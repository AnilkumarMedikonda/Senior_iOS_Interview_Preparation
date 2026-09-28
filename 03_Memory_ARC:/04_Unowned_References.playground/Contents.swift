import Foundation

//==============================================================
// MARK: - Unowned References
//==============================================================
//
// unowned = does NOT increase the strong count (like weak).
// But it is NOT Optional and is NOT set to nil.
// Accessing it after the object is freed → crash.
// Use only when the other object always lives as long or longer.
//


//==============================================================
// MARK: - 01. Customer ↔ Card
//==============================================================
//
// A card can't exist without a customer.
// Customer owns Card (strong). Card → Customer (unowned).
//

final class Customer {

    let name: String

    var card: CreditCard?

    init(name: String) {
        self.name = name
    }

    deinit {
        print("Customer deinit")
    }
}

final class CreditCard {

    unowned let customer: Customer   // non-optional, can be let

    init(customer: Customer) {
        self.customer = customer
    }

    deinit {
        print("CreditCard deinit")
    }
}

print("\n========== 01 - Customer ↔ Card ==========")

var customer: Customer? = Customer(name: "Anil")

customer?.card = CreditCard(customer: customer!)

print(customer?.card?.customer.name as Any)   // Optional("Anil")

customer = nil                                // Customer deinit → CreditCard deinit


//==============================================================
// MARK: - 02. The Crash Risk
//==============================================================
//
// If the owner is freed first, unowned points to freed memory.
//

print("\n========== 02 - The Crash Risk ==========")

var owner: Customer? = Customer(name: "Ravi")

let card = CreditCard(customer: owner!)

owner = nil                                   // Customer deinit

// print(card.customer.name)                  ❌ Crash — customer already freed


//==============================================================
// MARK: - 03. weak vs unowned
//==============================================================
//
// ┌──────────────┬───────────────────────┬────────────────────────┐
// │              │ weak                  │ unowned                │
// ├──────────────┼───────────────────────┼────────────────────────┤
// │ Count        │ No +1                 │ No +1                  │
// │ Type         │ Optional, var         │ Non-optional, let/var  │
// │ Object freed │ Becomes nil           │ Dangling → crash       │
// │ Use when     │ May outlive the other │ Never outlives it      │
// │ Example      │ Delegates             │ Card → Customer        │
// └──────────────┴───────────────────────┴────────────────────────┘
//
// When unsure → weak. unowned is a promise; breaking it crashes.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is an unowned reference?
//    → A non-owning, non-optional reference — no +1, never set to nil.
//
// 2. weak vs unowned?
//    → weak → Optional, becomes nil. unowned → non-optional, crashes if accessed after free.
//
// 3. When is unowned safe to use?
//    → When the referenced object always lives as long or longer (Card → Customer).
//
// 4. What happens if you access an unowned reference after deallocation?
//    → Runtime crash — it points to freed memory.
//
// 5. Why can unowned be let but weak cannot?
//    → unowned never changes. weak must be var because ARC sets it to nil.
//
//==============================================================
