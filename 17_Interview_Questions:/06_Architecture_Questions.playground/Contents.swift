import Foundation

// ============================================================
// MARK: - 06_ARCHITECTURE_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Each question:
 1. Question + short spoken answer
 2. Follow-up the interviewer usually asks
 3. A tiny code proof with DEBUG output

 One shared example: a product screen.
*/


// ============================================================
// MARK: - Shared Model + Data
// ============================================================

struct Product {
    let id: Int
    let name: String
    let price: Double
}

protocol ProductRepository {
    func product(id: Int) -> Product?
}

struct StubProductRepository: ProductRepository {
    func product(id: Int) -> Product? {
        Product(id: id, name: "Running Shoes", price: 4999)
    }
}


// ============================================================
// MARK: - Q01–Q03. MVC vs MVVM — ViewModel Without UIKit
// ============================================================

/*
 Q1: MVC vs MVVM?
 Answer: MVVM moves presentation logic + state from the VC
         into a ViewModel with no UIKit → testable.

 Q2: Massive VC fix?
 Answer: Services / repositories, ViewModel, Coordinator,
         child VCs.

 Q3: What belongs in a ViewModel?
 Answer: State, formatting, user actions. No UIKit, no push,
         no URLSession.
*/

final class ProductViewModel {

    private let repository: ProductRepository

    private(set) var title = ""

    private(set) var price = ""

    var onReviewsTapped: (() -> Void)?                       // navigation = event, not push

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func load(id: Int) {
        guard let product = repository.product(id: id) else {
            title = "Not found"
            return
        }
        title = product.name
        price = "₹\(Int(product.price))"                      // formatting lives here
    }

    func reviewsTapped() {
        onReviewsTapped?()
    }
}

let viewModel = ProductViewModel(repository: StubProductRepository())

viewModel.load(id: 42)

print("DEBUG Q03 - tested without UIKit:", viewModel.title, viewModel.price)


// ============================================================
// MARK: - Q04. Coordinator
// ============================================================

/*
 Q: Why Coordinators?

 Answer:
 Own navigation + screen creation; screens don't know each
 other; deep links in one place.

 Follow-up: child coordinator leaks?
 → Keep in childCoordinators, remove when finished.
*/

final class ProductCoordinator {

    private(set) var stack: [String] = []

    func start() {
        let screenViewModel = ProductViewModel(repository: StubProductRepository())
        screenViewModel.onReviewsTapped = { [weak self] in
            self?.stack.append("Reviews")                    // coordinator decides
        }
        stack = ["Product"]
        screenViewModel.reviewsTapped()                      // simulate tap
    }
}

let coordinator = ProductCoordinator()

coordinator.start()

print("DEBUG Q04 - navigation stack:", coordinator.stack)   // ["Product", "Reviews"]


// ============================================================
// MARK: - Q05. VIPER
// ============================================================

/*
 Q: What is VIPER?

 Answer:
 View · Interactor · Presenter · Entity · Router — one job
 each, via protocols. Very testable, lots of boilerplate.
*/

print("DEBUG Q05 - VIPER = 5+ files per screen → large teams only")


// ============================================================
// MARK: - Q06. Clean Architecture — Dependency Rule
// ============================================================

/*
 Q: What is Clean Architecture?

 Answer:
 Presentation → Domain ← Data. Domain is pure Swift and owns
 the repository protocol; Data implements it.
*/

// Domain
struct GetProductUseCase {

    let repository: ProductRepository

    func execute(id: Int) -> Product? {
        guard let product = repository.product(id: id), product.price > 0 else {
            return nil                                       // business rule here
        }
        return product
    }
}

print("DEBUG Q06 - use case:", GetProductUseCase(repository: StubProductRepository()).execute(id: 1)?.name as Any)


// ============================================================
// MARK: - Q07–Q08. Choosing + Business Logic
// ============================================================

/*
 Q7: Large app?
 Answer: MVVM-C default + Clean layers for complex logic.

 Q8: Business logic?
 Answer: Use cases / services / domain — never views.
*/

print("DEBUG Q07 - default: MVVM-C (+ Clean when logic grows)")


// ============================================================
// MARK: - Q09. Repository (Cache-First)
// ============================================================

/*
 Q: Repository vs API client?

 Answer:
 API client = HTTP only. Repository = combines API + cache +
 DB, returns domain models.
*/

final class CachedProductRepository: ProductRepository {

    private var cache: [Int: Product] = [:]

    private(set) var networkCalls = 0

    func product(id: Int) -> Product? {
        if let cached = cache[id] {
            return cached
        }
        networkCalls += 1                                    // pretend API call
        let fresh = Product(id: id, name: "Cap", price: 499)
        cache[id] = fresh
        return fresh
    }
}

let cachedRepository = CachedProductRepository()

_ = cachedRepository.product(id: 1)

_ = cachedRepository.product(id: 1)

print("DEBUG Q09 - network calls for 2 reads:", cachedRepository.networkCalls)   // 1


// ============================================================
// MARK: - Q10. Singleton — Injectable
// ============================================================

/*
 Q: What's wrong with singletons?

 Answer:
 Global state + hidden dependencies. Hide behind a protocol,
 inject with .shared as default.
*/

protocol AnalyticsTracking {
    func track(_ event: String)
}

final class Analytics: AnalyticsTracking, Sendable {          // Sendable → safe static let in Swift 6

    static let shared = Analytics()

    private init() {}

    func track(_ event: String) {
        print("DEBUG Q10 - real analytics:", event)
    }
}

final class MockAnalytics: AnalyticsTracking {

    private(set) var events: [String] = []

    func track(_ event: String) {
        events.append(event)
    }
}

final class CheckoutViewModel {

    private let analytics: AnalyticsTracking

    init(analytics: AnalyticsTracking = Analytics.shared) {
        self.analytics = analytics
    }

    func pay() {
        analytics.track("purchase")
    }
}

CheckoutViewModel().pay()                                    // app

let mockAnalytics = MockAnalytics()

CheckoutViewModel(analytics: mockAnalytics).pay()            // test

print("DEBUG Q10 - mock recorded:", mockAnalytics.events)


// ============================================================
// MARK: - Q11 + Q16. Factory + OCP
// ============================================================

/*
 Q11: Factory?  → hide which concrete type is created.
 Q16: OCP?      → new type, no edits to existing code.
*/

protocol PaymentMethod {
    func pay(_ amount: Int) -> String
}

struct CardPayment: PaymentMethod {
    func pay(_ amount: Int) -> String { "Card ₹\(amount)" }
}

struct UPIPayment: PaymentMethod {
    func pay(_ amount: Int) -> String { "UPI ₹\(amount)" }
}

enum PaymentFactory {

    static func make(_ type: String) -> PaymentMethod {
        type == "upi" ? UPIPayment() : CardPayment()
    }
}

func checkout(_ method: PaymentMethod) -> String {             // closed for modification
    method.pay(999)
}

struct WalletPayment: PaymentMethod {                         // open for extension
    func pay(_ amount: Int) -> String { "Wallet ₹\(amount)" }
}

print("DEBUG Q11 -", checkout(PaymentFactory.make("upi")))

print("DEBUG Q16 -", checkout(WalletPayment()), "← added without editing checkout()")


// ============================================================
// MARK: - Q12. Delegate vs Observer
// ============================================================

/*
 Q: Delegate vs Observer?

 Answer:
 Delegate = one-to-one, can return values.
 Observer = one-to-many broadcast.
*/

extension Notification.Name {
    static let cartChanged = Notification.Name("cartChanged")
}

let observerA = NotificationCenter.default.addObserver(forName: .cartChanged, object: nil, queue: nil) { _ in
    print("DEBUG Q12 - badge updated")
}

let observerB = NotificationCenter.default.addObserver(forName: .cartChanged, object: nil, queue: nil) { _ in
    print("DEBUG Q12 - checkout button updated")
}

NotificationCenter.default.post(name: .cartChanged, object: nil)   // one post → many listeners

NotificationCenter.default.removeObserver(observerA)

NotificationCenter.default.removeObserver(observerB)


// ============================================================
// MARK: - Q13. Adapter
// ============================================================

/*
 Q: Why wrap SDKs with an Adapter?

 Answer:
 App depends on your protocol → swap vendors, mock in tests.
*/

final class ThirdPartySDK {
    func logEvent(name: String, params: [String: String]) {
        print("DEBUG Q13 - SDK.logEvent(\(name))")
    }
}

final class SDKAnalyticsAdapter: AnalyticsTracking {

    private let sdk = ThirdPartySDK()

    func track(_ event: String) {
        sdk.logEvent(name: event, params: [:])               // translate the call
    }
}

CheckoutViewModel(analytics: SDKAnalyticsAdapter()).pay()


// ============================================================
// MARK: - Q14 + Q19. DI + DIP — Composition Root
// ============================================================

/*
 Q14: DI?  → pass dependencies in (init); wire in one place.
 Q19: DIP vs DI? → principle (depend on protocols) vs technique.
*/

struct AppContainer {

    let repository: ProductRepository

    let analytics: AnalyticsTracking

    func makeProductViewModel() -> ProductViewModel {
        ProductViewModel(repository: repository)
    }
}

let testContainer = AppContainer(repository: StubProductRepository(), analytics: MockAnalytics())

let injectedViewModel = testContainer.makeProductViewModel()

injectedViewModel.load(id: 9)

print("DEBUG Q14 - built in composition root:", injectedViewModel.title)


// ============================================================
// MARK: - Q15. SRP
// ============================================================

/*
 Q: SRP with an iOS example?

 Answer:
 One reason to change — formatter, repository, ViewModel
 each do one job (see the types above).
*/

struct PriceFormatter {
    func format(_ price: Double) -> String { "₹\(Int(price))" }
}

print("DEBUG Q15 - formatter alone:", PriceFormatter().format(1299))


// ============================================================
// MARK: - Q17. LSP Violation
// ============================================================

/*
 Q: Give an LSP violation.

 Answer:
 Square subclassing Rectangle breaks "set width keeps height".
*/

class Rectangle {
    var width = 0.0
    var height = 0.0
    func setWidth(_ value: Double) { width = value }
    func setHeight(_ value: Double) { height = value }
    var area: Double { width * height }
}

final class Square: Rectangle {
    override func setWidth(_ value: Double) { width = value; height = value }
    override func setHeight(_ value: Double) { width = value; height = value }
}

func resize(_ shape: Rectangle) -> Double {
    shape.setWidth(5)
    shape.setHeight(4)
    return shape.area
}

print("DEBUG Q17 - Rectangle:", resize(Rectangle()), "| Square:", resize(Square()))   // 20 | 16 ❌


// ============================================================
// MARK: - Q18. ISP
// ============================================================

/*
 Q: ISP?

 Answer:
 Small protocols; a read-only screen depends only on reading.
*/

protocol ProductReading {
    func products() -> [String]
}

protocol ProductWriting {
    func add(_ name: String)
}

struct ReadOnlyMock: ProductReading {                         // mock implements ONE method
    func products() -> [String] { ["Shoes"] }
}

print("DEBUG Q18 - tiny mock:", ReadOnlyMock().products())


// ============================================================
// MARK: - Q20. Testability
// ============================================================

/*
 Q: How does architecture affect testability?

 Answer:
 Protocols + DI + logic outside UI → test with mocks,
 no network, no simulator.
*/

print("DEBUG Q20 - every proof above ran without UIKit or network ✅")


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Coordinator ── navigation
        ↓
   View ⇄ ViewModel ── state + formatting
              ↓
          UseCase ── business rules
              ↓
      Repository (protocol) ← RemoteRepository → APIClient
              ↓
         Composition root wires concrete types

   Patterns: Factory · Adapter · Observer · Delegate · DI
   SOLID:    one job · extend not edit · honest subtypes ·
             small protocols · depend on abstractions


 Senior One-Liner:

 "I default to MVVM with Coordinators, add Clean layers when
  business logic grows, keep dependencies behind protocols
  wired in one composition root, and apply SOLID so each type
  has one job and is easy to test."
*/
