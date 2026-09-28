import Foundation

//==============================================================
// MARK: - Sendable
//==============================================================
//
// Sendable = safe to pass between concurrency domains
// (tasks, actors, threads) without a data race.
// Swift 6 checks this at compile time.
//
// Sendable when:
// value types with Sendable members → automatic
// final class with only let Sendable properties
// actors → always
// @unchecked Sendable → YOU guarantee safety (locks / queues)
//


//==============================================================
// MARK: - 01. Value Types
//==============================================================
//
// Copied on send → no shared state → safe.
//

struct Product: Sendable {
    let id: Int
    var name: String
}


//==============================================================
// MARK: - 02. Classes
//==============================================================
//
// final + only immutable (let) Sendable properties → OK.
//

final class AppConfig: Sendable {
    let baseURL: String

    init(baseURL: String) {
        self.baseURL = baseURL
    }
}

// final class Cart: Sendable {
//     var items: [String] = []              ❌ mutable stored property
// }


//==============================================================
// MARK: - 03. Actors
//==============================================================
//
// Always Sendable — their state is isolated.
//

actor CartStore {

    private var items: [String] = []

    func add(_ item: String) {
        items.append(item)
    }

    func count() -> Int {
        items.count
    }
}


//==============================================================
// MARK: - 04. @unchecked Sendable
//==============================================================
//
// Compiler can't verify — you promise every access is protected.
// Use for older lock / queue-based classes.
//

final class TokenStore: @unchecked Sendable {

    private let lock = NSLock()

    private var token = ""

    func update(_ newToken: String) {
        lock.lock()
        defer { lock.unlock() }
        token = newToken
    }

    func current() -> String {
        lock.lock()
        defer { lock.unlock() }
        return token
    }
}


//==============================================================
// MARK: - 05. @Sendable Closures
//==============================================================
//
// Closures passed to Task / TaskGroup / DispatchQueue are @Sendable.
// They can't capture mutable local variables.
//
// var count = 0
// Task {
//     count += 1                            ❌ mutation of captured var in concurrently-executing code
// }
//
// let total = 10
// Task {
//     print(total)                          ✅ let is fine
// }
//


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - Value Types ==========")

    let product = Product(id: 1, name: "Shoes")

    let name = await Task.detached { product.name }.value     // copied across

    print(name)                                     // Shoes


    print("\n========== 02 - Classes ==========")

    let config = AppConfig(baseURL: "https://api.example.com")

    let url = await Task.detached { config.baseURL }.value

    print(url)


    print("\n========== 03 - Actors ==========")

    let store = CartStore()

    await withTaskGroup(of: Void.self) { group in
        for item in ["Shoes", "Cap", "Bag"] {
            group.addTask { await store.add(item) }
        }
    }

    print("Items:", await store.count())            // 3


    print("\n========== 04 - @unchecked Sendable ==========")

    let tokenStore = TokenStore()

    await Task.detached { tokenStore.update("abc123") }.value

    print("Token:", tokenStore.current())           // abc123
}


//==============================================================
// MARK: - 06. Common Swift 6 Errors
//==============================================================
//
// "Capture of non-Sendable type in a @Sendable closure"
//   → make the type Sendable, use an actor, or isolate to @MainActor.
//
// "Main actor-isolated property can not be referenced from a nonisolated context"
//   → mark the caller @MainActor or await MainActor.run.
//
// "Mutation of captured var in concurrently-executing code"
//   → use let, an actor, or return the value from the task.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is Sendable?
//    → A marker that a type is safe to pass across tasks and actors without data races.
//
// 2. Which types are Sendable automatically?
//    → Structs and enums whose members are all Sendable, and all actors.
//
// 3. When can a class be Sendable?
//    → When it's final and all stored properties are immutable Sendable lets.
//
// 4. What is @unchecked Sendable?
//    → Turns off the check — you guarantee safety with locks or queues.
//
// 5. What is a @Sendable closure?
//    → A closure safe to run concurrently; it can't capture mutable state.
//
// 6. Why does Swift 6 show so many Sendable errors?
//    → Strict concurrency turns possible data races into compile-time errors.
//
//==============================================================
