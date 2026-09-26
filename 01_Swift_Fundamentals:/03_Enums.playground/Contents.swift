import Foundation

//==============================================================
// MARK: - 03. Enums
//==============================================================
// Value type representing a fixed set of related cases.

//==============================================================
// MARK: - 1. Exhaustive Switch
//==============================================================
// No default needed — adding a case breaks every switch until handled.

enum Direction {
    case north, south, east, west
}

print("\n========== 01 - Exhaustive Switch ==========")
let direction = Direction.north
switch direction {
case .north: print("North")   // ✅
case .south: print("South")
case .east: print("East")
case .west: print("West")
}

//==============================================================
// MARK: - 2. Associated Values
//==============================================================
// Runtime data per case — each case can carry different types.

enum LoginState {
    case idle
    case success(userID: String)
    case failure(message: String)
}

print("\n========== 02 - Associated Values ==========")
let loginState = LoginState.success(userID: "USER_123")
switch loginState {
case .idle: print("Idle")
case .success(let userID): print("Logged in:", userID)   // ✅
case .failure(let message): print("Failed:", message)
}

//==============================================================
// MARK: - 3. Raw Values
//==============================================================
// Compile-time constant per case. init(rawValue:) is failable.
// Raw values OR associated values — not both.

enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
}

enum Priority: Int {
    case low = 1, medium, high   // 1, 2, 3 — auto-increment
}

print("\n========== 03 - Raw Values ==========")
print(HTTPMethod.get.rawValue)                   // GET
print(Priority.high.rawValue)                    // 3
print(HTTPMethod(rawValue: "POST") as Any)       // Optional(post)
print(HTTPMethod(rawValue: "PATCH") as Any)      // nil

//==============================================================
// MARK: - 4. CaseIterable
//==============================================================
// allCases in declaration order. ❌ Not synthesized with associated values.

enum SortOption: String, CaseIterable {
    case relevance = "Relevance"
    case newest = "Newest"
}

print("\n========== 04 - CaseIterable ==========")
for option in SortOption.allCases {
    print(option.rawValue)   // Relevance, Newest
}

//==============================================================
// MARK: - 5. if case, guard case, where
//==============================================================

enum NetworkResult {
    case success(statusCode: Int)
    case failure(statusCode: Int)
}

func handle(_ result: NetworkResult) {
    switch result {
    case .success(let code): print("Success:", code)
    case .failure(let code) where code == 401: print("Refresh token")
    case .failure(let code) where code >= 500: print("Retry:", code)
    case .failure(let code): print("Client error:", code)
    }
}

func process(_ state: LoginState) {
    guard case let .success(userID) = state else { return print("Not logged in") }
    print("Processing:", userID)
}

print("\n========== 05 - if case, guard case, where ==========")
if case let .success(userID) = loginState {
    print("if case:", userID)          // USER_123
}
process(.idle)                         // Not logged in
handle(.failure(statusCode: 401))      // Refresh token
handle(.failure(statusCode: 503))      // Retry: 503

//==============================================================
// MARK: - 6. Properties and Methods
//==============================================================
// ✅ Computed, static, methods  ❌ Stored instance properties
// Changing self requires mutating.

enum TrafficLight: CustomStringConvertible {
    case red, green, yellow

    var description: String {
        switch self {
        case .red: return "Stop"
        case .green: return "Go"
        case .yellow: return "Slow"
        }
    }

    mutating func next() {
        switch self {
        case .red: self = .green
        case .green: self = .yellow
        case .yellow: self = .red
        }
    }
}

print("\n========== 06 - Properties and Methods ==========")
var light = TrafficLight.red
print(light)   // Stop
light.next()
print(light)   // Go

//==============================================================
// MARK: - 7. Equatable
//==============================================================
// No associated values → free. With them → synthesized only if all are Equatable.

enum APIResult: Equatable {
    case success(Int)
    case failure(String)
}

print("\n========== 07 - Equatable ==========")
print(APIResult.success(200) == .success(200))   // true
print(APIResult.success(200) == .success(404))   // false

//==============================================================
// MARK: - 8. Codable with Unknown Fallback
//==============================================================
// Trap: one unknown backend value fails the WHOLE decode.

enum OrderStatus: String, Decodable {
    case pending, shipped, unknown

    init(from decoder: Decoder) throws {
        let rawValue = try decoder.singleValueContainer().decode(String.self)
        if let status = OrderStatus(rawValue: rawValue) {
            self = status
        } else {
            self = .unknown
        }
    }
}

struct Order: Decodable {
    let id: Int
    let status: OrderStatus
}

print("\n========== 08 - Codable with Unknown Fallback ==========")
let json = Data(#"[{"id": 1, "status": "shipped"}, {"id": 2, "status": "returned"}]"#.utf8)
do {
    for order in try JSONDecoder().decode([Order].self, from: json) {
        print(order.id, order.status)   // 1 shipped | 2 unknown
    }
} catch {
    print(error)
}

//==============================================================
// MARK: - 9. @unknown default
//==============================================================
// For Apple framework enums that may gain cases in future OS versions.
// Handles new cases at runtime AND warns at compile time. Plain default hides them.
//
// switch settings.authorizationStatus {
// case .authorized, .provisional, .ephemeral: ...
// case .denied, .notDetermined: ...
// @unknown default: ...
// }

//==============================================================
// MARK: - 10. indirect
//==============================================================
// Recursive cases, boxed on the heap.

indirect enum Expression {
    case number(Int)
    case addition(Expression, Expression)
    case multiplication(Expression, Expression)
}

func evaluate(_ expression: Expression) -> Int {
    switch expression {
    case .number(let value): return value
    case .addition(let left, let right): return evaluate(left) + evaluate(right)
    case .multiplication(let left, let right): return evaluate(left) * evaluate(right)
    }
}

print("\n========== 10 - indirect ==========")
let expression = Expression.addition(.number(10), .multiplication(.number(2), .number(5)))
print(evaluate(expression))   // 20

//==============================================================
// MARK: - 11. Caseless Enum as Namespace
//==============================================================
// Cannot be instantiated — unlike a struct.

enum APIConstants {
    static let baseURL = "https://api.example.com"
}

print("\n========== 11 - Caseless Enum as Namespace ==========")
print(APIConstants.baseURL)
// let constants = APIConstants()   ❌

//==============================================================
// MARK: - 12. Enum vs Boolean Flags
//==============================================================
// Flags allow impossible states (loading + data + error at once).
// Enum = exactly one state → "make invalid states unrepresentable".

// ❌ struct State { var isLoading: Bool; var products: [String]?; var error: String? }

enum ScreenState {
    case loading
    case loaded([String])
    case empty
    case error(String)
}

func render(_ state: ScreenState) {
    switch state {
    case .loading: print("Spinner")
    case .loaded(let products): print("Products:", products.count)
    case .empty: print("Empty view")
    case .error(let message): print("Error:", message)
    }
}

print("\n========== 12 - Enum vs Boolean Flags ==========")
render(.loading)                    // Spinner
render(.loaded(["Shoes", "Cap"]))   // Products: 2
render(.error("Timeout"))           // Error: Timeout

//==============================================================
// MARK: - Interview Questions
//==============================================================
// 1. Raw values vs associated values?
// 2. Why is init(rawValue:) failable?
// 3. Why can't enums with associated values be CaseIterable automatically?
// 4. if case vs guard case? Does case order matter with where?
// 5. Can enums have stored properties? Why mutating?
// 6. When is == synthesized for associated values?
// 7. How do you stop an unknown API value from failing the decode?
// 8. @unknown default vs default?
// 9. What is indirect, and what does it cost?
// 10. Why a caseless enum for constants?
// 11. Why an enum over Boolean flags for screen state?
//==============================================================
