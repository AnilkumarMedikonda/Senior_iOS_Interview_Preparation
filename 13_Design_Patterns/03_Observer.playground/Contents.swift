import Foundation
import Combine

// ============================================================
// MARK: - OBSERVER PATTERN
// ============================================================

/*
 Observer = one object (Subject) notifies MANY objects
 (Observers) automatically when its state changes.

 Subject (CartStore)
      │ state changes
      ├──→ Observer 1 (Cart badge)
      ├──→ Observer 2 (Checkout button)
      └──→ Observer 3 (Analytics)

 Subject doesn't know WHO observes — only that they conform.
*/


// ============================================================
// MARK: - 1. Custom Observer (Protocol + Weak References)
// ============================================================

protocol CartObserver: AnyObject {                          // AnyObject → can be held weakly
    func cartDidChange(itemCount: Int)
}

// Box so the Subject holds observers WEAKLY → no retain cycles / leaks
private struct WeakObserver {
    weak var value: CartObserver?
}

final class CartStore {

    private var observers: [WeakObserver] = []

    private(set) var itemCount = 0 {
        didSet { notifyObservers() }                         // state change → notify
    }

    func addObserver(_ observer: CartObserver) {
        observers.append(WeakObserver(value: observer))
    }

    func removeObserver(_ observer: CartObserver) {
        observers.removeAll { $0.value === observer }
    }

    func addItem() {
        itemCount += 1
    }

    private func notifyObservers() {
        observers.removeAll { $0.value == nil }              // drop deallocated observers
        for observer in observers {
            observer.value?.cartDidChange(itemCount: itemCount)
        }
    }
}

final class CartBadge: CartObserver {
    func cartDidChange(itemCount: Int) {
        print("🛒 Badge shows \(itemCount)")
    }
}

final class CheckoutButton: CartObserver {
    func cartDidChange(itemCount: Int) {
        print("🔘 Checkout \(itemCount > 0 ? "enabled" : "disabled")")
    }
}

print("\n========== 01 - Custom Observer ==========")

let cart = CartStore()

let badge = CartBadge()

var checkout: CheckoutButton? = CheckoutButton()

cart.addObserver(badge)

if let checkout {
    cart.addObserver(checkout)
}

cart.addItem()                                               // both observers notified

checkout = nil                                               // observer deallocated — weak, no leak

cart.addItem()                                               // only badge notified


// ============================================================
// MARK: - 2. NotificationCenter (Broadcast)
// ============================================================

/*
 One-to-many broadcast by name. Poster and observers don't know each other.
 Good for app-wide events: logout, theme change, keyboard, app lifecycle.
*/

extension Notification.Name {
    static let userDidLogout = Notification.Name("userDidLogout")
}

print("\n========== 02 - NotificationCenter ==========")

let logoutToken = NotificationCenter.default.addObserver(
    forName: .userDidLogout,
    object: nil,
    queue: .main
) { notification in
    print("📣 Logout received — reason:", notification.userInfo?["reason"] as Any)
}

NotificationCenter.default.post(
    name: .userDidLogout,
    object: nil,
    userInfo: ["reason": "token expired"]
)

NotificationCenter.default.removeObserver(logoutToken)       // block observers must be removed


// ============================================================
// MARK: - 3. KVO (Key-Value Observing)
// ============================================================

/*
 Observe a property of an NSObject. Needs @objc dynamic.
 Used for UIKit/AVFoundation properties (e.g. AVPlayer.status, WKWebView.estimatedProgress).
*/

final class DownloadTask: NSObject {
    @objc dynamic var progress: Double = 0
}

print("\n========== 03 - KVO ==========")

let download = DownloadTask()

let progressObservation = download.observe(\.progress, options: [.new]) { _, change in
    if let value = change.newValue {
        print("⬇️ Progress:", value)
    }
}

download.progress = 0.5

download.progress = 1.0

progressObservation.invalidate()                             // stop observing


// ============================================================
// MARK: - 4. Combine (@Published)
// ============================================================

/*
 Modern Swift observer: @Published property + sink.
 Subscription lives as long as the AnyCancellable.
*/

final class PriceStore {
    @Published var price = 4999
}

print("\n========== 04 - Combine ==========")

let priceStore = PriceStore()

var cancellables = Set<AnyCancellable>()

priceStore.$price
    .dropFirst()                                             // skip current value
    .sink { newPrice in
        print("💰 New price: ₹\(newPrice)")
    }
    .store(in: &cancellables)

priceStore.price = 3999

priceStore.price = 2999

// SwiftUI: @Observable / ObservableObject → views are the observers


// ============================================================
// MARK: - 5. Observer vs Delegate
// ============================================================

/*
 ┌──────────────────┬────────────────────────┬──────────────────────────┐
 │                  │ Delegate               │ Observer                 │
 ├──────────────────┼────────────────────────┼──────────────────────────┤
 │ Relationship     │ One-to-one             │ One-to-many              │
 │ Return values    │ Yes (can answer back)  │ No — just "this changed" │
 │ Coupling         │ Knows its delegate     │ Subject doesn't know who │
 │ iOS example      │ UITableViewDelegate    │ NotificationCenter, KVO  │
 └──────────────────┴────────────────────────┴──────────────────────────┘
*/


// ============================================================
// MARK: - 6. iOS Options — Which One?
// ============================================================

/*
 Custom protocol + weak list → full control, type-safe
 NotificationCenter          → app-wide broadcast events
 KVO                         → observe Apple NSObject properties
 Combine @Published          → reactive streams, ViewModels (UIKit)
 @Observable                 → SwiftUI state (iOS 17+)
*/


// ============================================================
// MARK: - 7. Pitfalls
// ============================================================

/*
 ❌ Strong references to observers → retain cycles / leaks  → hold weakly
 ❌ Forgetting to remove block observers / invalidate KVO    → callbacks on dead screens
 ❌ Notifications posted on a background thread               → UI updates must hop to main
 ❌ Too many notifications                                    → hard to trace who changed what
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is the Observer pattern?
     → A subject notifies many observers automatically when its state changes.

 Q2. Observer vs Delegate?
     → Delegate is one-to-one and can return values; Observer is one-to-many broadcast.

 Q3. Why hold observers weakly?
     → So the subject doesn't keep them alive — avoids leaks and retain cycles.

 Q4. What Observer options does iOS provide?
     → NotificationCenter, KVO, Combine, and @Observable / ObservableObject.

 Q5. When would you use NotificationCenter?
     → App-wide events many unrelated parts care about, like logout or theme change.

 Q6. What does KVO need?
     → An NSObject subclass with @objc dynamic properties.

 Q7. Biggest risk of NotificationCenter?
     → Hidden, hard-to-trace flows and missing cleanup of block observers.
*/
