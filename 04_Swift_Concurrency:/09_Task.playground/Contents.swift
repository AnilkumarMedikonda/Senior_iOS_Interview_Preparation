import Foundation

//==============================================================
// MARK: - Task
//==============================================================
//
// Task = a unit of async work.
// Task { }          → starts async work from sync code, inherits context
// async let         → run child work in parallel, await later
// Task.detached { } → no inherited context — rarely needed
//

func fetch(_ name: String) async -> String {
    try? await Task.sleep(for: .milliseconds(100))
    return name
}


//==============================================================
// MARK: - 01. Task { }
//==============================================================
//
// Bridge from sync code into async.
// Inherits the current actor (e.g. @MainActor) and priority.
//
// func viewDidLoad() {
//     Task {
//         let user = await fetch("Anil")   // then update UI — still on main
//     }
// }
//


//==============================================================
// MARK: - 02. Task Returns a Value
//==============================================================
//
// Keep a reference → await .value later, or cancel it.
//


//==============================================================
// MARK: - 03. async let — Parallel
//==============================================================
//
// Both start immediately; await collects them.
// Total time ≈ the slowest one, not the sum.
//

func loadParallel() async {
    let start = Date()
    async let profile = fetch("Profile")
    async let orders = fetch("Orders")
    let results = await [profile, orders]
    print(results, String(format: "%.1fs", Date().timeIntervalSince(start)))   // ~0.1s
}


//==============================================================
// MARK: - 04. Task.detached
//==============================================================
//
// Does NOT inherit actor or priority. Doesn't run on main.
// Use only for independent background work (e.g. cleanup, logging).
// Default choice is Task { }.
//


//==============================================================
// MARK: - 05. Priority
//==============================================================
//
// .high / .userInitiated → user is waiting
// .medium                 → default
// .low / .utility         → background-ish
// .background             → user doesn't see it
//


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 02 - Task Returns a Value ==========")

    let task = Task { await fetch("Anil") }

    print("Value:", await task.value)                // Value: Anil


    print("\n========== 03 - async let ==========")

    await loadParallel()                             // ["Profile", "Orders"] ~0.1s


    print("\n========== 04 - Task.detached ==========")

    let detached = Task.detached(priority: .background) {
        await fetch("Logs cleaned")
    }

    print(await detached.value)                      // Logs cleaned


    print("\n========== 05 - Priority ==========")

    let urgent = Task(priority: .userInitiated) {
        await fetch("Urgent")
    }

    print(await urgent.value)                        // Urgent
}


//==============================================================
// MARK: - 06. Structured vs Unstructured
//==============================================================
//
// ┌───────────────────┬───────────────┬────────────────────────────────┐
// │ Kind              │ Structured?   │ Cancelled with parent?         │
// ├───────────────────┼───────────────┼────────────────────────────────┤
// │ async let         │ Yes (child)   │ Yes                            │
// │ TaskGroup         │ Yes (child)   │ Yes                            │
// │ Task { }          │ No            │ No — cancel manually           │
// │ Task.detached { } │ No            │ No, and inherits nothing       │
// └───────────────────┴───────────────┴────────────────────────────────┘
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a Task?
//    → A unit of async work; Task { } starts it from sync code.
//
// 2. Task { } vs Task.detached { }?
//    → Task inherits actor and priority; detached inherits nothing.
//
// 3. How do you run two async calls in parallel?
//    → async let both, then await them together.
//
// 4. async let vs two awaits in a row?
//    → async let runs in parallel (~slowest); sequential awaits add up.
//
// 5. Structured vs unstructured concurrency?
//    → Structured (async let, TaskGroup) is tied to the parent and auto-cancelled.
//
// 6. Does Task { } inside a @MainActor class run on main?
//    → Yes, it inherits the actor — heavy work should be moved off it.
//
//==============================================================
