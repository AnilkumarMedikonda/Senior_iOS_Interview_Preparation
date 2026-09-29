import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - API Client
//==============================================================
//
// One place for all networking: build request → send → check status → decode.
// ViewModels depend on a PROTOCOL, so the real client can be swapped
// for a mock in tests and previews.
//
// View → ViewModel → APIClient (protocol) → URLSession → Server
//
// Open the console: ⇧⌘Y
//

struct Post: Decodable {
    let id: Int
    let title: String
}


//==============================================================
// MARK: - 01. Endpoint
//==============================================================
//
// Every API call described in ONE enum: path, method, query.
// No URL strings scattered across the app.
//

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Endpoint {
    case post(id: Int)
    case posts(userID: Int)

    var path: String {
        switch self {
        case .post(let id):
            return "/posts/\(id)"
        case .posts:
            return "/posts"
        }
    }

    var method: HTTPMethod {
        .get
    }

    var queryItems: [URLQueryItem] {
        switch self {
        case .post:
            return []
        case .posts(let userID):
            return [URLQueryItem(name: "userId", value: "\(userID)")]
        }
    }

    func makeRequest(baseURL: String) -> URLRequest? {
        var components = URLComponents(string: baseURL + path)
        if !queryItems.isEmpty {
            components?.queryItems = queryItems
        }
        guard let url = components?.url else { return nil }
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Accept")   // common header
        return request
    }
}


//==============================================================
// MARK: - 02. Errors
//==============================================================
//
// Keep the status code — the UI needs it (401 → login, 404 → not found).
// Full error handling → 04_Network_Error_Handling.
//

enum NetworkError: Error {
    case invalidURL
    case badStatus(Int)
    case decoding
}


//==============================================================
// MARK: - 03. Protocol
//==============================================================
//
// One generic method for every endpoint and every model.
//

protocol APIClient: Sendable {
    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}


//==============================================================
// MARK: - 04. Live Client
//==============================================================

struct LiveAPIClient: APIClient {

    let baseURL = "https://jsonplaceholder.typicode.com"

    let session = URLSession.shared

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {

        guard let request = endpoint.makeRequest(baseURL: baseURL) else {
            throw NetworkError.invalidURL
        }

        let (data, response) = try await session.data(for: request)

        if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
            throw NetworkError.badStatus(http.statusCode)
        }

        do {
            return try JSONDecoder().decode(T.self, from: data)
        } catch {
            throw NetworkError.decoding
        }
    }
}


//==============================================================
// MARK: - 05. Mock Client
//==============================================================
//
// Same protocol, no network — returns fixed JSON.
// Used in unit tests and SwiftUI previews.
//

struct MockAPIClient: APIClient {

    let json: String

    func send<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        try JSONDecoder().decode(T.self, from: Data(json.utf8))
    }
}


//==============================================================
// MARK: - 06. ViewModel Uses the Protocol
//==============================================================
//
// Injected client → the ViewModel doesn't know (or care) if it's real or mock.
//

@MainActor
final class PostViewModel {

    private let client: any APIClient

    private(set) var title = ""

    init(client: any APIClient) {
        self.client = client
    }

    func load(id: Int) async {
        do {
            let post: Post = try await client.send(.post(id: id))
            title = post.title
        } catch NetworkError.badStatus(let code) {
            title = "Error \(code)"
        } catch {
            title = "Something went wrong"
        }
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - Endpoint ==========")

    if let request = Endpoint.posts(userID: 1).makeRequest(baseURL: "https://jsonplaceholder.typicode.com") {
        print(request.httpMethod as Any, request.url as Any)   // GET …/posts?userId=1
    }


    print("\n========== 04 - Live Client ==========")

    let liveViewModel = PostViewModel(client: LiveAPIClient())

    await liveViewModel.load(id: 1)

    print("Live:", liveViewModel.title)

    await liveViewModel.load(id: 99999)

    print("Live missing:", liveViewModel.title)               // Error 404


    print("\n========== 05 - Mock Client ==========")

    let mockViewModel = PostViewModel(client: MockAPIClient(json: #"{"id": 7, "title": "Mock title"}"#))

    await mockViewModel.load(id: 7)

    print("Mock:", mockViewModel.title)                        // Mock title — no network


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 07. What Belongs in the Client
//==============================================================
//
// ✅ Base URL, common headers, building requests
// ✅ Status code checks, decoding, mapping errors
// ✅ Auth token injection + refresh (05_Authentication_And_Token_Refresh)
// ❌ UI logic, screen state, business rules → ViewModel / Repository
// ❌ URLSession calls inside ViewControllers
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Why build an API client instead of calling URLSession everywhere?
//    → One place for requests, headers, status checks, decoding, and errors.
//
// 2. Why describe endpoints with an enum?
//    → Every API call is listed in one type — no scattered URL strings, easy to change.
//
// 3. Why a generic send<T: Decodable>?
//    → One method works for every endpoint and every model.
//
// 4. Why hide the client behind a protocol?
//    → Inject a mock in tests and previews without touching the network.
//
// 5. Where should the client sit in the architecture?
//    → Below the ViewModel / Repository; views never talk to it directly.
//
// 6. What should the client's errors contain?
//    → Enough detail to act on — like the HTTP status code.
//
//==============================================================
