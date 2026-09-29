import Foundation
import Combine

//==============================================================
// MARK: - Combine vs async/await
//==============================================================
//
// Combine     → a STREAM of values over time, shaped with operators
// async/await → ONE result, written as straight-line code
// AsyncSequence / AsyncStream → async/await's version of a stream
//
// They work together — bridge in both directions.
//
// ▶︎ Async sections print in order inside one Task at the bottom.
//


//==============================================================
// MARK: - 01. Mental Model
//==============================================================
//
// ┌────────────────────┬──────────────────────────────┬──────────────────────────────┐
// │                    │ Combine                      │ async/await                  │
// ├────────────────────┼──────────────────────────────┼──────────────────────────────┤
// │ Shape              │ Many values over time        │ One value (or AsyncSequence) │
// │ Code style         │ Declarative operator chain   │ Linear, top to bottom        │
// │ Errors             │ Failure type, catch / retry  │ throws, do / catch           │
// │ Cancellation       │ AnyCancellable               │ Task.cancel(), structured    │
// │ Main thread        │ receive(on: .main)           │ @MainActor                   │
// │ Time operators     │ debounce, throttle built in  │ swift-async-algorithms       │
// └────────────────────┴──────────────────────────────┴──────────────────────────────┘
//


//==============================================================
// MARK: - 02. Same Request, Two Styles
//==============================================================

var cancellables = Set<AnyCancellable>()

func productsPublisher() -> AnyPublisher<[String], Never> {           // Combine style
    Just(["Shoes", "Cap"])
        .delay(for: .milliseconds(100), scheduler: DispatchQueue.main)
        .eraseToAnyPublisher()
}

func fetchProducts() async -> [String] {                              // async style
    try? await Task.sleep(for: .milliseconds(100))
    return ["Shoes", "Cap"]
}

// Combine:
// productsPublisher()
//     .map { $0.count }
//     .sink { print("Combine count:", $0) }
//     .store(in: &cancellables)
//
// async/await:
// let count = await fetchProducts().count
// print("Async count:", count)


//==============================================================
// MARK: - 03. Publisher → async (.values)
//==============================================================
//
// Any publisher can be read with for-await via .values.
// Lets async code consume existing Combine streams (e.g. @Published).
//

@MainActor
final class CartStore {

    @Published var count = 0
}


//==============================================================
// MARK: - 04. async → Publisher (Future + Task)
//==============================================================
//
// Wrap an async function so Combine code can use it.
// Deferred → the work starts only when someone subscribes.
//

func productsBridged() -> AnyPublisher<[String], Never> {
    Deferred {
        Future { promise in
            Task {
                let products = await fetchProducts()
                promise(.success(products))
            }
        }
    }
    .eraseToAnyPublisher()
}


//==============================================================
// MARK: - 05. AsyncStream — Async Version of a Subject
//==============================================================
//
// yield values into a stream; consume with for-await.
//

func priceUpdates() -> AsyncStream<Int> {
    AsyncStream { continuation in
        for price in [4999, 4499, 3999] {
            continuation.yield(price)
        }
        continuation.finish()
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 02 - Same Request, Two Styles ==========")

    let combineCount = await withCheckedContinuation { continuation in
        productsPublisher()
            .map { $0.count }
            .sink { continuation.resume(returning: $0) }
            .store(in: &cancellables)
    }

    print("Combine count:", combineCount)                // 2

    let asyncCount = await fetchProducts().count

    print("Async count:  ", asyncCount)                  // 2 — same result, linear code


    print("\n========== 03 - Publisher → async ==========")

    let cart = CartStore()

    let listener = Task {
        for await count in cart.$count.values {          // Combine stream read with for-await
            print("Cart count:", count)
            if count == 2 { break }
        }
    }

    try? await Task.sleep(for: .milliseconds(50))

    cart.count = 1

    try? await Task.sleep(for: .milliseconds(50))         // give the loop time — .values delivers on demand

    cart.count = 2

    await listener.value                                  // Cart count: 0, 1, 2


    print("\n========== 04 - async → Publisher ==========")

    let bridgedCount = await withCheckedContinuation { continuation in
        productsBridged()
            .sink { continuation.resume(returning: $0.count) }
            .store(in: &cancellables)
    }

    print("Bridged count:", bridgedCount)                // 2


    print("\n========== 05 - AsyncStream ==========")

    for await price in priceUpdates() {
        print("Price:", price)                            // 4999, 4499, 3999
    }
}


//==============================================================
// MARK: - 06. When to Use Which
//==============================================================
//
// ✅ async/await
//    One-shot work: API calls, DB reads, file I/O
//    New code with @Observable view models
//    Sequential steps that depend on each other
//
// ✅ Combine
//    Continuous UI streams: text field → debounce → search
//    Combining live inputs: form validation with combineLatest
//    Existing codebases already built on Combine
//
// Bridges:
//    Publisher → async:  .values
//    async → Publisher:  Deferred { Future { Task { … } } }
//    Subject → async:    AsyncStream (continuation.yield)
//
// Missing in plain async/await: debounce, throttle, combineLatest
// → add Apple's swift-async-algorithms package, or keep Combine for those.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Combine vs async/await — core difference?
//    → Combine models streams of values; async/await models a single async result.
//
// 2. When would you still choose Combine?
//    → Continuous UI streams — debounce search, combineLatest validation — or an existing Combine codebase.
//
// 3. How do you consume a publisher from async code?
//    → for await value in publisher.values.
//
// 4. How do you expose an async function to Combine code?
//    → Deferred { Future { promise in Task { promise(.success(await work())) } } }.
//
// 5. What is AsyncStream?
//    → An AsyncSequence you push values into — the async/await counterpart of a subject.
//
// 6. How does cancellation differ?
//    → Combine cancels via AnyCancellable; async/await via Task.cancel() and structured concurrency.
//
// 7. What does async/await lack compared to Combine?
//    → Built-in time and combining operators — use swift-async-algorithms.
//
//==============================================================
