import Foundation
import CryptoKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - 05_NETWORKING_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Each question:
 1. Question + short spoken answer
 2. Follow-up the interviewer usually asks
 3. A tiny code proof with DEBUG output

 Runs offline. Async proofs run in order in one Task at the bottom.
*/


// ============================================================
// MARK: - Q01. Building a Request
// ============================================================

/*
 Q: How does a basic request work?

 Answer:
 URLRequest → URLSession.data(for:) → check status → decode.

 Follow-up: why URLComponents?
 → Safe percent-encoding of query values.
*/

var components = URLComponents()

components.scheme = "https"

components.host = "api.shop.com"

components.path = "/products"

components.queryItems = [URLQueryItem(name: "q", value: "running shoes")]

if let url = components.url {
    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.setValue("application/json", forHTTPHeaderField: "Accept")
    print("DEBUG Q01 -", request.httpMethod as Any, url)          // ...?q=running%20shoes
}


// ============================================================
// MARK: - Q02. Status Codes Don't Throw
// ============================================================

/*
 Q: Does URLSession throw for 404 / 500?

 Answer:
 No — only transport errors throw. Check statusCode.
*/

enum AppError: Error, Equatable {
    case offline
    case timeout
    case cancelled
    case unauthorized
    case server(Int)
    case client(Int)
    case decoding
}

func mapStatus(_ code: Int) -> AppError? {
    switch code {
    case 200..<300: return nil
    case 401:       return .unauthorized
    case 500..<600: return .server(code)
    default:        return .client(code)
    }
}

print("DEBUG Q02 - 200 →", mapStatus(200) as Any, "| 404 →", mapStatus(404) as Any, "| 503 →", mapStatus(503) as Any)


// ============================================================
// MARK: - Q03. Data vs Download vs Upload
// ============================================================

/*
 Q: Data vs download vs upload tasks?

 Answer:
 Data → memory (API calls)
 Download → temp file (large, background) — move it first!
 Upload → send body / file
*/

print("DEBUG Q03 - download temp file is deleted after the handler returns")


// ============================================================
// MARK: - Q04. Codable Key Mapping
// ============================================================

/*
 Q: Keys that don't match your model?

 Answer:
 .convertFromSnakeCase or CodingKeys. Missing required key →
 whole decode fails.
*/

struct Product: Decodable {
    let productID: Int
    let displayName: String

    enum CodingKeys: String, CodingKey {
        case productID = "product_id"
        case displayName = "name"
    }
}

let goodJSON = Data(#"{"product_id": 42, "name": "Running Shoes"}"#.utf8)

if let product = try? JSONDecoder().decode(Product.self, from: goodJSON) {
    print("DEBUG Q04 -", product.productID, product.displayName)
}


// ============================================================
// MARK: - Q05. Debugging Decoding Errors
// ============================================================

/*
 Q: How do you debug a decoding failure?

 Answer:
 Catch DecodingError — it names the key / path.
*/

let badJSON = Data(#"{"product_id": "forty-two"}"#.utf8)

do {
    _ = try JSONDecoder().decode(Product.self, from: badJSON)
} catch DecodingError.typeMismatch(_, let context) {
    print("DEBUG Q05 - type mismatch at:", context.codingPath.map(\.stringValue))
} catch DecodingError.keyNotFound(let key, _) {
    print("DEBUG Q05 - missing key:", key.stringValue)
} catch {
    print("DEBUG Q05 - other:", error)
}


// ============================================================
// MARK: - Q06–Q07. API Client + Mock
// ============================================================

/*
 Q6: Design a reusable API client?
 Answer: Endpoint enum + generic send<T> + status check +
         error mapping, behind a protocol.

 Q7: How do you test it?
 Answer: Inject a mock client (or URLProtocol stub).
*/

enum Endpoint {
    case product(id: Int)

    var path: String {
        switch self {
        case .product(let id):
            return "/products/\(id)"
        }
    }
}

protocol APIClient: Sendable {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}

struct MockAPIClient: APIClient {

    let json: String

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }
}


// ============================================================
// MARK: - Q08. Mapping Transport Errors
// ============================================================

/*
 Q: Kinds of network errors?

 Answer:
 Transport (URLError), HTTP status, decoding → one AppError.
 Cancelled → silent.
*/

func mapError(_ error: Error) -> AppError {
    if let urlError = error as? URLError {
        switch urlError.code {
        case .notConnectedToInternet: return .offline
        case .timedOut:               return .timeout
        case .cancelled:              return .cancelled
        default:                      return .server(0)
        }
    }
    if error is DecodingError {
        return .decoding
    }
    return .server(0)
}

print("DEBUG Q08 - offline →", mapError(URLError(.notConnectedToInternet)), "| timeout →", mapError(URLError(.timedOut)))


// ============================================================
// MARK: - Q09. Retry with Backoff
// ============================================================

/*
 Q: How do you design retry logic?

 Answer:
 Retry only timeout / offline / 5xx, cap attempts,
 exponential backoff. Never 4xx or decoding.
*/

func isRetryable(_ error: AppError) -> Bool {
    switch error {
    case .offline, .timeout, .server:
        return true
    default:
        return false
    }
}

func retrying<T>(maxAttempts: Int = 3, _ operation: () async throws -> T) async throws -> T {
    var attempt = 1
    while true {
        do {
            return try await operation()
        } catch {
            let appError = mapError(error)
            guard isRetryable(appError), attempt < maxAttempts else { throw appError }
            let delay = 0.05 * Double(1 << (attempt - 1))           // 0.05, 0.1, 0.2 (demo)
            print("DEBUG Q09 - attempt \(attempt) failed (\(appError)) → retry in \(delay)s")
            try await Task.sleep(for: .seconds(delay))
            attempt += 1
        }
    }
}


// ============================================================
// MARK: - Q10–Q12. Tokens + Single In-Flight Refresh
// ============================================================

/*
 Q10: Where to store tokens?   → Keychain.
 Q11: Token expired?           → 401 → refresh once → retry once.
 Q12: Five 401s at once?       → ONE refresh; others await it.
*/

actor TokenManager {

    private var refreshTask: Task<String, Never>?

    private(set) var refreshCount = 0

    func validToken() async -> String {
        if let refreshTask {
            return await refreshTask.value                   // join the refresh in progress
        }
        refreshCount += 1
        let task = Task {
            try? await Task.sleep(for: .milliseconds(100))   // fake refresh call
            return "token-v2"
        }
        refreshTask = task
        let token = await task.value
        refreshTask = nil
        return token
    }
}


// ============================================================
// MARK: - Q13. Cancellation
// ============================================================

/*
 Q: How do you cancel requests?

 Answer:
 Cancel the Task; URLSession / Task.sleep throw.
 Still guard against stale results.
*/

func slowRequest() async throws -> String {
    try await Task.sleep(for: .seconds(1))
    return "data"
}


// ============================================================
// MARK: - Q14. Parallel Requests
// ============================================================

/*
 Q: Load several APIs in parallel?

 Answer:
 async let (fixed) / TaskGroup (dynamic); catch per child.
*/

func fakeAPI(_ name: String) async -> String {
    try? await Task.sleep(for: .milliseconds(100))
    return name
}


// ============================================================
// MARK: - Q15–Q16. Caching
// ============================================================

/*
 Q15: URLCache vs own cache?
 Answer: URLCache follows server headers; own cache = your rules.

 Q16: Image cache for lists?
 Answer: NSCache (memory) → Caches folder (disk) → network,
         downsampled, decoded off main.
*/

let imageCache = NSCache<NSString, NSString>()

imageCache.setObject("decoded-image-42", forKey: "img-42")

print("DEBUG Q16 - hit:", imageCache.object(forKey: "img-42") != nil, "| miss:", imageCache.object(forKey: "img-99") == nil)


// ============================================================
// MARK: - Q17. SSL Pinning
// ============================================================

/*
 Q: SSL pinning + trade-offs?

 Answer:
 Trust only your server's key hash. Risk: rotation → pin a
 backup key + remote kill switch.
*/

func keyHash(_ keyData: Data) -> String {
    Data(SHA256.hash(data: keyData)).base64EncodedString()
}

let serverKey = Data("server-public-key".utf8)

let pinnedHashes: Set<String> = [keyHash(serverKey), "BACKUP-KEY-HASH="]

let attackerKey = Data("attacker-public-key".utf8)

print("DEBUG Q17 - server allowed:", pinnedHashes.contains(keyHash(serverKey)))     // true

print("DEBUG Q17 - attacker allowed:", pinnedHashes.contains(keyHash(attackerKey))) // false


// ============================================================
// MARK: - Q18. ATS
// ============================================================

/*
 Q: What does ATS do?

 Answer:
 HTTPS + modern TLS by default; HTTP needs an Info.plist exception.
*/

print("DEBUG Q18 - http:// blocked by default (ATS)")


// ============================================================
// MARK: - Run Async Proofs
// ============================================================

Task { @MainActor in

    // Q06–Q07 — mock client
    let client: APIClient = MockAPIClient(json: #"{"product_id": 7, "name": "Cap"}"#)

    if let product: Product = try? await client.send(.product(id: 7)) {
        print("DEBUG Q07 - mock client:", product.displayName)
    }

    // Q09 — retry: fails twice with timeout, then succeeds
    var calls = 0

    let result = try? await retrying {
        calls += 1
        if calls < 3 {
            throw URLError(.timedOut)
        }
        return "Products"
    }

    print("DEBUG Q09 -", result as Any, "after", calls, "attempts")

    // Q12 — five 401s at once → one refresh
    let tokens = TokenManager()

    await withTaskGroup(of: String.self) { group in
        for _ in 0..<5 {
            group.addTask { await tokens.validToken() }
        }
    }

    print("DEBUG Q12 - refresh calls for 5 requests:", await tokens.refreshCount)    // 1

    // Q13 — cancellation
    let request = Task { try await slowRequest() }

    request.cancel()

    do {
        _ = try await request.value
    } catch is CancellationError {
        print("DEBUG Q13 - cancelled → show nothing")
    } catch {
        print("DEBUG Q13 - error:", error)
    }

    // Q14 — parallel
    let clock = ContinuousClock()

    let elapsed = await clock.measure {
        async let user = fakeAPI("user")
        async let orders = fakeAPI("orders")
        async let banner = fakeAPI("banner")
        _ = await (user, orders, banner)
    }

    print("DEBUG Q14 - 3 × 100 ms in parallel took:", elapsed)

    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Endpoint → APIClient (protocol) → URLSession
                  │
                  ├── status check (404/500 don't throw)
                  ├── decode (DecodingError tells you why)
                  ├── map errors → AppError
                  ├── auth: 401 → ONE refresh (actor) → retry once
                  └── retry: only safe errors + backoff

   Cancel what the user no longer needs.
   Cache: memory → disk → network.
   Security: HTTPS (ATS) + pinning with a backup key.


 Senior One-Liner:

 "I build one protocol-based API client that checks status
  codes, maps errors, injects auth with a single in-flight
  token refresh, retries only safe errors with backoff, and
  cancels work the user no longer needs."
*/
