import Foundation

//==============================================================
// MARK: - Continuations
//==============================================================
//
// Continuation = bridge from callback-based APIs to async / await.
// Suspend the task, then resume it when the callback fires.
// Rule: resume EXACTLY once.
//


//==============================================================
// MARK: - 01. Legacy Callback APIs
//==============================================================

func legacyFetchUser(completion: @escaping @Sendable (String) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
        completion("Anil")
    }
}

enum NetworkError: Error {
    case failed
}

func legacyFetchOrders(shouldFail: Bool, completion: @escaping @Sendable (Result<[String], Error>) -> Void) {
    DispatchQueue.global().asyncAfter(deadline: .now() + 0.1) {
        completion(shouldFail ? .failure(NetworkError.failed) : .success(["Shoes", "Cap"]))
    }
}


//==============================================================
// MARK: - 02. withCheckedContinuation
//==============================================================
//
// For callbacks that can't fail.
//

func fetchUser() async -> String {
    await withCheckedContinuation { continuation in
        legacyFetchUser { name in
            continuation.resume(returning: name)
        }
    }
}


//==============================================================
// MARK: - 03. withCheckedThrowingContinuation
//==============================================================
//
// For callbacks that return Result or an error.
//

func fetchOrders(shouldFail: Bool) async throws -> [String] {
    try await withCheckedThrowingContinuation { continuation in
        legacyFetchOrders(shouldFail: shouldFail) { result in
            continuation.resume(with: result)        // .success → returns, .failure → throws
        }
    }
}


//==============================================================
// MARK: - 04. Resume Exactly Once
//==============================================================
//
// Never resume     → task hangs forever (checked continuation logs a leak warning)
// Resume twice     → crash (checked) / undefined behavior (unsafe)
// Resume on every path — success, failure, and early returns.
//
// legacyFetchUser { name in
//     continuation.resume(returning: name)
//     continuation.resume(returning: name)    ❌ crash — resumed twice
// }
//
// legacyFetchUser { name in
//     if name.isEmpty { return }              ❌ hang — no resume on this path
//     continuation.resume(returning: name)
// }
//


//==============================================================
// MARK: - 05. Delegate-Based APIs
//==============================================================
//
// Store the continuation, resume it in the delegate callback.
// Clear it after resuming so it can't be resumed twice.
//

@MainActor
final class PermissionRequester {

    private var continuation: CheckedContinuation<Bool, Never>?

    func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
            simulateDelegateCallback()               // e.g. CLLocationManager
        }
    }

    private func simulateDelegateCallback() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.didChangeAuthorization(granted: true)
        }
    }

    private func didChangeAuthorization(granted: Bool) {
        continuation?.resume(returning: granted)
        continuation = nil                           // ✅ prevents double resume
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 02 - withCheckedContinuation ==========")

    print("User:", await fetchUser())               // User: Anil


    print("\n========== 03 - withCheckedThrowingContinuation ==========")

    do {
        print("Orders:", try await fetchOrders(shouldFail: false))   // ["Shoes", "Cap"]
        _ = try await fetchOrders(shouldFail: true)
    } catch {
        print("Error:", error)                      // Error: failed
    }


    print("\n========== 05 - Delegate-Based APIs ==========")

    let requester = PermissionRequester()

    print("Granted:", await requester.requestPermission())   // Granted: true
}


//==============================================================
// MARK: - 06. Checked vs Unsafe
//==============================================================
//
// withCheckedContinuation  → runtime checks for missing / double resume. Use by default.
// withUnsafeContinuation   → no checks, tiny bit faster. Only in hot paths you've verified.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a continuation?
//    → A bridge that suspends an async task until a callback resumes it.
//
// 2. When do you use one?
//    → To wrap completion-handler or delegate APIs in async / await.
//
// 3. What happens if you never resume?
//    → The task hangs forever; checked continuations log a warning.
//
// 4. What happens if you resume twice?
//    → Crash with a checked continuation; undefined behavior with unsafe.
//
// 5. How do you bridge a delegate-based API?
//    → Store the continuation, resume it in the delegate method, then set it to nil.
//
// 6. Checked vs unsafe continuation?
//    → Checked validates resume-once at runtime; unsafe skips checks for speed.
//
//==============================================================
