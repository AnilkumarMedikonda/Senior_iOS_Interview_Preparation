import UIKit

//==============================================================
// MARK: - Delegation
//==============================================================
//
// One object hands off decisions or events to another (its delegate).
// Pattern: protocol + weak delegate property + call delegate?.method().
// One-to-one communication. Used across UIKit:
// UITableViewDelegate, UITextFieldDelegate, UIScrollViewDelegate.
//


//==============================================================
// MARK: - 01. Basic Pattern — Reporting Events
//==============================================================

protocol SizePickerDelegate: AnyObject {

    func sizePicker(_ picker: SizePicker, didSelect size: Int)
}

final class SizePicker {

    weak var delegate: SizePickerDelegate?          // weak → no retain cycle

    func userTapped(size: Int) {
        delegate?.sizePicker(self, didSelect: size)
    }
}

final class ProductScreen: SizePickerDelegate {

    let picker = SizePicker()

    init() {
        picker.delegate = self                      // ⚠️ forget this → nothing happens
    }

    func sizePicker(_ picker: SizePicker, didSelect size: Int) {
        print("Selected size:", size)
    }
}

print("\n========== 01 - Basic Pattern ==========")

let productScreen = ProductScreen()

productScreen.picker.userTapped(size: 9)            // Selected size: 9


//==============================================================
// MARK: - 02. Asking for Data (Data Source)
//==============================================================
//
// The delegate can RETURN values — like UITableViewDataSource.
//

protocol CarouselDataSource: AnyObject {

    func numberOfItems() -> Int

    func title(at index: Int) -> String
}

final class Carousel {

    weak var dataSource: CarouselDataSource?

    func render() {
        guard let dataSource else { return }
        for index in 0..<dataSource.numberOfItems() {
            print("Item:", dataSource.title(at: index))
        }
    }
}

final class HomeScreen: CarouselDataSource {

    let carousel = Carousel()

    let banners = ["Sale", "New Arrivals"]

    init() {
        carousel.dataSource = self
    }

    func numberOfItems() -> Int { banners.count }

    func title(at index: Int) -> String { banners[index] }
}

print("\n========== 02 - Asking for Data ==========")

let homeScreen = HomeScreen()

homeScreen.carousel.render()                        // Item: Sale | Item: New Arrivals


//==============================================================
// MARK: - 03. Cell → ViewController
//==============================================================
//
// A button inside a cell tells its VC which item was tapped.
//

@MainActor
protocol ProductCellDelegate: AnyObject {

    func productCellDidTapFavorite(_ cell: ProductCell)
}

final class ProductCell: UITableViewCell {

    weak var delegate: ProductCellDelegate?

    var productID = 0

    func favoriteTapped() {
        delegate?.productCellDidTapFavorite(self)
    }
}

final class ProductListViewController: UIViewController, ProductCellDelegate {

    func productCellDidTapFavorite(_ cell: ProductCell) {
        print("Favorite product:", cell.productID)
    }
}

print("\n========== 03 - Cell → ViewController ==========")

let listVC = ProductListViewController()

let cell = ProductCell()

cell.productID = 42

cell.delegate = listVC

cell.favoriteTapped()                               // Favorite product: 42


//==============================================================
// MARK: - 04. Optional Delegate Methods
//==============================================================
//
// Swift way: default implementation in a protocol extension.
//

protocol PlayerDelegate: AnyObject {

    func playerDidFinish()

    func playerDidPause()
}

extension PlayerDelegate {

    func playerDidPause() {}                        // optional — default does nothing
}

final class VideoScreen: PlayerDelegate {

    func playerDidFinish() {
        print("Video finished")                    // only implements what it needs
    }
}

print("\n========== 04 - Optional Methods ==========")

let videoScreen = VideoScreen()

videoScreen.playerDidPause()                        // nothing

videoScreen.playerDidFinish()                       // Video finished


//==============================================================
// MARK: - 05. Delegate vs Closure vs NotificationCenter
//==============================================================
//
// ┌────────────────────┬─────────────────────┬──────────────────────────────┐
// │                    │ Relationship        │ Use when                     │
// ├────────────────────┼─────────────────────┼──────────────────────────────┤
// │ Delegate           │ One-to-one          │ Many related callbacks, data │
// │ Closure            │ One-to-one          │ One or two simple callbacks  │
// │ NotificationCenter │ One-to-many         │ App-wide events (logout)     │
// └────────────────────┴─────────────────────┴──────────────────────────────┘
//


//==============================================================
// MARK: - 06. Common Mistakes
//==============================================================
//
// ❌ Strong delegate → retain cycle (owner ↔ child)
// ❌ Protocol without AnyObject → can't declare weak
// ❌ Forgetting to set delegate = self → methods never called
// ❌ Delegate method names without the sender (didSelect(size:))
//    → can't tell which picker called when there are two
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is the delegation pattern?
//    → An object hands events or decisions to another object through a protocol.
//
// 2. Why is the delegate property weak?
//    → The owner already holds the child strongly; a strong delegate would form a cycle.
//
// 3. Why must a delegate protocol be AnyObject?
//    → weak only works with class types.
//
// 4. Delegate vs data source?
//    → Delegate reports events; data source provides data the object asks for.
//
// 5. How do you make delegate methods optional in Swift?
//    → Default implementation in a protocol extension (or @objc optional).
//
// 6. Delegate vs closure vs NotificationCenter?
//    → Delegate for many related callbacks, closure for one, notification for one-to-many.
//
// 7. Why pass the sender as the first parameter?
//    → So one delegate can handle multiple objects of the same type.
//
//==============================================================
