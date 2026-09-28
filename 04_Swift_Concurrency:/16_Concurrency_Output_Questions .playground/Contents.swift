import Foundation

// ============================================================
// MARK: - 04 Swift Concurrency
// MARK: - 16 Concurrency Output Questions
// ============================================================
//
// Async output prints later and can appear under other questions.
// Every async print is labeled (Q03-B) so each line stays traceable.
//


// ============================================================
// MARK: - Q01. Serial Queue + async
// ============================================================

print("\n========== Q01 - Serial Queue + async ==========")

let q01 = DispatchQueue(label: "q01.serial")

print("Q01-A")

q01.async {
    print("Q01-B")
}

print("Q01-C")

// Usually: A, C, B
// Guaranteed: only A is first.
// B may print before C — the serial queue can start immediately.


// ============================================================
// MARK: - Q02. Serial Queue + sync
// ============================================================

print("\n========== Q02 - Serial Queue + sync ==========")

let q02 = DispatchQueue(label: "q02.serial")

print("Q02-A")

q02.sync {
    print("Q02-B")
}

print("Q02-C")

// Expected: A, B, C — sync blocks the caller until B finishes.


// ============================================================
// MARK: - Q03. Concurrent Queue + async
// ============================================================

print("\n========== Q03 - Concurrent Queue + async ==========")

let q03 = DispatchQueue(label: "q03.concurrent", attributes: .concurrent)

print("Q03-A")

q03.async {
    print("Q03-B")
}

q03.async {
    print("Q03-C")
}

print("Q03-D")

// Guaranteed: A is first.
// D, B, C — any order. D is usually next, but not guaranteed.


// ============================================================
// MARK: - Q04. Concurrent Queue + sync
// ============================================================

print("\n========== Q04 - Concurrent Queue + sync ==========")

let q04 = DispatchQueue(label: "q04.concurrent", attributes: .concurrent)

print("Q04-A")

q04.sync {
    print("Q04-B")
}

print("Q04-C")

// Expected: A, B, C — sync waits regardless of queue type.


// ============================================================
// MARK: - Q05. Nested sync — DEADLOCK
// ============================================================

print("\n========== Q05 - Nested sync (Deadlock) ==========")

// ❌ DO NOT RUN — deadlocks.
//
// let q05 = DispatchQueue(label: "q05.serial")
//
// q05.sync {
//     print("A")
//     q05.sync {
//         print("B")
//     }
//     print("C")
// }

// Expected: A, then freeze. B and C never print.
// Reason: the serial queue waits synchronously for itself.


// ============================================================
// MARK: - Q06. main.sync from Main — DEADLOCK
// ============================================================

print("\n========== Q06 - main.sync from Main (Deadlock) ==========")

// ❌ DO NOT RUN from the main thread — deadlocks.
//
// print("A")
//
// DispatchQueue.main.sync {
//     print("B")
// }
//
// print("C")

// Expected: A, then freeze. B and C never print.
// Reason: main waits for the block, but the block needs main to run.


// ============================================================
// MARK: - Q07. async Ordering
// ============================================================

print("\n========== Q07 - async Ordering ==========")

DispatchQueue.global().async {
    print("Q07-B")
}

print("Q07-A")

// Not guaranteed. Usually A, then B.
// async returns immediately — B runs whenever a thread picks it up.


// ============================================================
// MARK: - Q08. Multiple async Tasks
// ============================================================

print("\n========== Q08 - Multiple async Tasks ==========")

DispatchQueue.global().async {
    print("Q08-A")
}

DispatchQueue.global().async {
    print("Q08-B")
}

DispatchQueue.global().async {
    print("Q08-C")
}

print("Q08-D")

// D usually first (current path). A, B, C — any order.


// ============================================================
// MARK: - Q09. Serial Queue FIFO
// ============================================================

print("\n========== Q09 - Serial Queue FIFO ==========")

let q09 = DispatchQueue(label: "q09.serial")

q09.async {
    print("Q09-A")
}

q09.async {
    print("Q09-B")
}

q09.async {
    print("Q09-C")
}

// Guaranteed: A, B, C — serial queue runs one at a time, in order.


// ============================================================
// MARK: - Q10. Concurrent Queue Ordering
// ============================================================

print("\n========== Q10 - Concurrent Queue Ordering ==========")

let q10 = DispatchQueue(label: "q10.concurrent", attributes: .concurrent)

q10.async {
    print("Q10-A")
}

q10.async {
    print("Q10-B")
}

q10.async {
    print("Q10-C")
}

// Start order: A → B → C
// Finish / print order: NOT guaranteed.


// ============================================================
// MARK: - Q11. DispatchGroup
// ============================================================

print("\n========== Q11 - DispatchGroup ==========")

let q11 = DispatchGroup()

q11.enter()

DispatchQueue.global().async {
    print("Q11-A")
    q11.leave()
}

q11.enter()

DispatchQueue.global().async {
    print("Q11-B")
    q11.leave()
}

q11.notify(queue: .main) {
    print("Q11-C")
}

// A / B any order. C always after BOTH.


// ============================================================
// MARK: - Q12. Dispatch Barrier
// ============================================================

print("\n========== Q12 - Dispatch Barrier ==========")

let q12 = DispatchQueue(label: "q12.concurrent", attributes: .concurrent)

q12.async {
    print("Q12-A")
}

q12.async {
    print("Q12-B")
}

q12.async(flags: .barrier) {
    print("Q12-C")
}

q12.async {
    print("Q12-D")
}

// A / B any order (can run together).
// C waits for A and B. D starts only after C.
// Guaranteed: {A, B} → C → D


// ============================================================
// MARK: - Q13. Semaphore
// ============================================================

print("\n========== Q13 - Semaphore ==========")

let q13Semaphore = DispatchSemaphore(value: 1)

DispatchQueue.global().async {
    q13Semaphore.wait()
    print("Q13-A")
    q13Semaphore.signal()
}

DispatchQueue.global().async {
    q13Semaphore.wait()
    print("Q13-B")
    q13Semaphore.signal()
}

// value = 1 → one task inside at a time.
// A / B order NOT guaranteed.


// ============================================================
// MARK: - Q14. Task + await
// ============================================================

print("\n========== Q14 - Task + await ==========")

func q14GetValue() async -> Int {
    return 10
}

Task {
    print("Q14-A")
    let value = await q14GetValue()
    print("Q14-\(value)")
    print("Q14-B")
}

// Inside the Task: A, 10, B — await waits in order.
// The Task itself runs after the current top-level code.


// ============================================================
// MARK: - Q15. Task.value
// ============================================================

print("\n========== Q15 - Task.value ==========")

let q15Task = Task {
    return 100
}

print("Q15-A")

Task {
    let value = await q15Task.value
    print("Q15-\(value)")
    print("Q15-B")
}

// A first (sync). Then 100, B.
// await task.value waits for the result.


// ============================================================
// MARK: - Q16. Task Cancellation
// ============================================================

print("\n========== Q16 - Task Cancellation ==========")

let q16Task = Task {
    for i in 1...5 {
        if Task.isCancelled {
            print("Q16-Cancelled")
            return
        }
        print("Q16-\(i)")
    }
}

q16Task.cancel()

// Expected here: Cancelled
// Why: top-level code runs on @MainActor, and the Task inherits it.
// The Task can't start until this code finishes → cancel() lands first.
// Key concept: cancel() is cooperative — it sets a flag, not a force stop.


// ============================================================
// MARK: - Q17. Actor
// ============================================================

print("\n========== Q17 - Actor ==========")

actor Q17Counter {

    var value = 0

    func increment() {
        value += 1
    }
}

let q17Counter = Q17Counter()

Task {
    await q17Counter.increment()
    print("Q17-\(await q17Counter.value)")
}

// Expected: 1 — actor isolates its state, outside access needs await.


// ============================================================
// MARK: - Q18. MainActor
// ============================================================

print("\n========== Q18 - MainActor ==========")

@MainActor
func q18UpdateUI() {
    print("Q18-UI Updated")
}

Task {
    await q18UpdateUI()
}

// Expected: UI Updated — runs on the main actor.


// ============================================================
// MARK: - Q19. TaskGroup
// ============================================================

print("\n========== Q19 - TaskGroup ==========")

func q19TaskGroup() async -> [Int] {
    await withTaskGroup(of: Int.self) { group in
        group.addTask { 10 }
        group.addTask { 20 }
        group.addTask { 30 }
        var results: [Int] = []
        for await value in group {
            results.append(value)
        }
        return results
    }
}

Task {
    print("Q19-\(await q19TaskGroup())")
}

// Do NOT assume [10, 20, 30].
// Results arrive in COMPLETION order, not creation order.


// ============================================================
// MARK: - Q20. Sendable + Actor
// ============================================================

print("\n========== Q20 - Sendable + Actor ==========")

struct Q20User: Sendable {
    let name: String
}

actor Q20UserStore {

    private var user: Q20User?

    func setUser(_ user: Q20User) {
        self.user = user
    }

    func getUser() -> Q20User? {
        user
    }
}

let q20Store = Q20UserStore()

Task {
    await q20Store.setUser(Q20User(name: "Anil"))
    if let result = await q20Store.getUser() {
        print("Q20-\(result.name)")
    } else {
        print("Q20-No User")
    }
}

// Expected: Anil — Sendable struct passed into an actor safely.


// ============================================================
// MARK: - END
// ============================================================

print("\n========== CONCURRENCY OUTPUT QUESTIONS — SYNC PART DONE ==========")

// Async lines (Q03, Q07–Q20) may print after this line.
