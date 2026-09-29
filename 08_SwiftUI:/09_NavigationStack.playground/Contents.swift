import SwiftUI
import Observation
import PlaygroundSupport

//==============================================================
// MARK: - NavigationStack (iOS 16+)
//==============================================================
//
// Navigation driven by DATA: the stack is an array of values (the path).
// Push = append, pop = removeLast, pop to root = removeAll.
// Replaces NavigationView.
//
// NavigationLink(value:)              → pushes a value
// .navigationDestination(for: Type)   → decides which view shows for it
//
// ▶︎ Run, navigate in the live view, and watch the console print the path.
//


//==============================================================
// MARK: - 01. Routes
//==============================================================
//
// One Hashable enum for every screen → type-safe, deep-linkable.
//

enum Route: Hashable {
    case category(String)
    case product(Int)
    case cart
}


//==============================================================
// MARK: - 02. Router
//==============================================================
//
// Owns the path. Injected through the environment →
// any screen can navigate without passing closures around.
//

@MainActor
@Observable
final class Router {

    var path: [Route] = [] {
        didSet { print("Path:", path) }
    }

    func push(_ route: Route) {
        path.append(route)
    }

    func pop() {
        if !path.isEmpty {
            path.removeLast()
        }
    }

    func popToRoot() {
        path.removeAll()
    }

    func openDeepLink(productID: Int) {
        path = [.category("Running"), .product(productID)]   // full stack → Back works
    }
}


//==============================================================
// MARK: - 03. Screens
//==============================================================

struct HomeView: View {

    @Environment(Router.self) private var router

    var body: some View {
        List {
            NavigationLink("Running shoes", value: Route.category("Running"))   // value-based link
            NavigationLink("Cart", value: Route.cart)
            Button("Deep link → product 42") {
                router.openDeepLink(productID: 42)
            }
        }
        .navigationTitle("Home")
    }
}

struct CategoryView: View {

    let name: String

    var body: some View {
        List(1...3, id: \.self) { id in
            NavigationLink("\(name) shoe #\(id)", value: Route.product(id))
        }
        .navigationTitle(name)
    }
}

struct ProductView: View {

    let productID: Int

    @Environment(Router.self) private var router

    var body: some View {
        VStack(spacing: 16) {
            Text("Product \(productID)")
                .font(.title)
            Button("Go to cart") {
                router.push(.cart)                            // programmatic push
            }
            Button("Back to Home") {
                router.popToRoot()                            // pop to root
            }
        }
        .navigationTitle("Product")
    }
}

struct CartView: View {

    @Environment(Router.self) private var router

    var body: some View {
        Button("Continue shopping") {
            router.pop()
        }
        .navigationTitle("Cart")
    }
}


//==============================================================
// MARK: - 04. Root: Stack + Destinations
//==============================================================
//
// ONE navigationDestination per type, attached OUTSIDE lazy containers
// (not inside List / LazyVStack rows).
//

struct ShopApp: View {

    @State private var router = Router()

    var body: some View {
        NavigationStack(path: $router.path) {
            HomeView()
                .navigationDestination(for: Route.self) { route in
                    switch route {
                    case .category(let name):
                        CategoryView(name: name)
                    case .product(let id):
                        ProductView(productID: id)
                    case .cart:
                        CartView()
                    }
                }
        }
        .environment(router)
    }
}

// Console examples:
// Tap "Running shoes"  → Path: [category("Running")]
// Tap shoe #2          → Path: [category("Running"), product(2)]
// Tap "Back to Home"   → Path: []
// Tap "Deep link"      → Path: [category("Running"), product(42)]


//==============================================================
// MARK: - 05. NavigationPath vs Typed Array
//==============================================================
//
// [Route]          → one type, easy to inspect and test ✅ (preferred)
// NavigationPath   → type-erased, mixes types (Product, Order, …);
//                    .codable → save / restore the stack
//


//==============================================================
// MARK: - 06. Common Mistakes
//==============================================================
//
// ❌ NavigationLink(destination:) in long lists → builds every destination eagerly
//    ✅ NavigationLink(value:) + navigationDestination → built only when pushed
// ❌ navigationDestination inside List rows / LazyVStack → not found, warnings
// ❌ Two navigationDestination for the same type → only one is used
// ❌ NavigationStack nested inside another NavigationStack → broken navigation
// ❌ Deep link pushes only the final screen → Back goes to the wrong place
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    ShopApp()
        .frame(width: 380, height: 600)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. NavigationStack vs NavigationView?
//    → NavigationStack is data-driven with a path; NavigationView is deprecated.
//
// 2. How do you navigate programmatically?
//    → Change the path array — append to push, removeLast to pop, removeAll for root.
//
// 3. Why use NavigationLink(value:) instead of (destination:)?
//    → Destinations are created lazily and navigation is driven by data.
//
// 4. How do you handle a deep link in SwiftUI?
//    → Parse to routes and set the whole path, so Back works.
//
// 5. NavigationPath vs [Route]?
//    → [Route] for one type; NavigationPath for mixed types and Codable restoration.
//
// 6. Where should navigationDestination go?
//    → Once per type, outside lazy containers like List rows.
//
// 7. Why put the path in a Router?
//    → Any screen can navigate through the environment; logic is testable in one place.
//
//==============================================================
