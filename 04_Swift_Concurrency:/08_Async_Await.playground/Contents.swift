import Foundation

//==============================================================
// MARK: - async / await
//==============================================================
//
// async → function can pause (suspend) without blocking a thread.
// await → marks a point where the function may suspend.
// Code reads top-to-bottom like sync code — no callback nesting.
//


//==============================================================
// MARK: - 01. async Function
//==============================================================

func fetchUserName() async -> String {
    try? await Task.sleep(for: .milliseconds(100))   // simulate network
    return "Anil"
}


//==============================================================
// MARK: - 02. Callbacks vs async / await
//==============================================================
//
// ❌ Callbacks — nesting, easy to forget completion, manual errors
//
// fetchUser { user in
//     fetchOrders(user) { orders in
//         fetchDetails(orders) { details in
//             print(details)
//         }
//     }
// }
//
// ✅ async / await — linear, errors via try
//
// let user = try await fetchUser()
// let orders = try await fetchOrders(user)
// let details = try await fetchDetails(orders)
//


//==============================================================
// MARK: - 03. async throws
//==============================================================

enum NetworkError: Error {
    case notFound
}

func fetchOrders(for user: String) async throws -> [String] {
    try await Task.sleep(for: .milliseconds(100))
    guard user == "Anil" else { throw NetworkError.notFound }
    return ["Shoes", "Cap"]
}


//==============================================================
// MARK: - 04. Sequential awaits
//==============================================================
//
// Each await waits for the previous one → total time adds up.
// Run them in parallel → async let (09_Task)
//

func loadSequential() async {
    let start = Date()
    _ = await fetchUserName()                        // ~0.1s
    _ = await fetchUserName()                        // ~0.1s
    print("Sequential:", String(format: "%.1fs", Date().timeIntervalSince(start)))   // ~0.2s
}


//==============================================================
// MARK: - 05. Calling async from Sync Code
//==============================================================
//
// await only works inside an async context.
// From sync code (viewDidLoad, button action) → wrap in Task { }.
//
// func buttonTapped() {
//     let name = await fetchUserName()     ❌ 'async' call in non-async function
// }
//
// func buttonTapped() {
//     Task {
//         let name = await fetchUserName() // ✅
//     }
// }
//


//==============================================================
// MARK: - 06. Suspension Points
//==============================================================
//
// At each await, the function pauses and FREES the thread.
// It may resume on a DIFFERENT thread (unless on an actor like @MainActor).
// State can change while suspended → re-check assumptions after await.
//


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - async Function ==========")

    let name = await fetchUserName()

    print("Name:", name)                             // Name: Anil


    print("\n========== 03 - async throws ==========")

    do {
        let orders = try await fetchOrders(for: name)
        print("Orders:", orders)                     // ["Shoes", "Cap"]
        _ = try await fetchOrders(for: "Ravi")
    } catch {
        print("Error:", error)                       // Error: notFound
    }


    print("\n========== 04 - Sequential awaits ==========")

    await loadSequential()
}


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What does async mean?
//    → The function can suspend without blocking the thread it runs on.
//
// 2. What does await do?
//    → Marks a suspension point — the function pauses until the result is ready.
//
// 3. Does await block the thread?
//    → No. The thread is freed to do other work while waiting.
//
// 4. async/await vs completion handlers?
//    → Linear code, errors with try, no missed callbacks, built-in cancellation.
//
// 5. Are two awaits in a row parallel?
//    → No, they run one after another. Use async let or TaskGroup for parallel.
//
// 6. How do you call async code from a sync function?
//    → Wrap it in Task { }.
//
// 7. Can code resume on a different thread after await?
//    → Yes, unless it's isolated to an actor like @MainActor.
//
//==============================================================
