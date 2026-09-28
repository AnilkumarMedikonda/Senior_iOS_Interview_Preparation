import Foundation

//==============================================================
// MARK: - Task Cancellation
//==============================================================
//
// Cancellation is COOPERATIVE.
// cancel() only sets a flag — the task must check it and stop.
// Check with Task.isCancelled or try Task.checkCancellation().
// Task.sleep and URLSession async APIs stop automatically.
//


//==============================================================
// MARK: - 01. cancel() Doesn't Stop Work by Itself
//==============================================================

func countIgnoringCancel() async -> Int {
    var count = 0
    for _ in 0..<5 {
        count += 1                                   // never checks → runs to the end
    }
    return count
}


//==============================================================
// MARK: - 02. Task.isCancelled
//==============================================================
//
// Check the flag and exit early — return partial result.
//

func processItems() async -> Int {
    var processed = 0
    for _ in 0..<10 {
        if Task.isCancelled { break }                // ✅ stop cooperatively
        try? await Task.sleep(for: .milliseconds(50))
        processed += 1
    }
    return processed
}


//==============================================================
// MARK: - 03. Task.checkCancellation()
//==============================================================
//
// Throws CancellationError → stops the whole call chain.
//

func downloadFiles() async throws -> Int {
    var downloaded = 0
    for _ in 0..<10 {
        try Task.checkCancellation()                 // ✅ throws if cancelled
        try await Task.sleep(for: .milliseconds(50)) // also throws on cancel
        downloaded += 1
    }
    return downloaded
}


//==============================================================
// MARK: - 04. Search-as-You-Type
//==============================================================
//
// Cancel the previous search before starting a new one.
//

@MainActor
final class SearchViewModel {

    private var searchTask: Task<Void, Never>?

    func search(_ text: String) {
        searchTask?.cancel()                         // drop the old request
        searchTask = Task {
            try? await Task.sleep(for: .milliseconds(300))   // debounce
            guard !Task.isCancelled else { return }
            print("Searching for:", text)
        }
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - cancel() Doesn't Stop Work ==========")

    let ignoring = Task { await countIgnoringCancel() }

    ignoring.cancel()

    print("Count:", await ignoring.value)            // 5 — ran fully


    print("\n========== 02 - Task.isCancelled ==========")

    let processing = Task { await processItems() }

    try? await Task.sleep(for: .milliseconds(120))

    processing.cancel()

    print("Processed:", await processing.value)      // ~2 of 10


    print("\n========== 03 - Task.checkCancellation() ==========")

    let downloading = Task { try await downloadFiles() }

    try? await Task.sleep(for: .milliseconds(120))

    downloading.cancel()

    do {
        _ = try await downloading.value
    } catch is CancellationError {
        print("Download cancelled")                  // Download cancelled
    } catch {
        print(error)
    }


    print("\n========== 04 - Search-as-You-Type ==========")

    let viewModel = SearchViewModel()

    viewModel.search("s")

    viewModel.search("sh")

    viewModel.search("shoes")

    try? await Task.sleep(for: .milliseconds(400))   // Searching for: shoes — only once
}


//==============================================================
// MARK: - 05. Automatic Cancellation
//==============================================================
//
// Structured children are cancelled with their parent:
//   async let → cancelled if the parent scope exits or throws
//   TaskGroup → group.cancelAll(), or first error in a throwing group
//
// SwiftUI .task { } → cancelled automatically when the view disappears.
// Task { } (unstructured) → NOT auto-cancelled — keep a reference and
// cancel it yourself (e.g. in deinit / viewDidDisappear).
//
// withTaskCancellationHandler → run cleanup immediately on cancel
// (e.g. cancel an underlying callback-based request).
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Does calling cancel() stop a task immediately?
//    → No. It sets a flag — the task must check it and stop itself.
//
// 2. Task.isCancelled vs Task.checkCancellation()?
//    → isCancelled returns a Bool; checkCancellation throws CancellationError.
//
// 3. Which APIs respond to cancellation automatically?
//    → Task.sleep, URLSession async methods — they throw CancellationError.
//
// 4. Are child tasks cancelled with the parent?
//    → Yes for async let and TaskGroup. No for Task { } and Task.detached.
//
// 5. How do you cancel an old search request?
//    → Keep the Task reference and cancel it before starting a new one.
//
// 6. Does SwiftUI cancel .task automatically?
//    → Yes, when the view disappears.
//
//==============================================================
