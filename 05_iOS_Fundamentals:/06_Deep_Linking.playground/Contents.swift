import Foundation

//==============================================================
// MARK: - Deep Linking
//==============================================================
//
// A URL that opens a specific screen inside the app.
// Custom scheme: myshop://product/42
// Flow: URL → parse → typed Route → navigate.
// Registered in Info.plist → URL Types → URL Schemes.
//


//==============================================================
// MARK: - 01. Typed Routes
//==============================================================
//
// Parse once into an enum — the rest of the app never touches raw strings.
//

enum Route: Equatable {
    case product(id: Int)
    case category(name: String)
    case cart
    case search(query: String)
    case unknown
}


//==============================================================
// MARK: - 02. Parsing with URLComponents
//==============================================================
//
// myshop://product/42          → host "product", path "/42"
// myshop://search?q=shoes      → host "search", query q=shoes
//

func parse(_ url: URL) -> Route {
    guard url.scheme == "myshop",
          let components = URLComponents(url: url, resolvingAgainstBaseURL: false) else {
        return .unknown
    }

    let pathParts = components.path.split(separator: "/").map(String.init)

    switch components.host {

    case "product":
        if let first = pathParts.first, let id = Int(first) {
            return .product(id: id)
        }
        return .unknown

    case "category":
        if let name = pathParts.first {
            return .category(name: name)
        }
        return .unknown

    case "cart":
        return .cart

    case "search":
        if let query = components.queryItems?.first(where: { $0.name == "q" })?.value {
            return .search(query: query)
        }
        return .unknown

    default:
        return .unknown
    }
}

print("\n========== 02 - Parsing ==========")

let links = [
    "myshop://product/42",
    "myshop://category/running",
    "myshop://cart",
    "myshop://search?q=shoes",
    "myshop://product/abc",
    "otherapp://product/1"
]

for link in links {
    if let url = URL(string: link) {
        print(link, "→", parse(url))
    }
}

// product(id: 42) | category(name: "running") | cart
// search(query: "shoes") | unknown (bad id) | unknown (wrong scheme)


//==============================================================
// MARK: - 03. Router
//==============================================================
//
// One place maps a Route to navigation.
//

final class DeepLinkRouter {

    func handle(_ route: Route) {
        switch route {
        case .product(let id):
            print("Push ProductDetail(id: \(id))")
        case .category(let name):
            print("Push CategoryList(\(name))")
        case .cart:
            print("Switch to Cart tab")
        case .search(let query):
            print("Open Search with '\(query)'")
        case .unknown:
            print("Unknown link → stay on Home")
        }
    }
}

print("\n========== 03 - Router ==========")

let router = DeepLinkRouter()

if let url = URL(string: "myshop://product/42") {
    router.handle(parse(url))                    // Push ProductDetail(id: 42)
}


//==============================================================
// MARK: - 04. Where Links Arrive
//==============================================================
//
// Cold start (app not running) → scene(_:willConnectTo:options:) connectionOptions.urlContexts
// Warm start (app running)     → scene(_:openURLContexts:)
// SwiftUI                      → .onOpenURL { url in }
//
// Cold start: UI may not be ready — store the pending route,
// navigate after the root screen / login finishes.
//


//==============================================================
// MARK: - 05. Real-World Concerns
//==============================================================
//
// 1. Validate everything — links are external input (never trust IDs).
// 2. Login required → save the route, finish login, then navigate.
// 3. Build the full stack: Home → Category → Product, so Back works.
// 4. Unknown / broken link → safe fallback (Home), never crash.
// 5. Custom schemes aren't unique — any app can claim "myshop://".
//    Use Universal Links for real web → app links (07_Universal_Links).
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a deep link?
//    → A URL that opens a specific screen inside the app.
//
// 2. How do you register a custom URL scheme?
//    → Info.plist → URL Types → URL Schemes.
//
// 3. How do you parse a deep link?
//    → URLComponents for host, path, and query items → map to a typed Route enum.
//
// 4. Where does the URL arrive on cold vs warm start?
//    → Cold: willConnectTo connectionOptions. Warm: openURLContexts.
//
// 5. How do you handle a link that needs login?
//    → Store the pending route, finish login, then navigate.
//
// 6. Why not rely only on custom URL schemes?
//    → Not unique, no web fallback, any app can register the same scheme.
//
// 7. How do you make Back work after a deep link?
//    → Build the full navigation stack, not just the final screen.
//
//==============================================================
