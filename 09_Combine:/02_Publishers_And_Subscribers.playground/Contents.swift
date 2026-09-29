import Foundation
import Combine

//==============================================================
// MARK: - Publishers & Subscribers
//==============================================================
//
// Publishers:  Just, sequence, Empty, Fail, Future, subjects, @Published,
//              Timer.publish, NotificationCenter, URLSession.dataTaskPublisher
// Subscribers: sink (closure), assign (write into a property)
// Subjects:    publishers you can push values into with send(_:)
//

var cancellables = Set<AnyCancellable>()


//==============================================================
// MARK: - 01. Built-In Publishers
//==============================================================

print("\n========== 01 - Built-In Publishers ==========")

Just("Shoes")                                              // one value, never fails
    .sink { print("Just:", $0) }
    .store(in: &cancellables)

[10, 20].publisher                                          // each element, then finished
    .sink { print("Sequence:", $0) }
    .store(in: &cancellables)

Empty<Int, Never>()                                         // no values, finishes immediately
    .sink(receiveCompletion: { print("Empty:", $0) }, receiveValue: { _ in })
    .store(in: &cancellables)

enum LoadError: Error {
    case offline
}

Fail<Int, LoadError>(error: .offline)                       // fails immediately
    .sink(receiveCompletion: { print("Fail:", $0) }, receiveValue: { _ in })
    .store(in: &cancellables)


//==============================================================
// MARK: - 02. PassthroughSubject vs CurrentValueSubject
//==============================================================
//
// Passthrough  → no stored value; late subscribers miss earlier sends (events)
// CurrentValue → stores the latest value; new subscribers get it immediately (state)
//

print("\n========== 02 - Passthrough vs CurrentValue ==========")

let buttonTaps = PassthroughSubject<String, Never>()

let cartCount = CurrentValueSubject<Int, Never>(0)

buttonTaps.send("tap 1")                                    // nobody listening → lost

cartCount.send(3)                                           // stored

buttonTaps
    .sink { print("Passthrough got:", $0) }
    .store(in: &cancellables)

cartCount
    .sink { print("CurrentValue got:", $0) }                // 3 immediately
    .store(in: &cancellables)

buttonTaps.send("tap 2")                                    // Passthrough got: tap 2

cartCount.send(4)                                           // CurrentValue got: 4

print("cartCount.value:", cartCount.value)                  // 4 — readable anytime


//==============================================================
// MARK: - 03. @Published
//==============================================================
//
// $property → a publisher of the property's values.
// ⚠️ It emits in willSet — inside sink, self.property is still the OLD value.
//    Use the value the closure receives.
//

@MainActor
final class CartViewModel {

    @Published var count = 0

    private var cancellables = Set<AnyCancellable>()

    init() {
        $count
            .sink { [weak self] newValue in
                guard let self else { return }
                print("Received \(newValue), self.count is \(self.count)")
            }
            .store(in: &cancellables)
    }
}

print("\n========== 03 - @Published ==========")

let cart = CartViewModel()                                  // Received 0, self.count is 0

cart.count = 5                                              // Received 5, self.count is 0 ⚠️ old value


//==============================================================
// MARK: - 04. assign — Cycle vs No Cycle
//==============================================================
//
// assign(to: \.x, on: self) → holds self STRONGLY → retain cycle
// assign(to: &$x)           → no cycle, no AnyCancellable needed (iOS 14+)
//

@MainActor
final class LeakyProfile {

    @Published var displayName = ""

    private var cancellables = Set<AnyCancellable>()

    init(names: PassthroughSubject<String, Never>) {
        names
            .map { "Hi, \($0)" }
            .assign(to: \.displayName, on: self)            // ❌ strong self
            .store(in: &cancellables)
    }

    deinit {
        print("LeakyProfile deinit")
    }
}

@MainActor
final class SafeProfile {

    @Published var displayName = ""

    init(names: PassthroughSubject<String, Never>) {
        names
            .map { "Hi, \($0)" }
            .assign(to: &$displayName)                      // ✅ tied to the property
    }

    deinit {
        print("SafeProfile deinit")
    }
}

print("\n========== 04 - assign ==========")

let names = PassthroughSubject<String, Never>()

var leaky: LeakyProfile? = LeakyProfile(names: names)

var safe: SafeProfile? = SafeProfile(names: names)

names.send("Anil")

print(safe?.displayName as Any)                             // Optional("Hi, Anil")

leaky = nil                                                 // no deinit ❌ leaked

safe = nil                                                  // SafeProfile deinit ✅


//==============================================================
// MARK: - 05. Hide Subjects with AnyPublisher
//==============================================================
//
// Keep the subject private; expose a read-only AnyPublisher.
// Outside code can subscribe but can't send.
//

final class CartService {

    private let itemsSubject = CurrentValueSubject<[String], Never>([])

    var items: AnyPublisher<[String], Never> {
        itemsSubject.eraseToAnyPublisher()
    }

    func add(_ item: String) {
        itemsSubject.send(itemsSubject.value + [item])
    }
}

print("\n========== 05 - AnyPublisher ==========")

let cartService = CartService()

cartService.items
    .sink { print("Cart:", $0) }
    .store(in: &cancellables)

cartService.add("Shoes")                                    // Cart: ["Shoes"]

// cartService.items.send(["Hack"])                         ❌ AnyPublisher has no send


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. PassthroughSubject vs CurrentValueSubject?
//    → Passthrough has no stored value (events); CurrentValue stores and replays the latest (state).
//
// 2. What does Just do?
//    → Emits one value and finishes; it can never fail.
//
// 3. What is $property on @Published?
//    → A publisher of the property's values, starting with the current one.
//
// 4. Why is self.property old inside a @Published sink?
//    → @Published emits in willSet — use the value passed to the closure.
//
// 5. assign(to:on:) vs assign(to: &$property)?
//    → The first retains the object strongly (cycle risk); the second doesn't and needs no cancellable.
//
// 6. Why expose AnyPublisher instead of the subject?
//    → Callers can subscribe but not send — encapsulation.
//
//==============================================================
