import Foundation
import Combine

//==============================================================
// MARK: - Combine Basics
//==============================================================
//
// Combine = values over time.
// Publisher → Operators → Subscriber
//
// Publisher  → emits values, then finishes or fails (Output, Failure types)
// Operators  → transform values (map, filter, debounce …)
// Subscriber → receives them (sink, assign)
//
// Subscribing returns an AnyCancellable — keep it, or the pipeline stops.
//


//==============================================================
// MARK: - 01. A Pipeline
//==============================================================

print("\n========== 01 - A Pipeline ==========")

let pipeline = [1, 2, 3, 4].publisher
    .map { $0 * 10 }
    .filter { $0 > 15 }
    .sink(
        receiveCompletion: { completion in
            print("Completion:", completion)                 // finished
        },
        receiveValue: { value in
            print("Value:", value)                           // 20, 30, 40
        }
    )


//==============================================================
// MARK: - 02. Failure Ends the Stream
//==============================================================
//
// After .failure (or .finished) NO more values are delivered.
//

enum PriceError: Error {
    case invalid
}

print("\n========== 02 - Failure Ends the Stream ==========")

let failing = ["100", "250", "abc", "400"].publisher
    .tryMap { text -> Int in
        guard let price = Int(text) else { throw PriceError.invalid }
        return price
    }
    .sink(
        receiveCompletion: { completion in
            print("Completion:", completion)                 // failure(PriceError.invalid)
        },
        receiveValue: { price in
            print("Price:", price)                           // 100, 250 — "400" never arrives
        }
    )


//==============================================================
// MARK: - 03. Keep the AnyCancellable
//==============================================================
//
// The subscription lives only as long as its AnyCancellable.
// ❌ Not stored → deallocated immediately → later values are lost.
//

print("\n========== 03 - Keep the AnyCancellable ==========")

let cartUpdates = PassthroughSubject<Int, Never>()

_ = cartUpdates.sink { count in
    print("❌ Lost subscription:", count)                    // never prints
}

var cancellables = Set<AnyCancellable>()

cartUpdates
    .sink { count in
        print("✅ Stored subscription:", count)
    }
    .store(in: &cancellables)                                // kept alive

cartUpdates.send(3)                                          // ✅ Stored subscription: 3


//==============================================================
// MARK: - 04. Cancelling
//==============================================================
//
// cancel() — or the AnyCancellable being deallocated — stops the pipeline.
//

print("\n========== 04 - Cancelling ==========")

let searchText = PassthroughSubject<String, Never>()

let searchSubscription = searchText.sink { text in
    print("Search:", text)
}

searchText.send("sho")                                       // Search: sho

searchSubscription.cancel()

searchText.send("shoes")                                     // nothing — cancelled


//==============================================================
// MARK: - 05. Publishers Are Lazy (Except Future)
//==============================================================
//
// Most publishers do nothing until someone subscribes.
// Future runs its work IMMEDIATELY on creation.
// Wrap it in Deferred to make it lazy.
//

print("\n========== 05 - Lazy vs Eager ==========")

let eagerFuture = Future<Int, Never> { promise in
    print("Future work started — before any subscriber")      // prints now
    promise(.success(42))
}

let lazyFuture = Deferred {
    Future<Int, Never> { promise in
        print("Deferred work started — on subscribe")
        promise(.success(7))
    }
}

print("Subscribing now…")

lazyFuture
    .sink { print("Deferred value:", $0) }
    .store(in: &cancellables)

eagerFuture
    .sink { print("Future value:", $0) }
    .store(in: &cancellables)


//==============================================================
// MARK: - 06. Retain Cycle in sink
//==============================================================
//
// self owns cancellables → cancellable owns sink closure → closure captures self
// → cycle. Use [weak self].
//

@MainActor
final class CartViewModel {

    let updates = PassthroughSubject<Int, Never>()

    private(set) var count = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        updates
            .sink { [weak self] newCount in                  // ✅ weak
                self?.count = newCount
            }
            .store(in: &cancellables)
    }

    deinit {
        print("CartViewModel deinit")                        // prints → no leak
    }
}

print("\n========== 06 - Retain Cycle in sink ==========")

var cartViewModel: CartViewModel? = CartViewModel()

cartViewModel?.updates.send(5)

print("Count:", cartViewModel?.count as Any)                 // Optional(5)

cartViewModel = nil                                          // CartViewModel deinit


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What are the three parts of a Combine pipeline?
//    → Publisher emits, operators transform, subscriber receives.
//
// 2. What happens after a publisher sends a failure?
//    → The stream ends — no more values are delivered.
//
// 3. Why must you store the AnyCancellable?
//    → When it's deallocated the subscription is cancelled and values stop.
//
// 4. What does store(in:) do?
//    → Keeps the cancellable in a Set, tying the subscription to the owner's lifetime.
//
// 5. Are publishers lazy?
//    → Most are; Future runs immediately — wrap it in Deferred to make it lazy.
//
// 6. How can sink cause a retain cycle?
//    → self stores the cancellable, which captures self — use [weak self].
//
//==============================================================
