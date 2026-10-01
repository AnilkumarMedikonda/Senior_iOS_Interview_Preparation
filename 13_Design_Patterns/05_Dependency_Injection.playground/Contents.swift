import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - DEPENDENCY INJECTION
// ============================================================

/*
 Dependency Injection (DI) = give an object what it needs from OUTSIDE,
 instead of letting it create its own dependencies.

 ❌ Without DI:  ViewModel ──creates──→ APIClient()
 ✅ With DI:     Composition root ──passes──→ APIClient ──into──→ ViewModel

 DI is the technique that applies DIP (depend on protocols).
*/


// ============================================================
// MARK: - 1. The Problem — Hard-Coded Dependency
// ============================================================

@MainActor
final class RealAPIClient {
    func fetchProductName() async -> String {
        try? await Task.sleep(for: .milliseconds(100))       // real network in an app
        return "Running Shoes"
    }
}

@MainActor
final class TightlyCoupledViewModel {

    private let api = RealAPIClient()                        // ❌ creates its own dependency

    func load() async -> String {
        await api.fetchProductName()
    }
}

// ❌ Can't test without the real network
// ❌ Can't swap the client for staging / mock / cache


// ============================================================
// MARK: - 2. Abstraction (Protocol)
// ============================================================

@MainActor
protocol ProductAPI {
    func fetchProductName() async -> String
}

extension RealAPIClient: ProductAPI {}                       // real one conforms

@MainActor
final class MockProductAPI: ProductAPI {

    private(set) var callCount = 0

    func fetchProductName() async -> String {
        callCount += 1
        return "Mock Shoes"                                  // instant, predictable
    }
}


// ============================================================
// MARK: - 3. Initializer Injection (preferred)
// ============================================================

/*
 Dependency passed in init → required, immutable (let), always set.
*/

@MainActor
final class ProductViewModel {

    private let api: ProductAPI                              // protocol, not concrete type

    init(api: ProductAPI) {
        self.api = api
    }

    func load() async -> String {
        await api.fetchProductName()
    }
}


// ============================================================
// MARK: - 4. Default Value Injection
// ============================================================

/*
 Real dependency by default → app code stays simple.
 Tests still pass a mock.
*/

@MainActor
final class CartViewModel {

    private let api: ProductAPI

    init(api: ProductAPI = RealAPIClient()) {
        self.api = api
    }

    func firstItem() async -> String {
        await api.fetchProductName()
    }
}


// ============================================================
// MARK: - 5. Property Injection
// ============================================================

/*
 Set after creation. Used when you don't control init
 (storyboard view controllers) or for optional dependencies.
 ⚠️ Can be forgotten → optional / crash risk.
*/

@MainActor
protocol Logger {
    func log(_ message: String)
}

@MainActor
final class ConsoleLogger: Logger {
    func log(_ message: String) {
        print("📝", message)
    }
}

@MainActor
final class ProfileScreen {

    var logger: Logger?                                      // injected later

    func viewDidLoad() {
        logger?.log("Profile opened")
    }
}


// ============================================================
// MARK: - 6. Method Injection
// ============================================================

/*
 Dependency passed only to the method that needs it.
 Good when it changes per call.
*/

@MainActor
final class ReceiptPrinter {

    func printReceipt(total: Int, using logger: Logger) {
        logger.log("Receipt total ₹\(total)")
    }
}


// ============================================================
// MARK: - 7. Composition Root (Simple DI Container)
// ============================================================

/*
 ONE place that creates concrete types and wires them together.
 Everything else just receives what it needs.
*/

@MainActor
final class AppContainer {

    let api: ProductAPI

    let logger: Logger

    init(api: ProductAPI, logger: Logger) {
        self.api = api
        self.logger = logger
    }

    static func live() -> AppContainer {
        AppContainer(api: RealAPIClient(), logger: ConsoleLogger())
    }

    static func test() -> AppContainer {
        AppContainer(api: MockProductAPI(), logger: ConsoleLogger())
    }

    func makeProductViewModel() -> ProductViewModel {
        ProductViewModel(api: api)
    }

    func makeProfileScreen() -> ProfileScreen {
        let screen = ProfileScreen()
        screen.logger = logger
        return screen
    }
}


// ============================================================
// MARK: - Run
// ============================================================

Task {

    print("\n========== 03 - Initializer Injection ==========")

    let liveViewModel = ProductViewModel(api: RealAPIClient())

    print("Live:", await liveViewModel.load())               // Running Shoes

    let mock = MockProductAPI()

    let testViewModel = ProductViewModel(api: mock)

    print("Test:", await testViewModel.load())               // Mock Shoes

    print("Mock called:", mock.callCount, "time(s)")         // 1


    print("\n========== 04 - Default Value Injection ==========")

    print("Default:", await CartViewModel().firstItem())     // Running Shoes

    print("Mocked: ", await CartViewModel(api: MockProductAPI()).firstItem())   // Mock Shoes


    print("\n========== 05 - Property Injection ==========")

    let profile = ProfileScreen()

    profile.logger = ConsoleLogger()

    profile.viewDidLoad()                                    // 📝 Profile opened


    print("\n========== 06 - Method Injection ==========")

    ReceiptPrinter().printReceipt(total: 4999, using: ConsoleLogger())


    print("\n========== 07 - Composition Root ==========")

    let live = AppContainer.live()

    print("Live container:", await live.makeProductViewModel().load())    // Running Shoes

    let test = AppContainer.test()

    print("Test container:", await test.makeProductViewModel().load())    // Mock Shoes

    live.makeProfileScreen().viewDidLoad()


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 8. DI in SwiftUI
// ============================================================

/*
 .environment(model)                   // inject once at the top
 @Environment(Model.self) var model    // read anywhere below

 Previews: inject a mock → no network.
*/


// ============================================================
// MARK: - 9. Service Locator (Anti-Pattern)
// ============================================================

/*
 ❌ let api = ServiceLocator.shared.resolve(ProductAPI.self)

 Dependencies are fetched from a global registry INSIDE the class →
 hidden again, just like a singleton. Prefer passing them in.
*/


// ============================================================
// MARK: - 10. DI vs DIP vs Factory vs Singleton
// ============================================================

/*
 DIP        → principle: depend on protocols, not concrete classes
 DI         → technique: pass those protocols in from outside
 Factory    → creates objects (often used by the composition root)
 Singleton  → one shared instance (inject it instead of calling .shared everywhere)
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is Dependency Injection?
     → Passing an object's dependencies in from outside instead of creating them inside.

 Q2. Why use it?
     → Loose coupling, easy swapping, and testing with mocks.

 Q3. Types of DI?
     → Initializer (preferred), property, and method injection.

 Q4. Why prefer initializer injection?
     → Dependencies are required, immutable, and can't be forgotten.

 Q5. When use property injection?
     → When you don't control init, like storyboard view controllers.

 Q6. What is a composition root?
     → The one place that creates concrete types and wires them together.

 Q7. DI vs DIP?
     → DIP is the principle (depend on abstractions); DI is how you supply them.

 Q8. Why is a service locator discouraged?
     → It hides dependencies inside the class, like a singleton.
*/
