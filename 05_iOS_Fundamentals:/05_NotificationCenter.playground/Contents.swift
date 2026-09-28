import Foundation

//==============================================================
// MARK: - NotificationCenter
//==============================================================
//
// One-to-MANY broadcast. The poster doesn't know who is listening.
// post → every registered observer is called.
// Delivered SYNCHRONOUSLY on the thread that posted.
//


//==============================================================
// MARK: - 01. Custom Notification Names
//==============================================================
//
// Define names once — avoids typos in string literals.
//

extension Notification.Name {

    static let userDidLogout = Notification.Name("userDidLogout")

    static let cartDidUpdate = Notification.Name("cartDidUpdate")
}


//==============================================================
// MARK: - 02. One Post, Many Observers
//==============================================================
//
// Selector-based observer — auto-removed on dealloc (iOS 9+).
//

final class ProfileScreen: NSObject {

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .userDidLogout,
            object: nil
        )
    }

    @objc private func handleLogout() {
        print("ProfileScreen → clear user data")
    }
}

final class CartScreen: NSObject {

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(handleLogout),
            name: .userDidLogout,
            object: nil
        )
    }

    @objc private func handleLogout() {
        print("CartScreen → empty cart")
    }
}

print("\n========== 02 - One Post, Many Observers ==========")

let profileScreen = ProfileScreen()

let cartScreen = CartScreen()

NotificationCenter.default.post(name: .userDidLogout, object: nil)

// ProfileScreen → clear user data
// CartScreen → empty cart


//==============================================================
// MARK: - 03. Passing Data with userInfo
//==============================================================

print("\n========== 03 - Passing Data with userInfo ==========")

let cartToken = NotificationCenter.default.addObserver(
    forName: .cartDidUpdate,
    object: nil,
    queue: nil
) { notification in
    if let count = notification.userInfo?["count"] as? Int {
        print("Cart badge:", count)
    }
}

NotificationCenter.default.post(name: .cartDidUpdate, object: nil, userInfo: ["count": 3])   // Cart badge: 3


//==============================================================
// MARK: - 04. Removing Block-Based Observers
//==============================================================
//
// Block-based observers return a token — remove it yourself,
// usually in deinit. Capture [weak self] inside the block.
//
// token = NotificationCenter.default.addObserver(forName: ...) { [weak self] _ in
//     self?.reload()
// }
//
// deinit {
//     NotificationCenter.default.removeObserver(token)
// }
//

print("\n========== 04 - Removing Block-Based Observers ==========")

NotificationCenter.default.removeObserver(cartToken)

NotificationCenter.default.post(name: .cartDidUpdate, object: nil, userInfo: ["count": 5])   // nothing — removed

print("Observer removed — no badge update")


//==============================================================
// MARK: - 05. System Notifications
//==============================================================
//
// UIResponder.keyboardWillShowNotification      → move content above keyboard
// UIApplication.didBecomeActiveNotification     → refresh data
// UIApplication.didEnterBackgroundNotification  → save state
// UIApplication.didReceiveMemoryWarningNotification → clear caches
//


//==============================================================
// MARK: - 06. Threading
//==============================================================
//
// Observers run on the POSTING thread, synchronously.
// Post from background → UI update in observer must hop to main.
// Or register with queue: .main (block-based).
//
// Modern alternative:
// for await _ in NotificationCenter.default.notifications(named: .userDidLogout) { ... }
//


//==============================================================
// MARK: - 07. Delegate vs NotificationCenter
//==============================================================
//
// Delegate            → one-to-one, can return values, explicit relationship
// NotificationCenter  → one-to-many, fire-and-forget, loose coupling
//
// Overuse makes data flow hard to trace — prefer delegates / closures
// when there is only one listener.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is NotificationCenter?
//    → A one-to-many broadcast system — posters don't know who listens.
//
// 2. Delegate vs NotificationCenter?
//    → Delegate is one-to-one with return values; notifications are one-to-many.
//
// 3. How do you pass data with a notification?
//    → userInfo dictionary or the object parameter.
//
// 4. Do you need to remove observers?
//    → Selector-based: no (iOS 9+). Block-based: yes, remove the token.
//
// 5. On which thread are observers called?
//    → The thread that posted, synchronously — unless queue: .main is given.
//
// 6. How can block-based observers leak?
//    → The block captures self strongly — use [weak self] and remove the token.
//
// 7. What are downsides of NotificationCenter?
//    → Hard to trace flow, stringly-typed data, easy to overuse.
//
//==============================================================
