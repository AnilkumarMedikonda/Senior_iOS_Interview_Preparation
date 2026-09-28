import Foundation

//==============================================================
// MARK: - Serial vs Concurrent Queues
//==============================================================
//
// Serial     → one task at a time, in order. Next starts after previous ends.
// Concurrent → tasks START in order but can run together, finish in any order.
// Serial / concurrent = how the QUEUE runs tasks.
// sync / async        = whether the CALLER waits → 04_Sync_vs_Async
//


//==============================================================
// MARK: - 01. Serial Queue
//==============================================================

print("\n========== 01 - Serial Queue ==========")

let serialQueue = DispatchQueue(label: "com.app.serial")

serialQueue.async {
    Thread.sleep(forTimeInterval: 0.2)
    print("Serial 1")
}

serialQueue.async {
    Thread.sleep(forTimeInterval: 0.1)
    print("Serial 2")
}

serialQueue.async {
    print("Serial 3")
}

// Output: Serial 1 → Serial 2 → Serial 3 — always in order


//==============================================================
// MARK: - 02. Concurrent Queue
//==============================================================

print("\n========== 02 - Concurrent Queue ==========")

let concurrentQueue = DispatchQueue(label: "com.app.concurrent", attributes: .concurrent)

concurrentQueue.async {
    Thread.sleep(forTimeInterval: 0.2)
    print("Concurrent 1")
}

concurrentQueue.async {
    Thread.sleep(forTimeInterval: 0.1)
    print("Concurrent 2")
}

concurrentQueue.async {
    print("Concurrent 3")
}

// Output: Concurrent 3 → Concurrent 2 → Concurrent 1 — fastest first


//==============================================================
// MARK: - 03. main Is Serial, global Is Concurrent
//==============================================================
//
// DispatchQueue.main      → serial (one UI update at a time)
// DispatchQueue.global()  → concurrent (shared system queues)
// DispatchQueue(label:)   → serial unless .concurrent
//


//==============================================================
// MARK: - 04. Serial Queue Protects Shared State
//==============================================================
//
// Only one task touches the value at a time → no race condition.
// Details → 06_Race_Condition, 07_Thread_Safety
//

final class Counter: @unchecked Sendable {   // safe: all access goes through the serial queue

    private let queue = DispatchQueue(label: "com.app.counter")

    private var value = 0

    func increment() {
        queue.sync {
            value += 1
        }
    }

    func current() -> Int {
        queue.sync { value }
    }
}

print("\n========== 04 - Serial Queue Protects Shared State ==========")

let counter = Counter()

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    counter.increment()
}

print("Count:", counter.current())      // 1000 — always


//==============================================================
// MARK: - 05. Summary
//==============================================================
//
// ┌─────────────────┬──────────────────────┬──────────────────────────┐
// │                 │ Serial               │ Concurrent               │
// ├─────────────────┼──────────────────────┼──────────────────────────┤
// │ Tasks at once   │ One                  │ Many                     │
// │ Finish order    │ Same as submitted    │ Any order                │
// │ Threads         │ One at a time        │ Several                  │
// │ Use for         │ Shared state, order  │ Independent work         │
// │ Examples        │ main, custom default │ global, .concurrent      │
// └─────────────────┴──────────────────────┴──────────────────────────┘
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Serial vs concurrent queue?
//    → Serial runs one task at a time in order; concurrent runs many, any finish order.
//
// 2. Is the main queue serial or concurrent?
//    → Serial.
//
// 3. Do concurrent tasks start in order?
//    → Yes, they start in order but can finish in any order.
//
// 4. Serial/concurrent vs sync/async?
//    → Serial/concurrent = how the queue runs tasks. Sync/async = whether the caller waits.
//
// 5. How can a serial queue make code thread-safe?
//    → Only one task accesses the shared value at a time.
//
//==============================================================
