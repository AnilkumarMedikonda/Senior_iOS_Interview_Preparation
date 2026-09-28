import Foundation

//==============================================================
// MARK: - Actors
//==============================================================
//
// actor = reference type that protects its mutable state.
// Only one task runs inside it at a time → no data races.
// Outside callers must await. Inside, access is synchronous.
// Compiler-enforced — no locks or queues to forget.
//


//==============================================================
// MARK: - 01. Actor Basics
//==============================================================

actor BankAccount {

    private(set) var balance = 100

    func deposit(_ amount: Int) {
        balance += amount                            // inside → no await
    }

    func withdraw(_ amount: Int) -> Bool {
        guard balance >= amount else { return false }
        balance -= amount                            // check + act = atomic
        return true
    }
}

// account.balance += 10                         ❌ can't mutate from outside
// let value = account.balance                   ❌ needs await from outside


//==============================================================
// MARK: - 02. Race Fixed
//==============================================================

actor Counter {

    var value = 0

    func increment() {
        value += 1
    }
}


//==============================================================
// MARK: - 03. nonisolated
//==============================================================
//
// For members that don't touch mutable state → no await needed.
//

actor UserSession {

    let userID: String                               // let → safe without await

    var loginCount = 0

    init(userID: String) {
        self.userID = userID
    }

    nonisolated func displayID() -> String {
        "User-\(userID)"                             // only reads a let
    }
}


//==============================================================
// MARK: - 04. Reentrancy
//==============================================================
//
// At an await INSIDE an actor, other calls can enter.
// State checked before the await may be stale after it.
//

actor ImageLoader {

    private var cache: [Int: String] = [:]

    private(set) var downloads = 0

    func load(_ id: Int) async -> String {
        if let cached = cache[id] { return cached }
        downloads += 1
        try? await Task.sleep(for: .milliseconds(100))   // ⚠️ suspension — others enter
        let image = "image\(id)"
        cache[id] = image
        return image
    }
}

// Fix: store the in-flight Task, so duplicate callers await the same one.
actor SafeImageLoader {

    private var tasks: [Int: Task<String, Never>] = [:]

    private(set) var downloads = 0

    func load(_ id: Int) async -> String {
        if let existing = tasks[id] {
            return await existing.value
        }
        downloads += 1
        let task = Task {
            try? await Task.sleep(for: .milliseconds(100))
            return "image\(id)"
        }
        tasks[id] = task                             // saved BEFORE awaiting
        return await task.value
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - Actor Basics ==========")

    let account = BankAccount()

    await account.deposit(50)

    print("Withdraw 120:", await account.withdraw(120))   // true

    print("Balance:", await account.balance)             // 30


    print("\n========== 02 - Race Fixed ==========")

    let counter = Counter()

    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<1000 {
            group.addTask { await counter.increment() }
        }
    }

    print("Count:", await counter.value)                  // 1000


    print("\n========== 03 - nonisolated ==========")

    let session = UserSession(userID: "42")

    print(session.displayID())                            // User-42 — no await


    print("\n========== 04 - Reentrancy ==========")

    let loader = ImageLoader()

    async let first = loader.load(1)
    async let second = loader.load(1)
    _ = await (first, second)

    print("Downloads (bug):", await loader.downloads)     // 2 — duplicate download

    let safeLoader = SafeImageLoader()

    async let third = safeLoader.load(1)
    async let fourth = safeLoader.load(1)
    _ = await (third, fourth)

    print("Downloads (fixed):", await safeLoader.downloads)   // 1
}


//==============================================================
// MARK: - 05. Actor vs Class vs Serial Queue
//==============================================================
//
// ┌──────────────┬─────────────────┬──────────────────┬───────────────────┐
// │              │ class           │ class + queue    │ actor             │
// ├──────────────┼─────────────────┼──────────────────┼───────────────────┤
// │ Thread-safe  │ No              │ Yes (manual)     │ Yes (compiler)    │
// │ Caller waits │ —               │ Blocks (sync)    │ Suspends (await)  │
// │ Inheritance  │ Yes             │ Yes              │ No                │
// │ Mistakes     │ Races           │ Forgotten sync   │ Reentrancy        │
// └──────────────┴─────────────────┴──────────────────┴───────────────────┘
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is an actor?
//    → A reference type that isolates its state so only one task accesses it at a time.
//
// 2. Why must you await actor calls from outside?
//    → The caller may have to wait its turn; await lets it suspend instead of block.
//
// 3. Actor vs class with a serial queue?
//    → Same idea, but actors are compiler-checked and suspend instead of blocking.
//
// 4. What is nonisolated?
//    → Marks members that don't touch mutable state, so they need no await.
//
// 5. What is actor reentrancy?
//    → At an await inside an actor, other calls can run — state may change meanwhile.
//
// 6. How do you avoid reentrancy bugs?
//    → Update state before awaiting, re-check after, or share an in-flight Task.
//
// 7. Can actors inherit?
//    → No. Actors don't support inheritance.
//
//==============================================================
