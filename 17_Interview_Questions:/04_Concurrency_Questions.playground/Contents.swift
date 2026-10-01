import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - 04_CONCURRENCY_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Each question:
 1. Question + short spoken answer
 2. Follow-up the interviewer usually asks
 3. A tiny code proof with DEBUG output

 Async proofs run in order inside one Task at the bottom.
*/


// ============================================================
// MARK: - Q01. Concurrency vs Parallelism
// ============================================================

/*
 Q: Concurrency vs parallelism?

 Answer:
 Concurrency = many tasks in progress (switching).
 Parallelism = running at the same instant on many cores.
*/

print("DEBUG Q01 - cores available:", ProcessInfo.processInfo.activeProcessorCount)


// ============================================================
// MARK: - Q02. Serial vs Concurrent Queue
// ============================================================

/*
 Q: Serial vs concurrent queue?

 Answer:
 Serial → one at a time, in order.
 Concurrent → many at once, any finish order.
*/

final class OrderRecorder: @unchecked Sendable {             // only touched on the serial queue
    var order: [Int] = []
}

let serialQueue = DispatchQueue(label: "serial")

let group = DispatchGroup()

let recorder = OrderRecorder()

for i in 1...3 {
    serialQueue.async(group: group) {
        recorder.order.append(i)
    }
}

group.wait()

print("DEBUG Q02 - serial order:", recorder.order)            // [1, 2, 3] always


// ============================================================
// MARK: - Q03. sync vs async
// ============================================================

/*
 Q: sync vs async?

 Answer:
 sync blocks the caller; async returns immediately.
*/

var steps: [String] = []

serialQueue.sync { steps.append("sync work") }

steps.append("after sync")

print("DEBUG Q03 - sync order:", steps)                      // work happens BEFORE "after sync"


// ============================================================
// MARK: - Q04. Deadlock
// ============================================================

/*
 Q: How do you create a deadlock?

 Answer:
 DispatchQueue.main.sync from the main thread —
 main waits for itself forever.

 ❌ DispatchQueue.main.sync { }      // from main → deadlock (commented out)
*/

print("DEBUG Q04 - main.sync on main = deadlock (not run)")


// ============================================================
// MARK: - Q05. Race Condition
// ============================================================

/*
 Q: What is a race condition?

 Answer:
 Unsynchronized read-modify-write on shared data → lost updates.
 Find with Thread Sanitizer.
*/

final class UnsafeCounter: @unchecked Sendable {             // ❌ lying about safety on purpose
    var value = 0
}

let unsafe = UnsafeCounter()

DispatchQueue.concurrentPerform(iterations: 10_000) { _ in
    unsafe.value += 1                                        // ❌ not atomic
}

print("DEBUG Q05 - unsafe count (expected 10000):", unsafe.value)   // usually LESS


// ============================================================
// MARK: - Q06. Thread Safety — Serial Queue / Lock
// ============================================================

/*
 Q: How do you make shared state thread-safe?

 Answer:
 Serial queue, barrier, lock — or an actor (Q12).
*/

final class LockedCounter: @unchecked Sendable {

    private var value = 0

    private let lock = NSLock()

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

let locked = LockedCounter()

DispatchQueue.concurrentPerform(iterations: 10_000) { _ in
    locked.increment()
}

print("DEBUG Q06 - locked count:", locked.current)           // 10000 ✅


// ============================================================
// MARK: - Q07–Q08. async/await Basics
// ============================================================

/*
 Q7: Why async/await?
 Answer: Linear code, throws for errors, cancellation built in.

 Q8: Does await block the thread?
 Answer: No — it suspends and frees the thread.
*/

func fetchPrice(id: Int) async -> Int {
    try? await Task.sleep(for: .milliseconds(100))           // suspends, doesn't block
    return id * 100
}


// ============================================================
// MARK: - Q09. Task vs Task.detached
// ============================================================

/*
 Q: Task vs Task.detached?

 Answer:
 Task inherits actor, priority, task-locals.
 Task.detached inherits nothing — use deliberately.
*/


// ============================================================
// MARK: - Q12. Actor
// ============================================================

/*
 Q: How do actors prevent data races?

 Answer:
 One task at a time touches its state; callers must await.
*/

actor SafeCounter {

    private(set) var value = 0

    func increment() {
        value += 1
    }
}


// ============================================================
// MARK: - Q13. Actor Reentrancy
// ============================================================

/*
 Q: What is actor reentrancy?

 Answer:
 Other calls can run at each await, so state checked before
 an await may change. Fix: store the in-flight Task.
*/

actor BuggyImageCache {

    private var cache: [Int: String] = [:]

    private(set) var downloads = 0

    func image(id: Int) async -> String {
        if let cached = cache[id] {
            return cached
        }
        downloads += 1
        try? await Task.sleep(for: .milliseconds(50))        // ← other calls run here
        let image = "image-\(id)"
        cache[id] = image
        return image
    }
}

actor FixedImageCache {

    private var inFlight: [Int: Task<String, Never>] = [:]

    private(set) var downloads = 0

    func image(id: Int) async -> String {
        if let existing = inFlight[id] {
            return await existing.value                      // join the same download
        }
        downloads += 1
        let task = Task {
            try? await Task.sleep(for: .milliseconds(50))
            return "image-\(id)"
        }
        inFlight[id] = task
        return await task.value
    }
}


// ============================================================
// MARK: - Q14. @MainActor
// ============================================================

/*
 Q: What is @MainActor?

 Answer:
 Global actor for the main thread — UI state always updated on main.
*/

@MainActor
final class ProductViewModel {

    private(set) var title = ""

    func load() async {
        let price = await fetchPrice(id: 5)                  // runs off main while suspended
        title = "₹\(price)"                                  // back on main
        print("DEBUG Q14 - updated on main thread:", Thread.isMainThread)
    }
}


// ============================================================
// MARK: - Q15. Sendable
// ============================================================

/*
 Q: What is Sendable?

 Answer:
 Safe to pass between concurrency domains: Sendable value
 types, actors, final immutable classes. Checked in Swift 6.

 struct Product: Sendable { let id: Int }        ✅
 final class Cart { var items = [Int]() }        ❌ not Sendable (mutable class)
*/


// ============================================================
// MARK: - Q17. Continuation
// ============================================================

/*
 Q: How do you bridge callbacks to async?

 Answer:
 withCheckedContinuation — resume EXACTLY once.
*/

func legacyFetch(completion: @escaping @Sendable (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.05) {
        completion("legacy data")
    }
}

func modernFetch() async -> String {
    await withCheckedContinuation { continuation in
        legacyFetch { value in
            continuation.resume(returning: value)            // exactly once
        }
    }
}


// ============================================================
// MARK: - Run Async Proofs
// ============================================================

Task { @MainActor in

    // Q10 — async let: parallel
    let clock = ContinuousClock()

    let parallel = await clock.measure {
        async let a = fetchPrice(id: 1)
        async let b = fetchPrice(id: 2)
        async let c = fetchPrice(id: 3)
        _ = await [a, b, c]
    }

    print("DEBUG Q10 - async let 3 × 100 ms took:", parallel)   // ~100 ms, not 300

    // Q10 — TaskGroup with order kept by index
    let prices = await withTaskGroup(of: (Int, Int).self) { group in
        for (index, id) in [3, 1, 2].enumerated() {
            group.addTask { (index, await fetchPrice(id: id)) }
        }
        var ordered = [Int](repeating: 0, count: 3)
        for await (index, price) in group {
            ordered[index] = price
        }
        return ordered
    }

    print("DEBUG Q10 - TaskGroup ordered:", prices)            // [300, 100, 200]

    // Q12 — actor is race-free
    let safe = SafeCounter()

    await withTaskGroup(of: Void.self) { group in
        for _ in 0..<1_000 {
            group.addTask { await safe.increment() }
        }
    }

    print("DEBUG Q12 - actor count:", await safe.value)        // 1000 ✅

    // Q13 — reentrancy bug vs fix
    let buggy = BuggyImageCache()

    async let first = buggy.image(id: 7)
    async let second = buggy.image(id: 7)
    _ = await (first, second)

    print("DEBUG Q13 - ❌ buggy downloads:", await buggy.downloads)   // 2

    let fixed = FixedImageCache()

    async let third = fixed.image(id: 7)
    async let fourth = fixed.image(id: 7)
    _ = await (third, fourth)

    print("DEBUG Q13 - ✅ fixed downloads:", await fixed.downloads)   // 1

    // Q14 — @MainActor
    await ProductViewModel().load()

    // Q16 — cooperative cancellation
    let longTask = Task {
        for step in 1...5 {
            if Task.isCancelled {
                print("DEBUG Q16 - stopped at step", step)
                return
            }
            try? await Task.sleep(for: .milliseconds(30))
        }
        print("DEBUG Q16 - finished all steps")
    }

    try? await Task.sleep(for: .milliseconds(70))

    longTask.cancel()

    await longTask.value

    // Q17 — continuation
    print("DEBUG Q17 -", await modernFetch())

    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - Q18. GCD vs async/await
// ============================================================

/*
 Q: GCD vs async/await?

 Answer:
 async/await + actors for new code (compiler-checked).
 GCD in legacy code and simple dispatching.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Shared mutable state   → actor
   UI state               → @MainActor
   Fixed parallel work    → async let
   Dynamic parallel work  → TaskGroup
   Old callback API       → continuation (resume once)
   Stop work              → cancel + check isCancelled
   Crossing boundaries    → Sendable

 Senior One-Liner:

 "I use async/await with structured concurrency, protect
  shared state with actors, keep UI on @MainActor, make
  cancellation cooperative, and let Swift 6 Sendable checks
  catch races at compile time."
*/
