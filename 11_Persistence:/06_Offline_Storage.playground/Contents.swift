import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - Offline Storage (Offline-First)
//==============================================================
//
// The LOCAL store is the source of truth — the UI always reads it.
// The network only keeps it in sync.
//
// Read:  show local data now → refresh from server → update local → UI updates
// Write: update local now → queue the change → send when online
//
// Runs offline with a fake server you can switch on and off.
//

@MainActor
final class FakeServer {

    var isOnline = false

    private(set) var quantities: [Int: Int] = [:]

    let feed = ["Shoes", "Cap", "New: Running Jacket"]

    func fetchFeed() async throws -> [String] {
        try await Task.sleep(for: .milliseconds(100))
        guard isOnline else { throw URLError(.notConnectedToInternet) }
        return feed
    }

    func setQuantity(_ quantity: Int, itemID: Int, requestID: UUID) async throws {
        try await Task.sleep(for: .milliseconds(100))
        guard isOnline else { throw URLError(.notConnectedToInternet) }
        quantities[itemID] = quantity                                // requestID → server ignores duplicates
    }
}


//==============================================================
// MARK: - 01. Read Path — Local First
//==============================================================
//
// Never show a spinner if you already have data.
// Show what's saved, then refresh in the background.
//

@MainActor
final class FeedRepository {

    private(set) var localFeed = ["Shoes", "Cap"]                     // saved from last session

    private let server: FakeServer

    init(server: FakeServer) {
        self.server = server
    }

    func load() async {
        print("Showing saved:", localFeed)                            // instant

        do {
            let fresh = try await server.fetchFeed()
            localFeed = fresh                                         // update local store
            print("Refreshed:", localFeed)                            // UI updates
        } catch {
            print("Offline → keep showing saved data")
        }
    }
}


//==============================================================
// MARK: - 02. Write Path — Outbox Queue
//==============================================================
//
// Update local immediately (UI feels instant), queue the change,
// sync when online. Each change has a requestID so a retry
// can't be applied twice (idempotency).
//

struct PendingChange {
    let requestID = UUID()
    let itemID: Int
    let quantity: Int
}

@MainActor
final class CartRepository {

    private(set) var localQuantities: [Int: Int] = [:]               // source of truth for UI

    private var outbox: [PendingChange] = []                         // saved to disk in a real app

    private let server: FakeServer

    init(server: FakeServer) {
        self.server = server
    }

    func setQuantity(_ quantity: Int, for itemID: Int) async {
        localQuantities[itemID] = quantity
        outbox.append(PendingChange(itemID: itemID, quantity: quantity))
        print("Item \(itemID) → \(quantity) | UI updated | pending: \(outbox.count)")
        await sync()
    }

    func sync() async {
        while let change = outbox.first {
            do {
                try await server.setQuantity(change.quantity, itemID: change.itemID, requestID: change.requestID)
                outbox.removeFirst()                                  // remove only after success
                print("Synced item \(change.itemID) | pending: \(outbox.count)")
            } catch {
                print("Offline → keep \(outbox.count) change(s) queued")
                return
            }
        }
    }
}


//==============================================================
// MARK: - 03. Conflicts
//==============================================================
//
// Same item edited on two devices while offline — who wins?
//
// Last-write-wins → compare updatedAt, newest wins (simple, can lose data)
// Server-wins     → server version always wins (safe for prices, stock)
// Merge           → combine fields / ask the user (notes, documents)
//

struct Note {
    let text: String
    let updatedAt: Date
}

func resolveLastWriteWins(local: Note, server: Note) -> Note {
    local.updatedAt > server.updatedAt ? local : server
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    let server = FakeServer()


    print("\n========== 01 - Read Path (Offline) ==========")

    let feed = FeedRepository(server: server)

    await feed.load()                                                 // saved data, stays usable


    print("\n========== 02 - Write While Offline ==========")

    let cart = CartRepository(server: server)

    await cart.setQuantity(2, for: 1)

    await cart.setQuantity(3, for: 2)


    print("\n========== 02 - Back Online → Sync ==========")

    server.isOnline = true                                            // NWPathMonitor would trigger this

    await cart.sync()

    print("Server now has:", server.quantities.sorted { $0.key < $1.key })


    print("\n========== 01 - Read Path (Online) ==========")

    await feed.load()                                                 // refreshed with new item


    print("\n========== 03 - Conflict: Last Write Wins ==========")

    let now = Date()

    let localNote = Note(text: "Size 9 please", updatedAt: now)

    let serverNote = Note(text: "Size 8", updatedAt: now.addingTimeInterval(-60))

    print("Winner:", resolveLastWriteWins(local: localNote, server: serverNote).text)   // Size 9 please


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 04. Detecting Connectivity
//==============================================================
//
// import Network
//
// let monitor = NWPathMonitor()
// monitor.pathUpdateHandler = { path in
//     if path.status == .satisfied {
//         Task { await cartRepository.sync() }        // back online → flush the outbox
//     }
// }
// monitor.start(queue: DispatchQueue(label: "network.monitor"))
//
// ⚠️ "Online" doesn't mean the server is reachable — still handle request failures.
//


//==============================================================
// MARK: - 05. Architecture
//==============================================================
//
// View → ViewModel → Repository → Local store (Core Data / SwiftData / SQLite)
//                               ↘ Sync engine → API client → Server
//
// The ViewModel only talks to the Repository and never waits on the network
// to show data.
//


//==============================================================
// MARK: - 06. Rules
//==============================================================
//
// ✅ Local store = source of truth; UI observes it
// ✅ Show saved data first, refresh in the background
// ✅ Queue offline writes (outbox), persist the queue, sync in order
// ✅ Remove a change only after the server confirms it
// ✅ requestID / idempotency key → retries never double-apply
// ✅ Pick a conflict strategy per data type
// ❌ Blank screen + spinner when saved data exists
// ❌ Dropping user edits because the network failed
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What does offline-first mean?
//    → The local database is the source of truth; the network just syncs it.
//
// 2. How do you show data instantly on launch?
//    → Read from the local store first, then refresh from the server in the background.
//
// 3. How do you handle writes while offline?
//    → Update locally, add the change to a persisted outbox, sync when back online.
//
// 4. Why add a request ID to queued changes?
//    → So a retried request isn't applied twice — idempotency.
//
// 5. How do you detect coming back online?
//    → NWPathMonitor — then flush the outbox, still handling request failures.
//
// 6. How do you resolve conflicts?
//    → Last-write-wins, server-wins, or merge — chosen per type of data.
//
// 7. Where does sync logic live?
//    → In the repository / sync layer, never in views or view models.
//
//==============================================================
