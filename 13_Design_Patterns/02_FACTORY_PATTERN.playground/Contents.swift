import Foundation

// ============================================================
// MARK: - FACTORY PATTERN
// ============================================================

/*
 Factory = centralizes object creation.

 Caller
    ↓
 Factory          "Which object should I create?"
    ↓
 Protocol (abstraction)
    ↓
 Concrete object  (Card / UPI / Apple Pay)

 Caller depends on the PROTOCOL, never on the concrete class.
*/


// ============================================================
// MARK: - 1. Abstraction + Concrete Types
// ============================================================

protocol PaymentService {
    func pay(amount: Double)
}

final class CardPayment: PaymentService {
    func pay(amount: Double) {
        print("💳 Card paid ₹\(Int(amount))")
    }
}

final class UPIPayment: PaymentService {
    func pay(amount: Double) {
        print("📱 UPI paid ₹\(Int(amount))")
    }
}

final class ApplePayPayment: PaymentService {
    func pay(amount: Double) {
        print("🍎 Apple Pay paid ₹\(Int(amount))")
    }
}


// ============================================================
// MARK: - 2. Factory
// ============================================================

enum PaymentType: CaseIterable {
    case card
    case upi
    case applePay
}

enum PaymentFactory {

    // Returns the PROTOCOL → caller never sees the concrete class
    static func create(type: PaymentType) -> PaymentService {
        switch type {
        case .card:
            return CardPayment()
        case .upi:
            return UPIPayment()
        case .applePay:
            return ApplePayPayment()
        }
    }
}

print("\n========== 02 - Factory ==========")

let payment = PaymentFactory.create(type: .upi)

payment.pay(amount: 500)                                     // 📱 UPI paid ₹500

for type in PaymentType.allCases {
    PaymentFactory.create(type: type).pay(amount: 100)
}


// ============================================================
// MARK: - 3. Without Factory (the problem)
// ============================================================

/*
 Every screen does:

 if type == .card { CardPayment().pay(...) }
 else if type == .upi { UPIPayment().pay(...) }
 ...

 ❌ Callers know every concrete class
 ❌ Adding "Wallet" = editing every caller
 ✅ With Factory: add one case + one line in ONE place
*/


// ============================================================
// MARK: - 4. Factory by Environment / Configuration
// ============================================================

protocol AnalyticsService {
    func track(_ event: String)
}

final class ConsoleAnalytics: AnalyticsService {
    func track(_ event: String) {
        print("🧪 [DEBUG] \(event)")
    }
}

final class FirebaseAnalytics: AnalyticsService {
    func track(_ event: String) {
        print("📊 [PROD] sent \(event)")
    }
}

enum AppEnvironment {
    case debug
    case production
}

enum AnalyticsFactory {

    static func make(for environment: AppEnvironment) -> AnalyticsService {
        switch environment {
        case .debug:
            return ConsoleAnalytics()
        case .production:
            return FirebaseAnalytics()
        }
    }
}

print("\n========== 04 - Factory by Environment ==========")

AnalyticsFactory.make(for: .debug).track("Checkout")         // 🧪 [DEBUG] Checkout

AnalyticsFactory.make(for: .production).track("Checkout")    // 📊 [PROD] sent Checkout


// ============================================================
// MARK: - 5. Screen Factory (+ Dependency Injection)
// ============================================================

/*
 Factory CREATES the screen and INJECTS its dependencies.
 Coordinators call the factory instead of building screens inline.
*/

final class ProductViewModel {

    let productID: Int
    let analytics: AnalyticsService

    init(productID: Int, analytics: AnalyticsService) {
        self.productID = productID
        self.analytics = analytics
    }
}

final class ProductScreen {

    let viewModel: ProductViewModel

    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }
}

protocol ScreenFactory {
    func makeProductScreen(productID: Int) -> ProductScreen
}

final class AppScreenFactory: ScreenFactory {

    private let analytics: AnalyticsService

    init(analytics: AnalyticsService) {
        self.analytics = analytics
    }

    func makeProductScreen(productID: Int) -> ProductScreen {
        let viewModel = ProductViewModel(productID: productID, analytics: analytics)   // inject
        return ProductScreen(viewModel: viewModel)
    }
}

print("\n========== 05 - Screen Factory ==========")

let screenFactory: ScreenFactory = AppScreenFactory(analytics: AnalyticsFactory.make(for: .debug))

let screen = screenFactory.makeProductScreen(productID: 42)

print("Built screen for product:", screen.viewModel.productID)    // 42

screen.viewModel.analytics.track("PDP Viewed")                   // 🧪 [DEBUG] PDP Viewed


// ============================================================
// MARK: - 6. Testing with a Mock Factory
// ============================================================

final class MockPayment: PaymentService {

    private(set) var paidAmounts: [Double] = []

    func pay(amount: Double) {
        paidAmounts.append(amount)                               // record, don't charge
    }
}

final class CheckoutViewModel {

    private let makePayment: (PaymentType) -> PaymentService     // factory injected as a closure

    init(makePayment: @escaping (PaymentType) -> PaymentService = PaymentFactory.create) {
        self.makePayment = makePayment
    }

    func checkout(total: Double, using type: PaymentType) {
        makePayment(type).pay(amount: total)
    }
}

print("\n========== 06 - Testing with Mock ==========")

let mockPayment = MockPayment()

let testCheckout = CheckoutViewModel(makePayment: { _ in mockPayment })

testCheckout.checkout(total: 999, using: .card)

print("Mock recorded:", mockPayment.paidAmounts)                // [999.0] — no real charge


// ============================================================
// MARK: - 7. Types of Factory
// ============================================================

/*
 Simple Factory     → one function/switch returns the right type
                      (PaymentFactory above — most common in iOS)

 Factory Method     → a protocol method subclasses/conformers override
                      to decide what to create (ScreenFactory above)

 Abstract Factory   → creates a FAMILY of related objects together
                      e.g. ThemeFactory → makeButton(), makeLabel(), makeColor()

 Swift built-ins that are factories:
 UIColor.systemBlue · URL(string:) · UIButton(type: .system) · JSONDecoder()
*/


// ============================================================
// MARK: - 8. Factory vs Singleton vs DI
// ============================================================

/*
 Factory    → "Which object should I create?"
 Singleton  → "Give me the ONE shared instance."
 DI         → "Give this object the dependency it needs."

 They work together:
 Factory creates → DI injects → ViewModel uses
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is the Factory pattern?
     → A creational pattern that centralizes object creation behind one place.

 Q2. What problem does it solve?
     → Callers stop depending on concrete classes; adding a type changes one place.

 Q3. Why return a protocol from a factory?
     → The caller depends on an abstraction, so implementations can change freely.

 Q4. Factory vs Singleton?
     → Factory decides what to create; Singleton guarantees one shared instance.

 Q5. Factory vs Dependency Injection?
     → Factory creates objects; DI hands them to the objects that need them.

 Q6. Simple Factory vs Factory Method vs Abstract Factory?
     → One switch; an overridable creation method; a family of related objects.

 Q7. How do you test code that uses a factory?
     → Inject the factory (protocol or closure) and pass a mock in tests.

 Q8. When is a factory overkill?
     → When there's only one implementation and creation is a plain init.
*/
