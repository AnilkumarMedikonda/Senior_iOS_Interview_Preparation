import Foundation

//==============================================================
// MARK: - Deep Link from Notification
//==============================================================
//
// Push payload carries a route → tap opens that screen.
// Best practice: put a deep link URL in the payload and reuse the
// SAME parser + router as custom schemes and Universal Links.
// One router, three entry points.
//


//==============================================================
// MARK: - 01. Payload with a Deep Link
//==============================================================
//
// {
//   "aps": { "alert": { "title": "Back in stock", "body": "Your size is available" } },
//   "deeplink": "myshop://product/42"
// }
//
// A URL instead of custom keys (type, id) → backend can add new
// screens without an app update, as long as the router knows them.
//


//==============================================================
// MARK: - 02. Payload → Route
//==============================================================

enum Route: Equatable {
    case product(id: Int)
    case cart
    case unknown
}

func parse(_ url: URL) -> Route {
    guard url.scheme == "myshop" else { return .unknown }
    let parts = url.path.split(separator: "/").map(String.init)
    switch url.host {
    case "product":
        if let first = parts.first, let id = Int(first) {
            return .product(id: id)
        }
        return .unknown
    case "cart":
        return .cart
    default:
        return .unknown
    }
}

func route(from userInfo: [AnyHashable: Any]) -> Route {
    guard let link = userInfo["deeplink"] as? String,
          let url = URL(string: link) else {
        return .unknown                              // no / bad link → safe fallback
    }
    return parse(url)
}

print("\n========== 02 - Payload → Route ==========")

print(route(from: ["deeplink": "myshop://product/42"]))   // product(id: 42)

print(route(from: ["deeplink": "myshop://cart"]))         // cart

print(route(from: ["aps": ["alert": "Hi"]]))              // unknown — no link


//==============================================================
// MARK: - 03. Cold Start — Pending Route
//==============================================================
//
// Tap on a killed app → didReceive fires BEFORE the UI / login is ready.
// Store the route, navigate once the app is ready.
//

final class DeepLinkCoordinator {

    private var pendingRoute: Route?

    private var isReady = false

    func handle(_ route: Route) {
        if isReady {
            navigate(to: route)
        } else {
            pendingRoute = route                     // hold until ready
            print("App not ready → saved", route)
        }
    }

    func appDidBecomeReady() {
        isReady = true
        if let route = pendingRoute {
            pendingRoute = nil
            navigate(to: route)
        }
    }

    private func navigate(to route: Route) {
        switch route {
        case .product(let id):
            print("Navigate: Home → ProductDetail(\(id))")   // full stack → Back works
        case .cart:
            print("Navigate: Cart tab")
        case .unknown:
            print("Navigate: stay on Home")
        }
    }
}

print("\n========== 03 - Cold Start ==========")

let coldCoordinator = DeepLinkCoordinator()

coldCoordinator.handle(.product(id: 42))            // App not ready → saved

coldCoordinator.appDidBecomeReady()                  // Navigate: Home → ProductDetail(42)


print("\n========== 03 - Warm Start ==========")

let warmCoordinator = DeepLinkCoordinator()

warmCoordinator.appDidBecomeReady()

warmCoordinator.handle(.cart)                        // Navigate: Cart tab — immediately


//==============================================================
// MARK: - 04. One Router, Three Entry Points
//==============================================================
//
// Custom scheme  → openURLContexts / onOpenURL        ─┐
// Universal Link → NSUserActivity.webpageURL           ├─▶ parse → Route → Coordinator
// Push tap       → userInfo["deeplink"] in didReceive ─┘
//
// Same parser, same navigation, same fallbacks → fewer bugs.
//


//==============================================================
// MARK: - 05. Real-World Rules
//==============================================================
//
// 1. Login required → keep the pending route until login finishes.
// 2. Build the full stack (Home → Category → Product) so Back works.
// 3. Unknown or expired item → fallback screen, never a crash.
// 4. Track the tap (analytics) before navigating.
// 5. Clear the badge / mark as read after handling.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. How do you open a specific screen from a push?
//    → Put a deep link in the payload, parse it in didReceive, route to the screen.
//
// 2. Why use a URL in the payload instead of custom keys?
//    → Reuses the deep link router; new screens need no new push-handling code.
//
// 3. What goes wrong on a cold start tap?
//    → didReceive fires before the UI is ready — navigating then fails.
//
// 4. How do you fix it?
//    → Store a pending route and navigate once the root screen / login is ready.
//
// 5. How do you handle a push for a screen that needs login?
//    → Keep the route, show login, navigate after success.
//
// 6. Why share one router for pushes, schemes, and Universal Links?
//    → Same parsing and fallbacks everywhere — one place to fix and test.
//
//==============================================================
