import UIKit

//==============================================================
// MARK: - UIView & UIViewController
//==============================================================
//
// UIView           → draws content, handles touches, lays out subviews.
// UIViewController → owns a root view, manages its lifecycle,
//                    handles navigation and coordinates data.
// A view controller has ONE root view; that view has many subviews.
//


//==============================================================
// MARK: - 01. Who Does What
//==============================================================
//
// ┌──────────────────────┬────────────────────────┬────────────────────────────┐
// │                      │ UIView                 │ UIViewController           │
// ├──────────────────────┼────────────────────────┼────────────────────────────┤
// │ Responsibility       │ Drawing, layout, touch │ Lifecycle, navigation      │
// │ Lifecycle callbacks  │ layoutSubviews,        │ viewDidLoad, viewWillAppear│
// │                      │ didMoveToWindow        │ viewDidAppear, …           │
// │ Owns                 │ Subviews               │ Root view + child VCs      │
// │ Reusable             │ Yes — anywhere         │ One screen / section       │
// └──────────────────────┴────────────────────────┴────────────────────────────┘
//


//==============================================================
// MARK: - 02. View Hierarchy
//==============================================================
//
// addSubview → added on TOP (last in subviews = front-most).
// A view has one superview — adding it elsewhere removes it from the old one.
//

print("\n========== 02 - View Hierarchy ==========")

let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 200))

let background = UIView()

let badge = UILabel()

container.addSubview(background)

container.addSubview(badge)                          // on top of background

print("Subviews:", container.subviews.count)         // 2

print("Front-most is badge:", container.subviews.last === badge)   // true

print("Badge superview is container:", badge.superview === container)   // true

container.bringSubviewToFront(background)

print("After bringToFront:", container.subviews.last === background)   // true

badge.removeFromSuperview()

print("After remove:", container.subviews.count)     // 1


//==============================================================
// MARK: - 03. Custom UIView
//==============================================================
//
// Code-based view: init(frame:) + required init?(coder:).
// Keep it dumb — configure with data, don't fetch data.
//

final class PriceTagView: UIView {

    private let priceLabel = UILabel()

    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubview(priceLabel)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func configure(price: Int) {
        priceLabel.text = "₹\(price)"
    }

    var displayedText: String {
        if let text = priceLabel.text {
            return text
        }
        return ""
    }
}

print("\n========== 03 - Custom UIView ==========")

let priceTag = PriceTagView(frame: .zero)

priceTag.configure(price: 4999)

print(priceTag.displayedText)                        // ₹4999


//==============================================================
// MARK: - 04. Responder Chain
//==============================================================
//
// Unhandled events travel up: view → superview → VC → parent VC → window → app.
// Each UIResponder's `next` points to the next responder.
//

final class ProfileViewController: UIViewController {

    let nameLabel = UILabel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(nameLabel)
    }
}

print("\n========== 04 - Responder Chain ==========")

let profileVC = ProfileViewController()

profileVC.loadViewIfNeeded()                         // triggers viewDidLoad

var responder: UIResponder? = profileVC.nameLabel

while let current = responder {
    print(type(of: current))                         // UILabel → UIView → ProfileViewController
    responder = current.next
}


//==============================================================
// MARK: - 05. Child View Controllers
//==============================================================
//
// Embed a VC inside another — keeps screens small and reusable.
// Add:    addChild → addSubview → didMove(toParent:)
// Remove: willMove(toParent: nil) → removeFromSuperview → removeFromParent
//

final class ReviewsViewController: UIViewController {}

final class ProductViewController: UIViewController {

    let reviewsVC = ReviewsViewController()

    func embedReviews() {
        addChild(reviewsVC)
        view.addSubview(reviewsVC.view)
        reviewsVC.didMove(toParent: self)
    }

    func removeReviews() {
        reviewsVC.willMove(toParent: nil)
        reviewsVC.view.removeFromSuperview()
        reviewsVC.removeFromParent()
    }
}

print("\n========== 05 - Child View Controllers ==========")

let productVC = ProductViewController()

productVC.embedReviews()

print("Children:", productVC.children.count)         // 1

print("Reviews parent is product:", productVC.reviewsVC.parent === productVC)   // true

productVC.removeReviews()

print("After remove:", productVC.children.count)     // 0


//==============================================================
// MARK: - 06. Common Mistakes
//==============================================================
//
// ❌ Adding a VC's view without addChild → child misses lifecycle + rotation events
// ❌ Massive View Controller — networking, parsing, formatting all in the VC
//    → move to ViewModel / services, keep VC for UI wiring
// ❌ Views that fetch their own data → hard to reuse and test
// ❌ Reading frames in viewDidLoad → size not final (see 10_Frame_vs_Bounds)
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. UIView vs UIViewController?
//    → A view draws and handles touches; a view controller manages a screen's lifecycle and logic.
//
// 2. How does the view hierarchy decide which view is on top?
//    → Subview order — the last in subviews is drawn front-most.
//
// 3. What is the responder chain?
//    → The path unhandled events travel: view → superview → VC → window → app.
//
// 4. How do you add a child view controller correctly?
//    → addChild, addSubview(child.view), then child.didMove(toParent:).
//
// 5. Why use child view controllers?
//    → Split a big screen into smaller, reusable, independently managed parts.
//
// 6. What is Massive View Controller and how do you avoid it?
//    → A VC doing everything — move logic into ViewModels, services, and child VCs.
//
// 7. Why does a custom UIView need init?(coder:)?
//    → It's required by UIView for storyboard / XIB loading.
//
//==============================================================
