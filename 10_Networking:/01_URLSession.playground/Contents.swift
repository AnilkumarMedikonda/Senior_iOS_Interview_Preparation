import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


// MARK: - 01. Basic GET Request
// NOTE:
// Use dataTask for normal API calls where the response is returned as Data.

func basicGETRequest() {
    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    URLSession.shared.dataTask(with: url) { data, response, error in

        if let error {
            print("DEBUG: GET Error:", error.localizedDescription)
            return
        }

        guard let response = response as? HTTPURLResponse else {
            print("DEBUG: Invalid Response")
            return
        }

        guard (200...299).contains(response.statusCode) else {
            print("DEBUG: HTTP Error:", response.statusCode)
            return
        }

        guard let data else {
            print("DEBUG: No Data")
            return
        }

        print("DEBUG: Status:", response.statusCode)
        print("DEBUG: Response:", String(data: data, encoding: .utf8) ?? "")
    }.resume()
}


// MARK: - 02. URLRequest
// NOTE:
// Use URLRequest when you need to configure method, headers, timeout, body, or cache policy.

func urlRequestExample() {
    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"
    request.timeoutInterval = 30

    request.setValue(
        "application/json",
        forHTTPHeaderField: "Accept"
    )

    URLSession.shared.dataTask(with: request) { _, response, error in

        if let error {
            print("DEBUG: Error:", error.localizedDescription)
            return
        }

        guard let response = response as? HTTPURLResponse else {
            return
        }

        print("DEBUG: Status:", response.statusCode)
    }.resume()
}


// MARK: - 03. Query Parameters
// NOTE:
// Use URLComponents and URLQueryItem to safely build query parameters.

func queryParametersExample() {
    guard var components = URLComponents(
        string: "https://jsonplaceholder.typicode.com/posts"
    ) else {
        return
    }

    components.queryItems = [
        URLQueryItem(name: "userId", value: "1"),
        URLQueryItem(name: "page", value: "2")
    ]

    guard let url = components.url else {
        return
    }

    print("DEBUG: URL:", url)

    URLSession.shared.dataTask(with: url) { _, _, _ in
        print("DEBUG: Request Completed")
    }.resume()
}


// MARK: - 04. POST Request
// NOTE:
// Use POST when sending data to the server.
// JSON APIs commonly use Content-Type: application/json.

func postRequest() {
    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts"
    ) else {
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    request.setValue(
        "application/json",
        forHTTPHeaderField: "Content-Type"
    )

    let body: [String: Any] = [
        "title": "iOS",
        "body": "URLSession",
        "userId": 1
    ]

    guard let bodyData = try? JSONSerialization.data(
        withJSONObject: body
    ) else {
        return
    }

    request.httpBody = bodyData

    URLSession.shared.dataTask(with: request) { _, response, error in

        if let error {
            print("DEBUG: POST Error:", error.localizedDescription)
            return
        }

        guard let response = response as? HTTPURLResponse else {
            return
        }

        print("DEBUG: POST Status:", response.statusCode)
    }.resume()
}


// MARK: - 05. Custom URLSession Configuration
// NOTE:
// Use custom configuration when you need control over timeout,
// caching, connectivity, or other session-level behavior.

func customSessionExample() {

    let configuration = URLSessionConfiguration.default

    configuration.timeoutIntervalForRequest = 30
    configuration.timeoutIntervalForResource = 60
    configuration.waitsForConnectivity = true

    let session = URLSession(configuration: configuration)

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    session.dataTask(with: url) { _, _, _ in
        print("DEBUG: Custom Session Completed")
    }.resume()
}


// MARK: - 06. Ephemeral Session
// NOTE:
// Use an ephemeral session when you don't want normal persistent
// cache, cookies, or credential storage.

func ephemeralSessionExample() {

    let configuration = URLSessionConfiguration.ephemeral
    let session = URLSession(configuration: configuration)

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    session.dataTask(with: url) { _, _, _ in
        print("DEBUG: Ephemeral Session Completed")
    }.resume()
}


// MARK: - 07. HTTP Status Handling
// NOTE:
// HTTP errors such as 401, 404, and 500 must be handled separately
// from transport/network errors.

func statusCodeHandling() {

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    URLSession.shared.dataTask(with: url) { _, response, error in

        if let error {
            print("DEBUG: Transport Error:", error.localizedDescription)
            return
        }

        guard let response = response as? HTTPURLResponse else {
            return
        }

        switch response.statusCode {

        case 200...299:
            print("DEBUG: Success")

        case 400...499:
            print("DEBUG: Client Error:", response.statusCode)

        case 500...599:
            print("DEBUG: Server Error:", response.statusCode)

        default:
            print("DEBUG: Unknown Status:", response.statusCode)
        }

    }.resume()
}


// MARK: - 08. Request Cancellation
// NOTE:
// Use cancel() when a request is no longer needed.
// Common for search, filters, pagination, and screen dismissal.

func cancellationExample() {

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts"
    ) else {
        return
    }

    let task = URLSession.shared.dataTask(with: url) { _, _, error in

        if let error {
            print("DEBUG: Request:", error.localizedDescription)
            return
        }

        print("DEBUG: Request Completed")
    }

    task.resume()
    task.cancel()

    print("DEBUG: Request Cancelled")
}


// MARK: - 09. Download Task
// NOTE:
// Use downloadTask for larger files because the response is written
// to a temporary file instead of being kept entirely in memory.

func downloadExample() {

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/photos/1"
    ) else {
        return
    }

    URLSession.shared.downloadTask(with: url) { location, _, error in

        if let error {
            print("DEBUG: Download Error:", error.localizedDescription)
            return
        }

        guard let location else {
            return
        }

        print("DEBUG: Temporary File:", location.path)
    }.resume()
}


// MARK: - 10. Upload Task
// NOTE:
// Use uploadTask when uploading data or files to a server.

func uploadExample() {

    guard let url = URL(
        string: "https://httpbin.org/post"
    ) else {
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "POST"

    request.setValue(
        "application/json",
        forHTTPHeaderField: "Content-Type"
    )

    let json = """
    {
        "name": "Anil",
        "platform": "iOS"
    }
    """

    guard let data = json.data(using: .utf8) else {
        return
    }

    URLSession.shared.uploadTask(
        with: request,
        from: data
    ) { _, _, error in

        if let error {
            print("DEBUG: Upload Error:", error.localizedDescription)
            return
        }

        print("DEBUG: Upload Completed")
    }.resume()
}


// MARK: - 11. Authorization Header
// NOTE:
// Use Authorization to send credentials such as a Bearer access token.

func authorizationExample() {

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    var request = URLRequest(url: url)

    let token = "ACCESS_TOKEN"

    request.setValue(
        "Bearer \(token)",
        forHTTPHeaderField: "Authorization"
    )

    URLSession.shared.dataTask(with: request) { _, _, _ in
        print("DEBUG: Auth Request Completed")
    }.resume()
}


// MARK: - 12. Cache Policy
// NOTE:
// Use cachePolicy to control how URLSession uses cached responses.
// The correct policy depends on the API's freshness requirements.

func cachePolicyExample() {

    let configuration = URLSessionConfiguration.default

    configuration.requestCachePolicy = .useProtocolCachePolicy

    let session = URLSession(configuration: configuration)

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    session.dataTask(with: url) { _, _, _ in
        print("DEBUG: Cache Request Completed")
    }.resume()
}


// MARK: - 13. Reusable Request Handler
// NOTE:
// Centralize common URLSession handling so every API request
// doesn't repeat error, status-code, and data validation.

func performRequest(
    _ request: URLRequest,
    completion: @escaping (Result<Data, Error>) -> Void
) {

    URLSession.shared.dataTask(with: request) { data, response, error in

        if let error {
            completion(.failure(error))
            return
        }

        guard let response = response as? HTTPURLResponse else {
            completion(.failure(URLError(.badServerResponse)))
            return
        }

        guard (200...299).contains(response.statusCode) else {
            completion(.failure(URLError(.badServerResponse)))
            return
        }

        guard let data else {
            completion(.failure(URLError(.zeroByteResource)))
            return
        }

        completion(.success(data))

    }.resume()
}


// MARK: - 14. Reusable Request Usage
// NOTE:
// This is the starting point for a centralized API Client.
// The dedicated API Client architecture comes in 03_API_Client.

func reusableRequestExample() {

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    var request = URLRequest(url: url)
    request.httpMethod = "GET"

    performRequest(request) { result in

        switch result {

        case .success(let data):
            print(
                "DEBUG: Response:",
                String(data: data, encoding: .utf8) ?? ""
            )

        case .failure(let error):
            print("DEBUG: Error:", error.localizedDescription)
        }
    }
}


// MARK: - 15. URLSession Delegate
// NOTE:
// Use URLSessionDelegate for advanced networking such as
// authentication challenges, SSL pinning, and session lifecycle events.

final class NetworkDelegate: NSObject, URLSessionDelegate {

    func urlSession(
        _ session: URLSession,
        didBecomeInvalidWithError error: Error?
    ) {
        print(
            "DEBUG: Session Invalid:",
            error?.localizedDescription ?? "No Error"
        )
    }
}

func delegateSessionExample() {

    let delegate = NetworkDelegate()

    let configuration = URLSessionConfiguration.default

    let session = URLSession(
        configuration: configuration,
        delegate: delegate,
        delegateQueue: nil
    )

    guard let url = URL(
        string: "https://jsonplaceholder.typicode.com/posts/1"
    ) else {
        return
    }

    session.dataTask(with: url) { _, _, _ in
        print("DEBUG: Delegate Session Completed")
    }.resume()

    session.finishTasksAndInvalidate()
}


// MARK: - 16. Background Session
// NOTE:
// Use background URLSession for long-running uploads/downloads
// that can continue while the app isn't actively running.

func backgroundSessionExample() {

    let configuration = URLSessionConfiguration.background(
        withIdentifier: "com.example.background"
    )

    let session = URLSession(configuration: configuration)

    print("DEBUG: Background Session Created:", session)
}


// MARK: - Run

let examples: [(String, () -> Void)] = [
    ("01 - Basic GET", basicGETRequest),
    ("02 - URLRequest", urlRequestExample),
    ("03 - Query Parameters", queryParametersExample),
    ("04 - POST Request", postRequest),
    ("05 - Custom Session", customSessionExample),
    ("06 - Ephemeral Session", ephemeralSessionExample),
    ("07 - Status Handling", statusCodeHandling),
    ("08 - Cancellation", cancellationExample),
    ("09 - Download Task", downloadExample),
    ("10 - Upload Task", uploadExample),
    ("11 - Authorization Header", authorizationExample),
    ("12 - Cache Policy", cachePolicyExample),
    ("14 - Reusable Request", reusableRequestExample),
    ("15 - Delegate Session", delegateSessionExample),
    ("16 - Background Session", backgroundSessionExample)
]

for (index, example) in examples.enumerated() {
    DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 1.5) {
        print("\n========== \(example.0) ==========")
        example.1()
    }
}
