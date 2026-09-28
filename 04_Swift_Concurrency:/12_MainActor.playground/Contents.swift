import Foundation

//==============================================================
// MARK: - @MainActor
//==============================================================
//
// @MainActor = a global actor bound to the main thread.
// Anything marked with it runs on main → safe for UI.
// Swift Concurrency replacement for DispatchQueue.main.async.
// Calling it from another context requires await.
//


//==============================================================
// MARK: - 01. @MainActor Class
//==============================================================
//
// Whole type on main — standard for ViewModels that drive UI.
//

@MainActor
final class ProductViewModel {

    private(set) var products: [String] = []

    private(set) var isLoading = false

    func load() async {
        isLoading = true                             // on main
        let result = await fetchProducts()           // suspends, main is free
        products = result                            // back on main
        isLoading = false
    }
}

func fetchProducts() async -> [String] {
    try? await Task.sleep(for: .milliseconds(100))
    return ["Shoes", "Cap"]
}


//==============================================================
// MARK: - 02. @MainActor Function
//==============================================================
//
// Only this function is pinned to main.
//

@MainActor
func showAlert(_ message: String) {
    print("Alert on main:", message)
}


//==============================================================
// MARK: - 03. MainActor.run
//==============================================================
//
// Hop to main from background work, then continue.
//

func processInBackground() async {
    let total = (1...1_000).reduce(0, +)             // background work
    await MainActor.run {
        print("Update UI with total:", total)        // on main
    }
}


//==============================================================
// MARK: - 04. Keep Heavy Work Off Main
//==============================================================
//
// Code inside a @MainActor type runs on main — even inside Task { }.
// Move CPU-heavy work to Task.detached, then return the result.
//

@MainActor
final class ReportViewModel {

    private(set) var summary = ""

    func buildReport() async {
        let result = await Task.detached {
            (1...1_000_000).reduce(0, +)             // off main
        }.value
        summary = "Total: \(result)"                 // back on main
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - @MainActor Class ==========")

    let viewModel = ProductViewModel()

    await viewModel.load()

    print("Products:", viewModel.products)           // ["Shoes", "Cap"]


    print("\n========== 02 - @MainActor Function ==========")

    await showAlert("Saved")                         // Alert on main: Saved


    print("\n========== 03 - MainActor.run ==========")

    await processInBackground()                      // Update UI with total: 500500


    print("\n========== 04 - Keep Heavy Work Off Main ==========")

    let reportVM = ReportViewModel()

    await reportVM.buildReport()

    print(reportVM.summary)                          // Total: 500000500000
}


//==============================================================
// MARK: - 05. DispatchQueue.main vs @MainActor
//==============================================================
//
// ┌────────────────────┬──────────────────────────┬───────────────────────┐
// │                    │ DispatchQueue.main.async │ @MainActor            │
// ├────────────────────┼──────────────────────────┼───────────────────────┤
// │ Checked by         │ Runtime (easy to forget) │ Compiler              │
// │ Style              │ Closure callback         │ await / annotation    │
// │ Granularity        │ Per call                 │ Type, func, property  │
// │ Use in new code    │ Legacy / GCD code        │ ✅ Default             │
// └────────────────────┴──────────────────────────┴───────────────────────┘
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is @MainActor?
//    → A global actor that runs code on the main thread — used for UI.
//
// 2. Why mark a ViewModel @MainActor?
//    → Its published state drives UI, so every update must happen on main.
//
// 3. How do you update UI from background async code?
//    → await MainActor.run { } or call a @MainActor function.
//
// 4. Does await inside a @MainActor method block the main thread?
//    → No. It suspends and frees main until the result arrives.
//
// 5. Does Task { } inside a @MainActor class run on main?
//    → Yes, it inherits the actor. Use Task.detached for heavy CPU work.
//
// 6. @MainActor vs DispatchQueue.main.async?
//    → @MainActor is compiler-checked; main.async is only checked at runtime.
//
//==============================================================
