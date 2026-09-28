import Foundation

//==============================================================
// MARK: - Sync vs Async
//==============================================================
//
// async → submit work and return immediately. Caller keeps going.
// sync  → submit work and WAIT until it finishes. Caller is blocked.
// It's about the CALLER, not the queue.
//

let workQueue = DispatchQueue(label: "com.app.work")


//==============================================================
// MARK: - 01. async — Caller Doesn't Wait
//==============================================================

print("\n========== 01 - async ==========")

print("A")

workQueue.async {
    print("B")
}

print("C")

// Output: A → C → B (caller didn't wait for B)


//==============================================================
// MARK: - 02. sync — Caller Waits
//==============================================================

print("\n========== 02 - sync ==========")

print("D")

workQueue.sync {
    print("E")
}

print("F")

// Output: D → E → F (caller blocked until E finished)


//==============================================================
// MARK: - 03. sync Returns a Value
//==============================================================
//
// Useful to read shared state safely from a serial queue.
//

print("\n========== 03 - sync Returns a Value ==========")

let total = workQueue.sync {
    10 + 20
}

print("Total:", total)                   // Total: 30


//==============================================================
// MARK: - 04. sync Deadlocks
//==============================================================
//
// sync onto the SAME serial queue you're already on → waits for itself.
// Details → 05_Deadlock
//
// ❌ DispatchQueue.main.sync { }              // called from main → freeze
//
// ❌ workQueue.async {
//        workQueue.sync { }                    // same serial queue → freeze
//    }
//


//==============================================================
// MARK: - 05. Combinations
//==============================================================
//
// ┌──────────────────┬──────────────────────────────────────────────────┐
// │ Combination      │ Behavior                                         │
// ├──────────────────┼──────────────────────────────────────────────────┤
// │ serial + async   │ Caller continues, tasks run one by one           │
// │ serial + sync    │ Caller waits, tasks run one by one               │
// │ concurrent+async │ Caller continues, tasks run together             │
// │ concurrent+sync  │ Caller waits for its task, others may run along  │
// │ main.async       │ ✅ Standard way to update UI from background      │
// │ main.sync        │ ❌ From main → deadlock                           │
// └──────────────────┴──────────────────────────────────────────────────┘
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. sync vs async?
//    → sync blocks the caller until the work finishes; async returns immediately.
//
// 2. Is sync / async about the queue or the caller?
//    → The caller. Serial / concurrent is about the queue.
//
// 3. What does print A, async B, print C output?
//    → A, C, B — the caller doesn't wait for B.
//
// 4. When would you use sync?
//    → To read shared state from a serial queue and return the value.
//
// 5. Why does DispatchQueue.main.sync from main deadlock?
//    → Main waits for the block, but the block needs main to run.
//
//==============================================================
