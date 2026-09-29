import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - Authentication & Token Refresh
//==============================================================
//
// Access token  → short-lived (minutes), sent on every request
// Refresh token → long-lived (days), used ONLY to get a new access token
//
// Flow: request → 401 → refresh token → retry the request ONCE
// Senior part: many requests hit 401 together → refresh only ONCE.
//
// Runs offline with a fake server. Open the console: ⇧⌘Y
//


//==============================================================
// MARK: - 01. Where Tokens Live
//==============================================================
//
// ✅ Keychain — encrypted, survives app restarts
// ❌ UserDefaults — plain text, readable in backups
// ✅ Keep the access token in memory while the app runs
//


//==============================================================
// MARK: - 02. Fake Server
//==============================================================

enum AuthError: Error {
    case unauthorized                                      // 401
    case refreshFailed                                     // refresh token expired
}

struct FakeServer {

    let currentValidToken = "token-v2"

    let acceptedRefreshToken: String

    func fetch(_ path: String, token: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(50))
        guard token == currentValidToken else {
            throw AuthError.unauthorized
        }
        return "\(path) data"
    }

    func refresh(using refreshToken: String) async throws -> String {
        try await Task.sleep(for: .milliseconds(200))
        guard refreshToken == acceptedRefreshToken else {
            throw AuthError.refreshFailed
        }
        return currentValidToken
    }
}


//==============================================================
// MARK: - 03. AuthManager — Refresh Only Once
//==============================================================
//
// An actor protects the token.
// While a refresh is running, other callers WAIT for the same Task
// instead of starting their own (same fix as 11_Actors reentrancy).
//

actor AuthManager {

    private var accessToken = "token-v1"                   // already expired

    private let refreshToken: String

    private var refreshTask: Task<String, Error>?

    private let server: FakeServer

    init(server: FakeServer, refreshToken: String) {
        self.server = server
        self.refreshToken = refreshToken
    }

    func currentToken() -> String {
        accessToken
    }

    func refreshAccessToken() async throws -> String {

        if let refreshTask {
            return try await refreshTask.value             // join the refresh in progress
        }

        let task = Task {
            print("🔄 Refreshing token…")
            return try await server.refresh(using: refreshToken)
        }

        refreshTask = task

        defer { refreshTask = nil }

        let newToken = try await task.value

        accessToken = newToken

        return newToken
    }
}


//==============================================================
// MARK: - 04. Client — Retry Once After 401
//==============================================================

struct AuthorizedClient {

    let auth: AuthManager

    let server: FakeServer

    func get(_ path: String) async throws -> String {

        let token = await auth.currentToken()

        do {
            return try await server.fetch(path, token: token)
        } catch AuthError.unauthorized {
            print("401 on \(path) → refresh")
            let newToken = try await auth.refreshAccessToken()
            return try await server.fetch(path, token: newToken)   // retry ONCE — no loop
        }
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 04 - Single Request ==========")

    let server = FakeServer(acceptedRefreshToken: "refresh-ok")

    let client = AuthorizedClient(auth: AuthManager(server: server, refreshToken: "refresh-ok"), server: server)

    print("✅", try await client.get("/profile"))


    print("\n========== 03 - Three Requests at Once ==========")

    let sharedClient = AuthorizedClient(auth: AuthManager(server: server, refreshToken: "refresh-ok"), server: server)

    async let profile = sharedClient.get("/profile")
    async let orders = sharedClient.get("/orders")
    async let cart = sharedClient.get("/cart")

    let results = try await [profile, orders, cart]

    print("✅", results)

    // 3 × "401 → refresh", but "🔄 Refreshing token…" prints only ONCE


    print("\n========== 05 - Refresh Token Expired ==========")

    let expiredServer = FakeServer(acceptedRefreshToken: "refresh-ok")

    let expiredClient = AuthorizedClient(auth: AuthManager(server: expiredServer, refreshToken: "refresh-OLD"), server: expiredServer)

    do {
        _ = try await expiredClient.get("/profile")
    } catch AuthError.refreshFailed {
        print("Refresh failed → clear Keychain, show login screen")
    }


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 06. Rules
//==============================================================
//
// ✅ Attach "Authorization: Bearer <token>" in ONE place (the API client)
// ✅ On 401: refresh once, retry the original request once
// ✅ Concurrent 401s share ONE refresh (actor + in-flight Task)
// ✅ Refresh fails → log out, clear tokens, show login
// ✅ Optional: refresh proactively when the token is about to expire
// ❌ Retrying 401 in a loop → infinite requests
// ❌ Each request refreshing on its own → refresh storm, tokens overwrite each other
// ❌ Storing tokens in UserDefaults
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Access token vs refresh token?
//    → Access token is short-lived and sent every request; refresh token is long-lived and gets new access tokens.
//
// 2. What happens when a request gets a 401?
//    → Refresh the access token, then retry the original request once.
//
// 3. Five requests get 401 at the same time — what do you do?
//    → Run one refresh; the others wait for it, then all retry with the new token.
//
// 4. How do you make sure only one refresh runs?
//    → An actor that stores the in-flight refresh Task and lets callers await it.
//
// 5. What if the refresh token has expired?
//    → Log the user out, clear stored tokens, show the login screen.
//
// 6. Where should tokens be stored?
//    → Keychain — never UserDefaults.
//
// 7. Why retry only once after refreshing?
//    → To avoid an infinite loop if the server keeps rejecting the token.
//
//==============================================================
