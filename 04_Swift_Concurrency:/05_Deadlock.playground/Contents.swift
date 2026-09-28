import Foundation

//==============================================================
// MARK: - Deadlock
//==============================================================
//
// Deadlock = two pieces of work each wait for the other → neither finishes.
// App freezes. No crash log — just a hang (or watchdog kill on main).
// Most common cause in iOS: sync onto the queue you're already on.
//
// Deadlock lines are commented out (❌) so the playground doesn't freeze.
//


//==============================================================
// MARK: - 01. main.sync from Main
//==============================================================
//
// Main is busy running this code and waits for the block.
// The block needs main to run → waits forever.
//

print("\n========== 01 - main.sync from Main ==========")

print("On main:", Thread.isMainThread)       // true

// DispatchQueue.main.sync {                 ❌ deadlock
//     print("Never runs")
// }

DispatchQueue.main.async {                   // ✅ fix — don't wait
    print("main.async runs later")
}


//==============================================================
// MARK: - 02. Serial Queue sync onto Itself
//==============================================================

let serialQueue = DispatchQueue(label: "com.app.serial")

print("\n========== 02 - Serial Queue sync onto Itself ==========")

// serialQueue.async {
//     serialQueue.sync {                    ❌ deadlock — waits for itself
//         print("Never runs")
//     }
// }

serialQueue.async {
    serialQueue.async {                      // ✅ fix — async instead
        print("Nested async runs")
    }
}


//==============================================================
// MARK: - 03. Concurrent Queue — No Deadlock
//==============================================================
//
// A concurrent queue can start the inner block on another thread.
//

let concurrentQueue = DispatchQueue(label: "com.app.concurrent", attributes: .concurrent)

print("\n========== 03 - Concurrent Queue ==========")

concurrentQueue.async {
    concurrentQueue.sync {
        print("Nested sync on concurrent queue — works")
    }
}


//==============================================================
// MARK: - 04. Two Queues Waiting on Each Other
//==============================================================
//
// Queue A waits for B while B waits for A.
//
// queueA.async {
//     queueB.sync {
//         queueA.sync { }                   ❌ A is blocked waiting for B
//     }
// }
//


//==============================================================
// MARK: - 05. Lock Deadlock
//==============================================================
//
// NSLock is not recursive — locking twice on the same thread freezes.
//

let lock = NSLock()

print("\n========== 05 - Lock Deadlock ==========")

// lock.lock()
// lock.lock()                               ❌ deadlock — already held

let recursiveLock = NSRecursiveLock()

recursiveLock.lock()

recursiveLock.lock()                         // ✅ same thread can re-lock

print("Recursive lock acquired twice")

recursiveLock.unlock()

recursiveLock.unlock()


//==============================================================
// MARK: - 06. How to Avoid Deadlocks
//==============================================================
//
// 1. Never call sync onto the queue you're currently on (especially main).
// 2. Prefer async; use sync only for short reads from a serial queue.
// 3. Always acquire locks in the same order.
// 4. Don't block an async context with semaphores or sync waits.
// 5. Prefer actors — they suspend instead of blocking a thread.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a deadlock?
//    → Two tasks wait on each other forever, so neither can finish.
//
// 2. Why does DispatchQueue.main.sync from main deadlock?
//    → Main waits for the block, but the block needs main to run.
//
// 3. Does nested sync always deadlock?
//    → Only on the same serial queue. A concurrent queue can run it elsewhere.
//
// 4. How do you fix a sync-onto-self deadlock?
//    → Use async, or move the work to a different queue.
//
// 5. How do locks cause deadlocks?
//    → Re-locking a non-recursive lock, or two threads taking locks in opposite order.
//
// 6. How do actors help?
//    → They suspend with await instead of blocking threads.
//
//==============================================================
