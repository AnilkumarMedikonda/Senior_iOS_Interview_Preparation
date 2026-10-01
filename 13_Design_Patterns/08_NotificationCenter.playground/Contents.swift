import Foundation

// ============================================================
// MARK: - COORDINATOR PATTERN
// ============================================================

/*
 Coordinator = an object that owns NAVIGATION and screen creation,
 so screens never push / present each other.

 AppCoordinator
     ├── AuthCoordinator      (login flow)   → finishes → removed
     └── ShopCoordinator      (main flow)
              └── CheckoutCoordinator (child flow)

 Pattern focus here: parent/child coordinators and their lifecycle.
 (MVVM-C architecture version → 12_Architecture/03_Coordinator)
*/


// ============================================================
// MARK: - 1. Navigator (stand-in for UINavigationController)
// ============================================================

@MainActor
final class Navigator {

    private(set) var stack: [String] = []

    func setRoot(_ screen: String) {
        stack = [screen]
        print("🏠 Root →", screen, "| stack:", stack)
    }

    func push(_ screen: String) {
        stack.append(screen)
        print("➡️ Push →", screen, "| stack:", stack)
    }
}


// ============================================================
// MARK: - 2. Coordinator Protocol
// ============================================================

@MainActor
protocol Coordinator: AnyObject {
    var childCoordinators: [Coordinator] { get set }
    func start()
}

extension Coordinator {

    func addChild(_ child: Coordinator) {
        childCoordinators.append(child)                      // parent keeps child alive
    }

    func removeChild(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }         // finished → release it
    }
}


// ============================================================
// MARK: - 3. Child Coordinator: Auth Flow
// ============================================================

@MainActor
final class AuthCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    var onFinish: ((AuthCoordinator) -> Void)?               // tells parent "I'm done"

    private let navigator: Navigator

    init(navigator: Navigator) {
        self.navigator = navigator
    }

    func start() {
        navigator.setRoot("Login")
    }

    func loginSucceeded() {                                  // called by Login ViewModel event
        print("✅ Login succeeded")
        onFinish?(self)
    }

    deinit {
        print("AuthCoordinator deinit ✅ (removed after finishing)")
    }
}


// ============================================================
// MARK: - 4. Child Coordinator: Shop Flow
// ============================================================

@MainActor
final class ShopCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let navigator: Navigator

    init(navigator: Navigator) {
        self.navigator = navigator
    }

    func start() {
        navigator.setRoot("Product List")
    }

    func showProduct(id: Int) {                              // event from Product List
        navigator.push("Product \(id)")
    }

    func showCheckout() {
        navigator.push("Checkout")
    }

    func handleDeepLink(productID: Int) {                    // full stack → Back works
        start()
        showProduct(id: productID)
    }
}


// ============================================================
// MARK: - 5. App Coordinator (Root)
// ============================================================

@MainActor
final class AppCoordinator: Coordinator {

    var childCoordinators: [Coordinator] = []

    private let navigator = Navigator()

    private var isLoggedIn = false

    func start() {
        isLoggedIn ? showShop() : showAuth()
    }

    private func showAuth() {
        let auth = AuthCoordinator(navigator: navigator)
        auth.onFinish = { [weak self] finished in            // weak → no cycle
            self?.removeChild(finished)
            self?.isLoggedIn = true
            self?.showShop()
        }
        addChild(auth)
        auth.start()
    }

    private func showShop() {
        let shop = ShopCoordinator(navigator: navigator)
        addChild(shop)
        shop.start()
    }

    var auth: AuthCoordinator? {
        childCoordinators.first { $0 is AuthCoordinator } as? AuthCoordinator
    }

    var shop: ShopCoordinator? {
        childCoordinators.first { $0 is ShopCoordinator } as? ShopCoordinator
    }
}


// ============================================================
// MARK: - Run
// ============================================================

MainActor.assumeIsolated {

    print("\n========== 01 - App Starts → Auth Flow ==========")

    let app = AppCoordinator()

    app.start()

    print("Children:", app.childCoordinators.count)          // 1 (Auth)


    print("\n========== 02 - Login → Auth Finishes → Shop Flow ==========")

    app.auth?.loginSucceeded()

    print("Children:", app.childCoordinators.count)          // 1 (Shop) — Auth removed


    print("\n========== 03 - Navigation Inside Shop ==========")

    app.shop?.showProduct(id: 42)

    app.shop?.showCheckout()


    print("\n========== 04 - Deep Link ==========")

    app.shop?.handleDeepLink(productID: 7)                   // [Product List, Product 7]
}


// ============================================================
// MARK: - 6. Rules
// ============================================================

/*
 ✅ Screens send EVENTS; coordinators decide where to go
 ✅ Parent keeps children in childCoordinators (or they're deallocated)
 ✅ Child reports "finished" → parent removes it (or it leaks)
 ✅ [weak self] in finish closures / weak parent references
 ✅ Deep links build the full stack in one place
 ❌ View controllers pushing other view controllers directly
 ❌ Forgetting removeChild → finished flows stay in memory
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is the Coordinator pattern?
     → An object that owns navigation and screen creation, so screens don't know each other.

 Q2. Why keep childCoordinators?
     → Coordinators aren't owned by UIKit; without the array they'd be deallocated immediately.

 Q3. How does a child coordinator finish?
     → It calls back (closure / delegate) and the parent removes it.

 Q4. What happens if you forget removeChild?
     → The finished flow stays in memory — a leak.

 Q5. How do coordinators help deep links?
     → One coordinator builds the full navigation stack for the route.

 Q6. Is Coordinator a pattern or an architecture?
     → A pattern; combined with MVVM it forms the MVVM-C architecture.
*/
