import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - Network Error Handling
//==============================================================
//
// Three kinds of failure:
// Transport → URLError (offline, timeout, cancelled) — THROWN by URLSession
// HTTP      → 4xx / 5xx status — NOT thrown, you check statusCode
// Decoding  → JSON doesn't match the model — DecodingError
//
// Map all of them into ONE app error → one place to decide
// what the user sees and what to retry.
//
// Runs offline. Open the console: ⇧⌘Y
//


//==============================================================
// MARK: - 01. One App Error
//==============================================================

enum NetworkError: Error, LocalizedError {
    case offline
    case timeout
    case cancelled
    case unauthorized                                      // 401
    case notFound                                          // 404
    case server(Int)                                       // 5xx
    case http(Int)                                         // other status
    case decoding
    case unknown

    // What the USER sees — never show raw technical errors
    var errorDescription: String? {
        switch self {
        case .offline:      return "No internet connection."
        case .timeout:      return "The server took too long. Try again."
        case .cancelled:    return nil
        case .unauthorized: return "Please log in again."
        case .notFound:     return "This item is no longer available."
        case .server:       return "Something went wrong on our side. Try again."
        case .http, .decoding, .unknown:
            return "Something went wrong."
        }
    }

    // Retry only failures that might succeed next time
    var isRetryable: Bool {
        switch self {
        case .offline, .timeout, .server:
            return true
        default:
            return false
        }
    }
}


//==============================================================
// MARK: - 02. Mapping Errors
//==============================================================

func mapStatus(_ code: Int) -> NetworkError? {
    switch code {
    case 200..<300: return nil                              // success
    case 401:       return .unauthorized
    case 404:       return .notFound
    case 500..<600: return .server(code)
    default:        return .http(code)
    }
}

func mapError(_ error: Error) -> NetworkError {
    if let networkError = error as? NetworkError {
        return networkError
    }
    if error is DecodingError {
        return .decoding
    }
    if let urlError = error as? URLError {
        switch urlError.code {
        case .notConnectedToInternet, .networkConnectionLost:
            return .offline
        case .timedOut:
            return .timeout
        case .cancelled:
            return .cancelled
        default:
            return .unknown
        }
    }
    return .unknown
}


//==============================================================
// MARK: - 03. Showing Errors to the User
//==============================================================

func handle(_ error: NetworkError) {
    switch error {
    case .cancelled:
        print("Cancelled → show nothing")                  // user navigated away
    case .unauthorized:
        print("401 → refresh token or log out")            // 05_Authentication
    default:
        if let message = error.errorDescription {
            print("Show alert:", message)
        }
    }
}


//==============================================================
// MARK: - 04. Retry with Exponential Backoff
//==============================================================
//
// Wait longer after each failure: 0.2s → 0.4s → 0.8s
// Retry only retryable errors, with a max attempt count.
//

func withRetry<T>(maxAttempts: Int = 3, operation: () async throws -> T) async throws -> T {
    var attempt = 1
    while true {
        do {
            return try await operation()
        } catch {
            let networkError = mapError(error)
            guard networkError.isRetryable, attempt < maxAttempts else {
                throw networkError
            }
            let delay = 0.2 * Double(1 << (attempt - 1))    // 0.2, 0.4, 0.8
            print("Attempt \(attempt) failed (\(networkError)) — retry in \(delay)s")
            try await Task.sleep(for: .seconds(delay))
            attempt += 1
        }
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 02 - Mapping Errors ==========")

    print("Status 200 →", mapStatus(200) as Any)             // nil
    print("Status 401 →", mapStatus(401) as Any)             // unauthorized
    print("Status 503 →", mapStatus(503) as Any)             // server(503)
    print("Offline    →", mapError(URLError(.notConnectedToInternet)))
    print("Timeout    →", mapError(URLError(.timedOut)))


    print("\n========== 03 - Showing Errors ==========")

    handle(.offline)
    handle(.unauthorized)
    handle(.cancelled)
    handle(.server(500))


    print("\n========== 04a - Retry Succeeds ==========")

    var calls = 0

    do {
        let result = try await withRetry {
            calls += 1
            if calls < 3 {
                throw URLError(.timedOut)                  // fails twice
            }
            return "Products loaded"
        }
        print("✅", result, "after", calls, "attempts")
    } catch {
        print("Failed:", error)
    }


    print("\n========== 04b - No Retry for 404 ==========")

    do {
        let _: String = try await withRetry {
            throw NetworkError.notFound                    // retrying won't help
        }
    } catch {
        handle(mapError(error))                            // Show alert: This item is no longer available.
    }


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 05. Rules
//==============================================================
//
// ✅ Retry: timeout, offline, 5xx (and 429 with Retry-After)
// ❌ Don't retry: 400, 401, 403, 404, decoding errors
// ✅ Cap attempts + exponential backoff → don't hammer a struggling server
// ✅ Cancelled → no alert, no retry
// ✅ 401 → refresh token once, then log out
// ✅ Log the technical error; show a friendly message
// ❌ Showing error.localizedDescription from URLError directly to users
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What kinds of network errors are there?
//    → Transport (URLError), HTTP status (4xx/5xx), and decoding errors.
//
// 2. Does URLSession throw for a 500?
//    → No — only transport errors throw. Map status codes yourself.
//
// 3. Why map everything into one app error type?
//    → One place to decide user messages, retries, and special cases like 401.
//
// 4. Which errors should you retry?
//    → Timeout, offline, and 5xx — not 4xx or decoding errors.
//
// 5. What is exponential backoff?
//    → Waiting longer after each failed retry (0.2s, 0.4s, 0.8s) to avoid overloading the server.
//
// 6. How should a cancelled request be handled?
//    → Silently — no alert and no retry.
//
// 7. What should the user see?
//    → A short friendly message; log the technical details separately.
//
//==============================================================
