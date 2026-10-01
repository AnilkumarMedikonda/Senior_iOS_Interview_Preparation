import Foundation

// ============================================================
// MARK: - LSP: LISKOV SUBSTITUTION PRINCIPLE
// ============================================================

/*
 LSP:

 A subtype should be safely replaceable for its base type
 without breaking the expected behavior.
*/


// ============================================================
// MARK: - 1. Payment Method
// ============================================================

protocol PaymentMethod {

    func pay()
}


// ============================================================
// MARK: - 2. Card Payment
// ============================================================

final class CardPayment: PaymentMethod {

    func pay() {
        print("Paid using Card")
    }
}


// ============================================================
// MARK: - 3. UPI Payment
// ============================================================

final class UPIPayment: PaymentMethod {

    func pay() {
        print("Paid using UPI")
    }
}


// ============================================================
// MARK: - 4. Client
// ============================================================

func processPayment(_ payment: PaymentMethod) {

    payment.pay()
}


// ============================================================
// MARK: - 5. Usage
// ============================================================

processPayment(CardPayment())
processPayment(UPIPayment())

print("DEBUG Q01 - ✅ Both substitute PaymentMethod safely")


// ============================================================
// MARK: - 6. ❌ LSP Violation — Subtype Breaks the Contract
// ============================================================

/*
 Cash on Delivery can't pay NOW, but it conforms to PaymentMethod.

 The client must now special-case it:
 "if payment is CashOnDelivery …"

 A subtype that needs special handling = LSP violation.
*/

final class CashOnDelivery: PaymentMethod {

    func pay() {
        print("❌ Cash on Delivery: can't pay now — nothing charged")   // breaks "pay()" contract
    }
}

func processPaymentWithHack(_ payment: PaymentMethod) {

    if payment is CashOnDelivery {                                   // ❌ type check = smell
        print("Special case: skip payment, mark order as COD")
        return
    }

    payment.pay()
}

processPayment(CashOnDelivery())                                     // silently "pays" nothing

processPaymentWithHack(CashOnDelivery())

print("DEBUG Q02 - ❌ Client needs a type check → LSP broken")


// ============================================================
// MARK: - 7. ✅ Fix — Model the Real Capabilities
// ============================================================

/*
 Only types that can really pay now conform to OnlinePayment.
 COD is a different kind of payment option — no false promise.
*/

protocol PaymentOption {

    var title: String { get }
}

protocol OnlinePayment: PaymentOption {

    func pay()
}

final class CardOption: OnlinePayment {

    let title = "Card"

    func pay() {
        print("Paid using Card")
    }
}

final class CashOnDeliveryOption: PaymentOption {

    let title = "Cash on Delivery"                                   // no pay() — honest contract
}

func checkout(with option: PaymentOption) {

    if let online = option as? OnlinePayment {
        online.pay()
    } else {
        print("Order placed — pay with \(option.title) later")
    }
}

func payNow(_ payment: OnlinePayment) {                              // accepts only types that CAN pay

    payment.pay()
}

checkout(with: CardOption())

checkout(with: CashOnDeliveryOption())

payNow(CardOption())

// payNow(CashOnDeliveryOption())   ❌ compile error — the type system prevents the bug

print("DEBUG Q03 - ✅ Every OnlinePayment really pays")


// ============================================================
// MARK: - 8. ❌ Classic Trap — Rectangle / Square
// ============================================================

/*
 "A square IS a rectangle" — true in math, wrong in code.

 Code expects: set width, height stays the same.
 Square changes BOTH → breaks the expectation.
*/

class Rectangle {

    var width: Double = 0
    var height: Double = 0

    func setWidth(_ value: Double) { width = value }
    func setHeight(_ value: Double) { height = value }

    var area: Double { width * height }
}

final class Square: Rectangle {

    override func setWidth(_ value: Double) {
        width = value
        height = value                                               // ❌ surprise side effect
    }

    override func setHeight(_ value: Double) {
        width = value
        height = value
    }
}

func resize(_ rectangle: Rectangle) -> Double {

    rectangle.setWidth(5)
    rectangle.setHeight(4)
    return rectangle.area                                            // expected 20
}

print("DEBUG Q04 - Rectangle area:", resize(Rectangle()))           // 20.0 ✅

print("DEBUG Q05 - Square area:", resize(Square()))                 // 16.0 ❌ not 20


// ============================================================
// MARK: - 9. ✅ Fix — Shared Protocol, No Inheritance
// ============================================================

protocol Shape {

    var area: Double { get }
}

struct RectangleShape: Shape {

    let width: Double
    let height: Double

    var area: Double { width * height }
}

struct SquareShape: Shape {

    let side: Double

    var area: Double { side * side }
}

let shapes: [Shape] = [RectangleShape(width: 5, height: 4), SquareShape(side: 4)]

for shape in shapes {
    print("DEBUG Q06 - Area:", shape.area)                          // 20.0, 16.0 — no broken promise
}


// ============================================================
// MARK: - 10. High-Level Flow
// ============================================================

/*
              PaymentMethod
                   ↑
             ┌─────┴─────┐
             ↓           ↓
        CardPayment   UPIPayment
             │           │
             └─────┬─────┘
                   ↓
            processPayment()


 Both implementations can safely replace PaymentMethod.

 No special handling is required.
*/


// ============================================================
// MARK: - 11. LSP Red Flags in iOS
// ============================================================

/*
 ❌ `if x is SomeSubtype` checks in client code
 ❌ Overrides that throw / fatalError("not supported")
 ❌ Overrides that silently do nothing
 ❌ UIView subclass overriding layoutSubviews without super
 ❌ Mock repository that behaves differently from the real one
    (tests pass, app breaks)
*/


// ============================================================
// MARK: - 12. Senior Point
// ============================================================

/*
 LSP is about BEHAVIOR.

 A subtype should honor the contract and expected behavior
 of the abstraction it replaces.
*/


// ============================================================
// MARK: - 13. Senior Interview Questions
// ============================================================

/*
 Q1. What is LSP?

 Answer:
 A subtype must be usable anywhere its base type is
 expected, without breaking behaviour.


 Q2. How do you spot an LSP violation?

 Answer:
 Client code needs type checks (`is` / `as?`) or a
 subtype throws, crashes or does nothing for a method.


 Q3. Explain the Rectangle / Square problem.

 Answer:
 Square overrides setWidth to also change height, so code
 expecting a rectangle gets the wrong area.


 Q4. How do you fix an LSP violation?

 Answer:
 Model real capabilities with separate protocols, or use
 composition instead of inheritance.


 Q5. Is LSP only about inheritance?

 Answer:
 No. It applies to protocol conformance too — every
 conforming type must honor the protocol's contract.


 Q6. How is LSP related to ISP?

 Answer:
 Fat protocols force types to fake methods they can't
 support; smaller protocols (ISP) prevent that.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

        ❌ VIOLATION

   PaymentMethod.pay()
        ↑
   CashOnDelivery.pay()  → does nothing
        ↓
   client: if payment is CashOnDelivery { ... }


        ✅ LSP

   OnlinePayment.pay()
        ↑
   Card · UPI         → all really pay

   PaymentOption
        ↑
   CashOnDelivery     → no false promise


 Remember:

 If the client must ask "which subtype are you?"
              ↓
          LSP is broken
*/


// ============================================================
// MARK: - Interview One-Liner
// ============================================================

/*
 "LSP means a subtype should be safely substitutable for
 its base abstraction without breaking expected behavior."
*/
