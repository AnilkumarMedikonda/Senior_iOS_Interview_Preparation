import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - Request Cancellation
//==============================================================
//
// Cancel requests the user no longer needs:
// left the screen, typed a new search, changed a filter, pulled to refresh.
//
// Why: saves data + battery, and prevents OLD responses from
// overwriting NEW screen state.
//
// URLSession async calls stop automatically when their Task is cancelled
// (they throw URLError(.cancelled)).
//
// Runs offline with fake requests. Open the console: ⇧⌘Y
//

func fakeRequest(_ name: String, delay: Int = 200) async throws -> String {
    try await Task.sleep(for: .milliseconds(delay))       // throws if cancelled
    return "\(name) result"
}


//==============================================================
// MARK: - 01. Cancelling a Task
//==============================================================
//
// Cancelled → handle silently: no alert, no retry.
//

func cancelOneRequest() async {

    let request = Task {
        try await fakeRequest("Products")
    }

    request.cancel()

    do {
        let value = try await request.value
        print("Got:", value)
    } catch is CancellationError {
        print("Cancelled → show nothing")
    } catch {
        print("Error:", error)
    }
}


//==============================================================
// MARK: - 02. Search-as-You-Type
//==============================================================
//
// Each keystroke cancels the previous search before starting a new one.
// Small wait (debounce) → don't fire a request for every letter.
//

@MainActor
final class SearchViewModel {

    private var searchTask: Task<Void, Never>?

    private var currentQuery = ""

    private(set) var results: [String] = []

    func search(_ query: String) {

        searchTask?.cancel()                              // drop the old search

        currentQuery = query

        searchTask = Task {
            do {
                try await Task.sleep(for: .milliseconds(300))    // debounce
                let response = try await fakeRequest(query)

                guard query == currentQuery else { return }      // stale check (03)

                results = [response]
                print("Showing:", response)
            } catch {
                print("Cancelled search:", query)
            }
        }
    }
}


//==============================================================
// MARK: - 03. Stale Response Guard
//==============================================================
//
// Cancellation can race with a response that already arrived.
// Before updating the UI, check the result still matches what the
// user asked for (query == currentQuery). Same idea as cell reuse IDs.
//


//==============================================================
// MARK: - 04. Cancel When Leaving the Screen
//==============================================================
//
// SwiftUI → .task { } is cancelled automatically when the view disappears.
// UIKit   → store the Task, cancel it in viewWillDisappear / deinit.
//

@MainActor
final class ProductViewModel {

    private var loadTask: Task<Void, Never>?

    func load() {
        loadTask = Task {
            do {
                let product = try await fakeRequest("Product details", delay: 500)
                print("Loaded:", product)
            } catch {
                print("Load cancelled — user left the screen")
            }
        }
    }

    func screenWillDisappear() {
        loadTask?.cancel()
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - Cancelling a Task ==========")

    await cancelOneRequest()


    print("\n========== 02 - Search-as-You-Type ==========")

    let searchViewModel = SearchViewModel()

    searchViewModel.search("s")

    try? await Task.sleep(for: .milliseconds(100))

    searchViewModel.search("sh")

    try? await Task.sleep(for: .milliseconds(100))

    searchViewModel.search("shoes")

    try? await Task.sleep(for: .milliseconds(700))

    // Cancelled search: s
    // Cancelled search: sh
    // Showing: shoes result


    print("\n========== 04 - Cancel When Leaving ==========")

    let productViewModel = ProductViewModel()

    productViewModel.load()

    try? await Task.sleep(for: .milliseconds(100))

    productViewModel.screenWillDisappear()                 // user tapped Back

    try? await Task.sleep(for: .milliseconds(100))


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 05. Completion-Handler Style
//==============================================================
//
// let task = URLSession.shared.dataTask(with: url) { _, _, error in
//     if (error as? URLError)?.code == .cancelled { return }   // ignore
// }
// task.resume()
// task.cancel()                                                // stop it
//


//==============================================================
// MARK: - 06. Rules
//==============================================================
//
// ✅ Keep a reference to the Task / URLSessionTask so you can cancel it
// ✅ Cancel the previous request before starting a new one (search, filters)
// ✅ Cancel on screen exit (SwiftUI .task does it for you)
// ✅ Treat cancellation as silent — no alert, no retry
// ✅ Still guard against stale results before updating UI
// ❌ Showing "Request cancelled" as an error to the user
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. When should you cancel a network request?
//    → When its result is no longer needed: screen exit, new search, filter change.
//
// 2. How do you cancel an async/await request?
//    → Cancel the Task — URLSession async calls stop and throw.
//
// 3. How do you implement search-as-you-type?
//    → Cancel the previous search Task, debounce, then start the new request.
//
// 4. Why guard against stale responses if you already cancel?
//    → A response can arrive just before cancellation — check it still matches.
//
// 5. Does SwiftUI cancel requests automatically?
//    → Yes, work started in .task is cancelled when the view disappears.
//
// 6. How should the app react to a cancelled request?
//    → Silently — no alert and no retry.
//
//==============================================================
