import Foundation

//==============================================================
// MARK: - Error Handling
//==============================================================

//==============================================================
// MARK: - 01. Custom Errors + LocalizedError
//==============================================================
// Error → any type can be thrown. LocalizedError → user-facing message.

enum NetworkError: Error, LocalizedError {
    case invalidURL
    case unauthorized
    case server(code: Int)

    var errorDescription: String? {
        switch self {
        case .invalidURL: return "The link is invalid."
        case .unauthorized: return "Please log in again."
        case .server(let code): return "Server error (\(code))."
        }
    }
}

print("\n========== 01 - Custom Errors + LocalizedError ==========")
print(NetworkError.server(code: 500).localizedDescription) // Server error (500).

//==============================================================
// MARK: - 02. throws + do-catch
//==============================================================
// Catch specific cases first, general catch last.

func fetchData(code: Int) throws -> String {
    if code == 401 { throw NetworkError.unauthorized }
    if code >= 500 { throw NetworkError.server(code: code) }
    return "Data"
}

print("\n========== 02 - throws + do-catch ==========")
do {
    let data = try fetchData(code: 503)
    print(data)
} catch NetworkError.unauthorized {
    print("Unauthorized")
} catch NetworkError.server(let code) where code >= 500 {
    print("Server down:", code) // Server down: 503
} catch {
    print("Other:", error)
}

//==============================================================
// MARK: - 03. try / try? / try!
//==============================================================
// try  → propagate or catch
// try? → error becomes nil, details lost
// try! → crash if an error is thrown

print("\n========== 03 - try / try? / try! ==========")
print((try? fetchData(code: 200)) as Any) // Optional("Data")
print((try? fetchData(code: 500)) as Any) // nil
// let crash = try! fetchData(code: 500)   ❌ runtime crash

//==============================================================
// MARK: - 04. Result
//==============================================================
// Result<Success, Failure> — stores success or failure as a value.
// Common in completion handlers. get() converts back to throws.

func fetchUser(id: Int) -> Result<String, NetworkError> {
    id > 0 ? .success("Anil") : .failure(.invalidURL)
}

print("\n========== 04 - Result ==========")
switch fetchUser(id: 0) {
case .success(let user):
    print("User:", user)
case .failure(let error):
    print("Failed:", error.localizedDescription) // Failed: The link is invalid.
}

do {
    let user = try fetchUser(id: 1).get()
    print("get():", user) // get(): Anil
} catch {
    print(error)
}

//==============================================================
// MARK: - 05. rethrows
//==============================================================
// Throws only if the closure throws.

func execute(_ action: () throws -> Void) rethrows {
    try action()
}

print("\n========== 05 - rethrows ==========")
execute { print("No try needed") }   // ✅ non-throwing closure
do {
    try execute { throw NetworkError.unauthorized }   // try required
} catch {
    print("Caught:", error)          // Caught: unauthorized
}

//==============================================================
// MARK: - 06. defer
//==============================================================
// Runs when the scope exits — success or error. Multiple defers run LIFO.

func process() throws {
    defer { print("Cleanup 1") }
    defer { print("Cleanup 2") }
    print("Processing")
    throw NetworkError.unauthorized
}

print("\n========== 06 - defer ==========")
do {
    try process()
} catch {
    print("Process failed")
}
// Processing | Cleanup 2 | Cleanup 1 | Process failed

//==============================================================
// MARK: - 07. Error Transformation
//==============================================================
// Map low-level errors to domain errors for the layer above.

enum UserError: Error {
    case unavailable
}

func loadUser() throws {
    do {
        _ = try fetchData(code: 500)
    } catch {
        throw UserError.unavailable
    }
}

print("\n========== 07 - Error Transformation ==========")
do {
    try loadUser()
} catch UserError.unavailable {
    print("User unavailable") // User unavailable
} catch {
    print("Unknown")
}

//==============================================================
// MARK: - 08. Typed Throws (Swift 6)
//==============================================================
// throws(ErrorType) → catch knows the exact type, no casting.

enum ValidationError: Error {
    case tooYoung
}

func validate(age: Int) throws(ValidationError) {
    if age < 18 { throw .tooYoung }
}

print("\n========== 08 - Typed Throws ==========")
do {
    try validate(age: 15)
} catch {
    print(error == .tooYoung) // true — error is ValidationError, not any Error
}

//==============================================================
// MARK: - 09. async throws
//==============================================================

func fetchUserAsync() async throws -> String {
    "Anil"
}

print("\n========== 09 - async throws ==========")
Task {
    do {
        print("Async user:", try await fetchUserAsync()) // prints last
    } catch {
        print("Async error:", error)
    }
}

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. throws vs Result — when do you use each?
// 2. try vs try? vs try! ?
// 3. How do you catch a specific error case?
// 4. What is rethrows?
// 5. When does defer run? Order of multiple defers?
// 6. Why transform errors between layers?
// 7. What do typed throws add?
// 8. How do you show a user-friendly error message?
//
//==============================================================
