import UIKit

// ============================================================
// MARK: - 02_iOS_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Each question:
 1. Question + short spoken answer
 2. Follow-up the interviewer usually asks
 3. A tiny code proof with DEBUG output (where code helps)

 Answer out loud BEFORE reading.
*/


// ============================================================
// MARK: - Q01. App States
// ============================================================

/*
 Q: What are the app states?

 Answer:
 Not running, inactive, active, background, suspended.
 Suspended apps can be killed without notice.

 Follow-up: where to save data?
 → sceneDidEnterBackground.
*/

enum AppState: String, CaseIterable {
    case notRunning, inactive, active, background, suspended
}

print("DEBUG Q01 -", AppState.allCases.map(\.rawValue).joined(separator: " → "))


// ============================================================
// MARK: - Q02. AppDelegate vs SceneDelegate
// ============================================================

/*
 Q: AppDelegate vs SceneDelegate?

 Answer:
 AppDelegate → app-wide: launch, push registration,
               background URLSession.
 SceneDelegate → one window's UI lifecycle + deep links.

 Follow-up: cold-start deep link?
 → scene(_:willConnectTo:options:) → connectionOptions.
*/

print("DEBUG Q02 - App events → AppDelegate | Window events → SceneDelegate")


// ============================================================
// MARK: - Q03. ViewController Lifecycle (Push A → B)
// ============================================================

/*
 Q: View controller lifecycle order?

 Answer:
 loadView → viewDidLoad (once) → viewWillAppear →
 viewIsAppearing → viewDidAppear → viewWillDisappear →
 viewDidDisappear.

 Follow-up: push A → B order?
*/

let pushOrder = [
    "B.viewDidLoad",
    "A.viewWillDisappear",
    "B.viewWillAppear",
    "A.viewDidDisappear",
    "B.viewDidAppear"
]

print("DEBUG Q03 - Push A → B:", pushOrder.joined(separator: " → "))


// ============================================================
// MARK: - Q04. Where NOT to Put Work
// ============================================================

/*
 Q: Where should you NOT put work?

 Answer:
 ❌ Heavy main-thread work in viewDidLoad / viewWillAppear
 ❌ Frame-based layout in viewDidLoad (bounds not final)
 ✅ viewDidLayoutSubviews or Auto Layout for frames
 ✅ Background work for loading
*/

print("DEBUG Q04 - viewDidLoad = one-time setup, not frame math")


// ============================================================
// MARK: - Q05. Delegate vs Closure vs NotificationCenter
// ============================================================

/*
 Q: Delegate vs closure vs NotificationCenter?

 Answer:
 Delegate → one listener, many callbacks, can return values
 Closure  → one simple callback
 Notification → broadcast to many

 Follow-up: wrong use of notifications?
 → One-to-one communication.
*/

protocol CartCellDelegate: AnyObject {
    func didTapAdd(productID: Int)
}

final class CartCell {

    weak var delegate: CartCellDelegate?                    // delegate

    var onRemove: ((Int) -> Void)?                          // closure

    func tapAdd() { delegate?.didTapAdd(productID: 42) }

    func tapRemove() { onRemove?(42) }
}

final class CartScreen: CartCellDelegate {

    let cell = CartCell()

    init() {
        cell.delegate = self
        cell.onRemove = { id in print("DEBUG Q05 - closure: remove \(id)") }
    }

    func didTapAdd(productID: Int) {
        print("DEBUG Q05 - delegate: add \(productID)")
    }

    deinit { print("DEBUG Q06 - CartScreen freed ✅ (weak delegate)") }
}

var cartScreen: CartScreen? = CartScreen()

cartScreen?.cell.tapAdd()

cartScreen?.cell.tapRemove()


// ============================================================
// MARK: - Q06. Why Weak Delegate
// ============================================================

/*
 Q: Why is the delegate weak?

 Answer:
 Owner → child is strong; child → delegate (owner) strong
 would be a retain cycle.
*/

cartScreen = nil                                             // deinit prints


// ============================================================
// MARK: - Q07. URL Scheme vs Universal Link
// ============================================================

/*
 Q: Custom URL scheme vs Universal Links?

 Answer:
 Scheme (myapp://) → easy, can be hijacked, fails if not installed
 Universal (https) → verified by AASA, falls back to website
*/

enum Route: Equatable {
    case product(id: Int)
    case cart
}

func route(from url: URL) -> Route? {
    let parts = url.pathComponents.filter { $0 != "/" }
    if parts.first == "product", parts.count > 1, let id = Int(parts[1]) {
        return .product(id: id)
    }
    if parts.first == "cart" {
        return .cart
    }
    return nil
}

if let universal = URL(string: "https://shop.com/product/42") {
    print("DEBUG Q07 - universal link →", route(from: universal) as Any)
}


// ============================================================
// MARK: - Q08. Cold vs Warm Start Deep Link
// ============================================================

/*
 Q: Deep link on cold vs warm start?

 Answer:
 Cold → store a pending route until UI is ready.
 Warm → route immediately. One router for both.
*/

final class DeepLinkRouter {

    private var pendingRoute: Route?

    private(set) var isUIReady = false

    func handle(_ route: Route) {
        if isUIReady {
            print("DEBUG Q08 - warm: navigate to", route)
        } else {
            pendingRoute = route
            print("DEBUG Q08 - cold: saved pending", route)
        }
    }

    func uiDidBecomeReady() {
        isUIReady = true
        if let pendingRoute {
            print("DEBUG Q08 - cold: now navigate to", pendingRoute)
            self.pendingRoute = nil
        }
    }
}

let router = DeepLinkRouter()

router.handle(.product(id: 42))                              // cold start

router.uiDidBecomeReady()

router.handle(.cart)                                         // warm start


// ============================================================
// MARK: - Q09. Push Flow + Device Token
// ============================================================

/*
 Q: Explain the push flow.

 Answer:
 Permission → register → device token → your server →
 server sends payload + token to APNs → device.

 Follow-up: token to string?
 → Each byte as two hex characters.
*/

let fakeToken = Data([0xDE, 0xAD, 0xBE, 0xEF])

let tokenString = fakeToken.map { String(format: "%02x", $0) }.joined()

print("DEBUG Q09 - token hex:", tokenString)                // deadbeef


// ============================================================
// MARK: - Q10. Foreground vs Tap
// ============================================================

/*
 Q: Foreground vs tap handling?

 Answer:
 willPresent → app in foreground: show banner or not
 didReceive  → user tapped: route to the screen

 Follow-up: silent push?
 → content-available: 1, no alert, wakes app briefly,
   throttled, not guaranteed.
*/

print("DEBUG Q10 - foreground → willPresent | tap → didReceive")


// ============================================================
// MARK: - Q11. Cell Reuse + Stale Image Bug
// ============================================================

/*
 Q: How does cell reuse work?

 Answer:
 Few cells created, reused while scrolling,
 prepareForReuse resets them.

 Follow-up: wrong image in a cell?
 → Async load finished after reuse — check the cell still
   shows the same item.
*/

final class ProductCell {

    var representedID: Int?

    var imageName: String?

    func prepareForReuse() {
        representedID = nil
        imageName = nil
    }

    func configure(id: Int) {
        representedID = id
        loadImage(for: id)
    }

    private func loadImage(for id: Int) {
        // pretend this finishes later
        let finishedImage = "image-\(id)"
        guard representedID == id else {                     // ✅ stale check
            print("DEBUG Q11 - ignored stale image for", id)
            return
        }
        imageName = finishedImage
    }
}

let reusedCell = ProductCell()

reusedCell.configure(id: 1)

reusedCell.prepareForReuse()

reusedCell.configure(id: 2)

print("DEBUG Q11 - cell shows:", reusedCell.imageName as Any)  // image-2


// ============================================================
// MARK: - Q12. frame vs bounds
// ============================================================

/*
 Q: frame vs bounds?

 Answer:
 frame → superview coordinates; bounds → own coordinates.
 Rotation changes frame, not bounds.
*/

let box = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))

box.transform = CGAffineTransform(rotationAngle: .pi / 4)

print("DEBUG Q12 - frame:", box.frame.size, "| bounds:", box.bounds.size)   // ~141 | 100


// ============================================================
// MARK: - Q13. setNeedsLayout vs layoutIfNeeded
// ============================================================

/*
 Q: setNeedsLayout vs layoutIfNeeded?

 Answer:
 setNeedsLayout → mark dirty, layout next cycle (cheap, batched)
 layoutIfNeeded → layout NOW (used in constraint animations)
*/

print("DEBUG Q13 - change constraint → UIView.animate { layoutIfNeeded() }")


// ============================================================
// MARK: - Q14. Hugging vs Compression Resistance
// ============================================================

/*
 Q: Content hugging vs compression resistance?

 Answer:
 Hugging → don't grow bigger than content
 Compression → don't shrink smaller than content
 Higher priority wins.

 Example: name + price label in one row
 → price: high hugging + high compression (never truncated)
*/

print("DEBUG Q14 - price label keeps its size, name label stretches/truncates")


// ============================================================
// MARK: - Q15. Dynamic Cell Height
// ============================================================

/*
 Q: How do you build dynamic-height cells?

 Answer:
 Constraints top → bottom inside contentView,
 numberOfLines = 0, automatic dimension + estimated height.
*/

print("DEBUG Q15 - missing bottom constraint → cell height 0")


// ============================================================
// MARK: - Q16. Diffable Data Source
// ============================================================

/*
 Q: Why diffable data sources?

 Answer:
 Apply snapshots; UIKit computes inserts / deletes / moves.
 No "invalid number of rows" crashes, free animations.
*/

let oldItems = ["Shoes", "Cap"]

let newItems = ["Cap", "Socks"]

let changes = newItems.difference(from: oldItems)

print("DEBUG Q16 - diff:", changes.map { change -> String in
    switch change {
    case .insert(_, let element, _): return "+\(element)"
    case .remove(_, let element, _): return "-\(element)"
    }
})


// ============================================================
// MARK: - Q17. Background Execution
// ============================================================

/*
 Q: Background options?

 Answer:
 beginBackgroundTask (finish short work), BGTaskScheduler
 (refresh / processing), background URLSession (transfers),
 silent push.

 Follow-up: guaranteed?
 → No, the system decides.
*/

print("DEBUG Q17 - BG tasks run when the SYSTEM decides")


// ============================================================
// MARK: - Q18. Where to Store What
// ============================================================

/*
 Q: UserDefaults vs Keychain vs Core Data vs files?

 Answer:
 Settings → UserDefaults
 Secrets  → Keychain
 Structured data → Core Data / SwiftData
 Blobs    → files (Caches / Documents)
*/

let storageMap = [
    "theme": "UserDefaults",
    "accessToken": "Keychain",
    "orders": "Core Data",
    "productImage": "Caches folder"
]

for key in ["theme", "accessToken", "orders", "productImage"] {
    if let place = storageMap[key] {
        print("DEBUG Q18 -", key, "→", place)
    }
}


// ============================================================
// MARK: - Q19. Core Data Threading
// ============================================================

/*
 Q: Core Data threading rule?

 Answer:
 Objects belong to their context's queue.
 viewContext on main, background context for heavy work,
 pass NSManagedObjectID between threads.
*/

print("DEBUG Q19 - pass objectID, never the managed object, across threads")


// ============================================================
// MARK: - Q20. Offline-First
// ============================================================

/*
 Q: How do you design offline-first?

 Answer:
 Local DB = source of truth, UI reads it immediately,
 network refreshes it, offline writes go to an outbox.
*/

print("DEBUG Q20 - read local → refresh remote → sync outbox")


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Lifecycle     → right work in the right callback
   Communication → delegate (1:1) · closure · notification (1:many)
   Deep links    → one router, pending route for cold start
   Push          → token → server → APNs → willPresent / didReceive
   Lists         → reuse + diffable + stale-check
   Storage       → Defaults · Keychain · Core Data · files


 Senior One-Liner:

 "I keep lifecycle work in the right callbacks, route deep
  links and push taps through one coordinator, build lists
  with reuse and diffable data sources, and store each kind
  of data in the right place."
*/
