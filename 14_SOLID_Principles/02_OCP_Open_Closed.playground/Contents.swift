import Foundation

// ============================================================
// MARK: - OCP: OPEN / CLOSED PRINCIPLE
// ============================================================

/*
 Definition:

 Software should be:

 OPEN FOR EXTENSION
 CLOSED FOR MODIFICATION

 Meaning:

 We should be able to add new behavior without repeatedly
 changing existing, stable code.
*/


// ============================================================
// MARK: - 1. ❌ Bad Example
// ============================================================

/*
 Every new payment type requires modifying PaymentProcessor.

 This violates OCP.
*/

final class OldPaymentProcessor {

    func process(type: String) {

        if type == "card" {
            print("Card payment")
        } else if type == "upi" {
            print("UPI payment")
        } else {
            print("❌ Unsupported: \(type) — must edit this class to add it")
        }
    }
}

let oldProcessor = OldPaymentProcessor()

oldProcessor.process(type: "card")

oldProcessor.process(type: "applePay")

print("DEBUG Q01 - ❌ New type = modify OldPaymentProcessor")


// ============================================================
// MARK: - 2. ✅ OCP Solution
// ============================================================

/*
 Define an abstraction.

 New payment types can conform to PaymentMethod without
 modifying PaymentProcessor.
*/

protocol PaymentMethod {

    func pay()
}


// ============================================================
// MARK: - 3. Concrete Payment Types
// ============================================================

final class CardPayment: PaymentMethod {

    func pay() {
        print("Card payment")
    }
}


final class UPIPayment: PaymentMethod {

    func pay() {
        print("UPI payment")
    }
}


final class ApplePay: PaymentMethod {

    func pay() {
        print("Apple Pay payment")
    }
}


// ============================================================
// MARK: - 4. Payment Processor
// ============================================================

/*
 PaymentProcessor depends on the abstraction:

 PaymentMethod

 It does NOT depend on:

 CardPayment
 UPIPayment
 ApplePay
*/

final class PaymentProcessor {

    func process(_ payment: PaymentMethod) {
        payment.pay()
    }
}


// ============================================================
// MARK: - 5. Usage
// ============================================================

let processor = PaymentProcessor()

processor.process(CardPayment())
processor.process(UPIPayment())
processor.process(ApplePay())

print("DEBUG Q02 - ✅ Processor works with any PaymentMethod")


// ============================================================
// MARK: - 6. Adding New Payment
// ============================================================

/*
 We can add a new payment without modifying
 PaymentProcessor.
*/

final class PayPalPayment: PaymentMethod {

    func pay() {
        print("PayPal payment")
    }
}

processor.process(PayPalPayment())

print("DEBUG Q03 - ✅ PayPal added — PaymentProcessor unchanged")


// ============================================================
// MARK: - 7. High-Level Flow
// ============================================================

/*

                 PaymentProcessor
                        │ depends on
                        ↓
                  PaymentMethod (protocol)
                        ↑ conforms
       ┌────────────┬───┴────────┬─────────────┐
       │            │            │             │
  CardPayment   UPIPayment    ApplePay    PayPalPayment  ← NEW


Add new payment:

NewPayment: PaymentMethod

No change required in PaymentProcessor.
*/


// ============================================================
// MARK: - 8. OCP in iOS
// ============================================================

/*
 Protocols + new conforming types     → PaymentMethod above
 Extensions                           → add behaviour to existing types
 UITableViewCell subclasses           → new cell types, same table code
 SwiftUI ViewModifier                 → new styling without editing views
 Strategy pattern                     → swap algorithms (sorting, pricing)

 Red flag:
 A growing switch / if-else on a "type" that you edit
 every time a new case is added.
*/


// ============================================================
// MARK: - 9. Senior Interview Point
// ============================================================

/*
 OCP does NOT mean:

 "Never modify existing code."

 It means:

 New behavior should preferably be added through
 abstraction/extension instead of repeatedly modifying
 stable existing logic.
*/


// ============================================================
// MARK: - 10. Senior Interview Questions
// ============================================================

/*
 Q1. What is the Open/Closed Principle?

 Answer:
 Code should be open for extension but closed for
 modification — add new behaviour without editing
 stable code.


 Q2. How do you apply OCP in Swift?

 Answer:
 Depend on a protocol and add new conforming types
 instead of growing if-else / switch statements.


 Q3. What is a common OCP violation?

 Answer:
 A switch on a type that must be edited every time
 a new case is added.


 Q4. Does OCP mean you never change existing code?

 Answer:
 No. Bug fixes and refactors are fine. OCP is about
 adding NEW behaviour without touching stable logic.


 Q5. Which pattern helps with OCP?

 Answer:
 Strategy — new algorithms are new types behind
 one protocol.


 Q6. How is OCP related to DIP?

 Answer:
 Both depend on abstractions. DIP decides the
 dependency direction; OCP uses it to allow extension.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

        ❌ BEFORE

   process(type:)
     if card  → ...
     if upi   → ...
     if NEW   → EDIT this class every time


        ✅ AFTER

   PaymentProcessor → PaymentMethod
                          ↑
          Card · UPI · ApplePay · NEW (just add a type)


 Remember:

 New feature
      =
 New type
      ≠
 Edit old code
*/


// ============================================================
// MARK: - Interview One-Liner
// ============================================================

/*
 "Open/Closed Principle means software should be open for
 extension but closed for modification."
*/
