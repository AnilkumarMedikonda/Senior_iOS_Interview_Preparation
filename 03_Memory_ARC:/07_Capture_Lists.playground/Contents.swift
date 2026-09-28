import Foundation

//==============================================================
// MARK: - Capture Lists
//==============================================================
//
// [ ... ] in → decides HOW a closure captures values.
// [x]            → copy of x at creation (strong if x is a class)
// [weak self]    → no +1, self becomes nil when freed
// [unowned self] → no +1, crash if self is freed
// [name = expr]  → capture a specific value instead of self
//


//==============================================================
// MARK: - 01. Value Capture
//==============================================================
//
// Captured once, when the closure is created.
//

print("\n========== 01 - Value Capture ==========")

var count = 1

let snapshot = { [count] in print("Snapshot:", count) }

count = 5

snapshot()                               // Snapshot: 1


//==============================================================
// MARK: - 02. [weak self]
//==============================================================
//
// Use when the closure may outlive self (network callbacks, timers).
//

final class ProfileViewModel {

    let name = "Profile"

    var onUpdate: (() -> Void)?

    func bind() {
        onUpdate = { [weak self] in
            guard let self else { return }
            print("Updated:", self.name)
        }
    }

    deinit {
        print("ProfileViewModel deinit")
    }
}

print("\n========== 02 - [weak self] ==========")

var profileVM: ProfileViewModel? = ProfileViewModel()

profileVM?.bind()

profileVM?.onUpdate?()                   // Updated: Profile

profileVM = nil                          // ProfileViewModel deinit


//==============================================================
// MARK: - 03. [unowned self]
//==============================================================
//
// Safe only when the closure can never outlive self.
// Here self owns the closure → closure dies with self.
//

final class PriceFormatter {

    let currency = "₹"

    lazy var format: (Int) -> String = { [unowned self] price in
        "\(self.currency)\(price)"
    }

    deinit {
        print("PriceFormatter deinit")
    }
}

print("\n========== 03 - [unowned self] ==========")

var formatter: PriceFormatter? = PriceFormatter()

print(formatter?.format(499) as Any)     // Optional("₹499")

formatter = nil                          // PriceFormatter deinit


//==============================================================
// MARK: - 04. Capture a Value Instead of self
//==============================================================
//
// Capture only what the closure needs → self isn't captured at all.
//

final class OrderScreen {

    let orderID = "ORD-101"

    var onShare: (() -> Void)?

    func setup() {
        onShare = { [orderID] in
            print("Sharing", orderID)    // no self → no cycle
        }
    }

    deinit {
        print("OrderScreen deinit")
    }
}

print("\n========== 04 - Capture a Value Instead of self ==========")

var orderScreen: OrderScreen? = OrderScreen()

orderScreen?.setup()

orderScreen?.onShare?()                  // Sharing ORD-101

orderScreen = nil                        // OrderScreen deinit


//==============================================================
// MARK: - 05. [self] Is Still Strong
//==============================================================
//
// A capture list alone doesn't break a cycle.
// [self] / [object] captures STRONGLY — only weak / unowned break it.
//

final class ChatScreen {

    var onSend: (() -> Void)?

    func setup() {
        onSend = { [self] in
            print(self)                  // ❌ still strong → cycle
        }
    }

    deinit {
        print("ChatScreen deinit")
    }
}

print("\n========== 05 - [self] Is Still Strong ==========")

var chatScreen: ChatScreen? = ChatScreen()

chatScreen?.setup()

chatScreen = nil

// No deinit printed — leaked


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a capture list?
//    → Syntax that controls how a closure captures values: copy, weak, or unowned.
//
// 2. { print(x) } vs { [x] in print(x) }?
//    → First reads x when called. Second copies x when the closure is created.
//
// 3. When do you use [weak self] vs [unowned self]?
//    → weak if the closure may outlive self. unowned only if it never can.
//
// 4. Does [self] prevent a retain cycle?
//    → No. It captures strongly — only weak or unowned break the cycle.
//
// 5. How can you avoid capturing self entirely?
//    → Capture only the needed value: [orderID] or [name = self.name].
//
//==============================================================
