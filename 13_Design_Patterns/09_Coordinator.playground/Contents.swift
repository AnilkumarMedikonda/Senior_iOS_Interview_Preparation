import Foundation
import Combine
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - NOTIFICATIONCENTER (Observer Pattern, Apple Style)
// ============================================================

/*
 NotificationCenter = app-wide broadcast by NAME.

 Poster ──post(.cartDidChange)──→ NotificationCenter ──→ Observer 1
                                                     ├──→ Observer 2
                                                     └──→ Observer 3

 Poster and observers never know each other. One-to-many.
*/


// ============================================================
// MARK: - 1. Custom Notification Names
// ============================================================

extension Notification.Name {
    static let cartDidChange = Notification.Name("cartDidChange")
    static let userDidLogout = Notification.Name("userDidLogout")
}


// ============================================================
// MARK: - 2. Typed Payload (avoid raw userInfo strings)
// ============================================================

struct CartChange {

    static let key = "cartChange"

    let itemCount: Int
}


// ============================================================
// MARK: - 3. Selector-Based Observer
// ============================================================

/*
 Classic style. Since iOS 9, removed automatically when the observer
 deallocates — but removing in deinit is still fine.
*/

final class CartBadgeView: NSObject {

    override init() {
        super.init()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(cartChanged(_:)),
            name: .cartDidChange,
            object: nil
        )
    }

    @objc private func cartChanged(_ notification: Notification) {
        if let change = notification.userInfo?[CartChange.key] as? CartChange {
            print("🛒 Badge: \(change.itemCount)")
        }
    }
}


// ============================================================
// MARK: - 4. Block-Based Observer (must remove!)
// ============================================================

/*
 Returns a token. NOT removed automatically → keep the token, remove it.
 queue: .main → handler runs on main even if posted from background.
*/

final class CheckoutBanner {

    private var token: NSObjectProtocol?

    init() {
        token = NotificationCenter.default.addObserver(
            forName: .cartDidChange,
            object: nil,
            queue: .main
        ) { notification in
            if let change = notification.userInfo?[CartChange.key] as? CartChange {
                print("🔔 Banner: \(change.itemCount) item(s) — checkout ready")
            }
        }
    }

    deinit {
        if let token {
            NotificationCenter.default.removeObserver(token)  // ✅ clean up
        }
    }
}


// ============================================================
// MARK: - 5. Combine Publisher
// ============================================================

final class AnalyticsListener {

    private var cancellable: AnyCancellable?

    init() {
        cancellable = NotificationCenter.default
            .publisher(for: .userDidLogout)
            .sink { _ in
                print("📊 Analytics: logout tracked")
            }                                                // auto-removed when cancellable dies
    }
}


// ============================================================
// MARK: - 6. Posting
// ============================================================

func postCartChange(count: Int) {
    NotificationCenter.default.post(
        name: .cartDidChange,
        object: nil,
        userInfo: [CartChange.key: CartChange(itemCount: count)]
    )
}


// ============================================================
// MARK: - Run
// ============================================================

let badge = CartBadgeView()

var banner: CheckoutBanner? = CheckoutBanner()

let analytics = AnalyticsListener()

print("\n========== 06 - Post → All Observers ==========")

postCartChange(count: 2)                                     // badge + banner

print("\n========== 04 - Banner Removed ==========")

banner = nil                                                 // token removed in deinit

postCartChange(count: 3)                                     // only badge now

print("\n========== 05 - Combine Observer ==========")

NotificationCenter.default.post(name: .userDidLogout, object: nil)

Task {

    print("\n========== 07 - async Sequence (iOS 15+) ==========")

    let listener = Task {
        for await _ in NotificationCenter.default.notifications(named: .userDidLogout) {
            print("⚡️ async: logout received")
            break
        }
    }

    try? await Task.sleep(for: .milliseconds(50))

    NotificationCenter.default.post(name: .userDidLogout, object: nil)

    await listener.value

    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 8. System Notifications You'll Use
// ============================================================

/*
 UIApplication.didEnterBackgroundNotification
 UIApplication.willEnterForegroundNotification
 UIResponder.keyboardWillShowNotification
 UIContentSizeCategory.didChangeNotification
 NSNotification.Name.NSManagedObjectContextDidSave
*/


// ============================================================
// MARK: - 9. Pitfalls
// ============================================================

/*
 ❌ Block observer never removed → callbacks on dead screens, leaks
 ❌ Strong self inside the block → retain cycle ([weak self])
 ❌ Posting from a background thread → handler runs there (use queue: .main)
 ❌ Stringly-typed userInfo → typed payload struct
 ❌ Using it for one-to-one communication → delegate / closure is clearer
 ❌ Too many notifications → hard to trace who triggered what
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is NotificationCenter?
     → Apple's broadcast system: post by name, any number of observers receive it.

 Q2. Which design pattern is it?
     → Observer (publish–subscribe).

 Q3. Selector vs block observers — removal?
     → Selector observers auto-remove since iOS 9; block observers must be removed via their token.

 Q4. On which thread is the handler called?
     → The posting thread, unless you pass queue: .main.

 Q5. NotificationCenter vs Delegate?
     → Notifications broadcast one-to-many with no return value; delegate is one-to-one and can return.

 Q6. Modern alternatives?
     → Combine publisher(for:) and async notifications(named:).
*/
