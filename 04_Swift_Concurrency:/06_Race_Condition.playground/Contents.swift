import Foundation

//==============================================================
// MARK: - Race Condition
//==============================================================
//
// Race condition = two threads access the same mutable data at the
// same time, and at least one writes → result depends on timing.
// Symptoms: wrong values, random crashes, bugs that "can't reproduce".
// Fixes → 07_Thread_Safety, 11_Actors
//


//==============================================================
// MARK: - 01. Lost Updates
//==============================================================
//
// @unchecked Sendable here is the BUG — it silences Swift 6
// so the race can be shown. Never do this without real protection.
//

final class UnsafeCounter: @unchecked Sendable {

    var value = 0

    func increment() {
        value += 1                           // ❌ not atomic
    }
}

print("\n========== 01 - Lost Updates ==========")

let unsafeCounter = UnsafeCounter()

DispatchQueue.concurrentPerform(iterations: 1000) { _ in
    unsafeCounter.increment()
}

print("Expected 1000, got:", unsafeCounter.value)   // often < 1000


//==============================================================
// MARK: - 02. Why value += 1 Isn't Safe
//==============================================================
//
// It's 3 steps: READ → ADD → WRITE
//
// Thread A reads 5
// Thread B reads 5
// Thread A writes 6
// Thread B writes 6        → one increment lost
//


//==============================================================
// MARK: - 03. Check-Then-Act
//==============================================================
//
// The check and the action aren't one step — another thread can
// change the value in between.
//
// if balance >= 100 {          // Thread A: 150 ✅   Thread B: 150 ✅
//     balance -= 100           // A → 50            B → -50 ❌
// }
//
// Real iOS examples: "is token expired → refresh" twice,
// "is image cached → download" twice.
//


//==============================================================
// MARK: - 04. Collections Can Crash
//==============================================================
//
// Array / Dictionary are not thread-safe.
// Concurrent writes can corrupt memory → random crash.
//
// var items: [Int] = []
// DispatchQueue.concurrentPerform(iterations: 1000) { i in
//     items.append(i)          ❌ crash or missing items
// }
//


//==============================================================
// MARK: - 05. Finding Races
//==============================================================
//
// 1. Thread Sanitizer — Scheme → Diagnostics → Thread Sanitizer.
//    Flags data races at runtime with both stack traces.
// 2. Swift 6 strict concurrency — many races become compile errors
//    ("capture of non-Sendable ... in @Sendable closure").
// 3. Crashes that change between runs → suspect a race.
//


//==============================================================
// MARK: - 06. How to Fix (Preview)
//==============================================================
//
// Serial queue        → one access at a time
// Concurrent + barrier→ many readers, one writer
// NSLock              → lock around read-modify-write
// Actor               → compiler-enforced isolation
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a race condition?
//    → Concurrent access to shared mutable state where the result depends on timing.
//
// 2. Why is value += 1 not thread-safe?
//    → It's read, add, write — two threads can read the same value and lose an update.
//
// 3. What is check-then-act?
//    → The check and the change aren't atomic, so another thread can change state in between.
//
// 4. Are Swift arrays thread-safe?
//    → No. Concurrent writes can crash or lose data.
//
// 5. How do you detect a race condition?
//    → Thread Sanitizer, Swift 6 strict concurrency checks.
//
// 6. How do you fix one?
//    → Serial queue, barrier, lock, or an actor.
//
//==============================================================
