import Foundation

//==============================================================
// MARK: - Thread Safety
//==============================================================
//
// Thread-safe = correct results no matter how many threads call it.
// Rule: only ONE thread may write shared state at a time,
//       and no one reads while it's being written.
//
// @unchecked Sendable below is safe — every access is protected.
//


//==============================================================
// MARK: - 01. Serial Queue
//==============================================================
//
// All reads and writes go through one serial queue.
//

final class QueueCounter: @unchecked Sendable {

    private let queue = DispatchQueue(label: "com.app.counter")

    private var value = 0

    func increment() {
        queue.sync { value += 1 }
    }

    var current: Int {
        queue.sync { value }
    }
}

print("\n========== 01 - Serial Queue ==========")

let queueCounter = QueueCounter()

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    queueCounter.increment()
}

print("Serial queue:", queueCounter.current)       // 1000


//==============================================================
// MARK: - 02. Concurrent Queue + Barrier
//==============================================================
//
// Reads run in parallel (sync). Writes wait for exclusive access (barrier).
// Best for read-heavy data: caches, settings.
//

final class ImageCache: @unchecked Sendable {

    private let queue = DispatchQueue(label: "com.app.cache", attributes: .concurrent)

    private var storage: [String: String] = [:]

    func get(_ key: String) -> String? {
        queue.sync { storage[key] }                 // many readers
    }

    func set(_ key: String, _ value: String) {
        queue.async(flags: .barrier) {              // one writer
            self.storage[key] = value
        }
    }
}

print("\n========== 02 - Concurrent Queue + Barrier ==========")

let cache = ImageCache()

cache.set("logo", "logo.png")

print("Cached:", cache.get("logo") as Any)        // Optional("logo.png")


//==============================================================
// MARK: - 03. NSLock
//==============================================================
//
// Lock → work → unlock. defer guarantees unlock even on early return.
//

final class LockCounter: @unchecked Sendable {

    private let lock = NSLock()

    private var value = 0

    func increment() {
        lock.lock()
        defer { lock.unlock() }
        value += 1
    }

    var current: Int {
        lock.lock()
        defer { lock.unlock() }
        return value
    }
}

print("\n========== 03 - NSLock ==========")

let lockCounter = LockCounter()

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    lockCounter.increment()
}

print("NSLock:", lockCounter.current)              // 1000


//==============================================================
// MARK: - 04. Fixing Check-Then-Act
//==============================================================
//
// Check and change inside ONE protected block → atomic.
//

final class BankAccount: @unchecked Sendable {

    private let lock = NSLock()

    private var balance = 150

    func withdraw(_ amount: Int) -> Bool {
        lock.lock()
        defer { lock.unlock() }
        guard balance >= amount else { return false }
        balance -= amount
        return true
    }

    var current: Int {
        lock.lock()
        defer { lock.unlock() }
        return balance
    }
}

print("\n========== 04 - Fixing Check-Then-Act ==========")

let account = BankAccount()

DispatchQueue.concurrentPerform(iterations: 2) { _ in
    _ = account.withdraw(100)
}

print("Balance:", account.current)                 // 50 — never negative


//==============================================================
// MARK: - 05. Actor (Preview)
//==============================================================
//
// The compiler enforces one-at-a-time access. No locks, no queues.
// Details → 11_Actors
//

actor ActorCounter {

    var value = 0

    func increment() {
        value += 1
    }
}

print("\n========== 05 - Actor ==========")

let actorCounter = ActorCounter()

Task {
    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<1000 {
            group.addTask { await actorCounter.increment() }
        }
    }
    print("Actor:", await actorCounter.value)       // 1000 — prints last
}


//==============================================================
// MARK: - 06. Which Tool When
//==============================================================
//
// ┌─────────────────────┬──────────────────────────────┬────────────────────┐
// │ Tool                │ Best for                     │ Watch out          │
// ├─────────────────────┼──────────────────────────────┼────────────────────┤
// │ Serial queue        │ Simple shared state          │ sync onto itself   │
// │ Concurrent + barrier│ Read-heavy caches            │ Barrier on global ✗│
// │ NSLock              │ Short, fast critical sections│ Forgetting unlock  │
// │ Actor               │ New Swift Concurrency code   │ Reentrancy         │
// └─────────────────────┴──────────────────────────────┴────────────────────┘
//
// Barrier only works on your OWN concurrent queue, not global().
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What does thread-safe mean?
//    → Correct results no matter how many threads access it at once.
//
// 2. How does a serial queue make code thread-safe?
//    → It runs one block at a time, so reads and writes never overlap.
//
// 3. What is a barrier, and when would you use it?
//    → A write that waits for all reads and blocks new ones — for read-heavy caches.
//
// 4. Why doesn't a barrier work on DispatchQueue.global()?
//    → Global queues are shared; barrier only applies to your own concurrent queue.
//
// 5. Why use defer with NSLock?
//    → Guarantees unlock on every exit path, avoiding deadlocks.
//
// 6. How do you fix check-then-act?
//    → Do the check and the change inside the same lock or queue block.
//
// 7. Queue / lock vs actor?
//    → Actors give compiler-checked safety; queues and locks rely on discipline.
//
//==============================================================
