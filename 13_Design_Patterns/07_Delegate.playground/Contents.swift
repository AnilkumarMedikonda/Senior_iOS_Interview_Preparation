import Foundation

// ============================================================
// MARK: - DELEGATE PATTERN
// ============================================================

/*
 Delegate = one object hands off decisions / events to ONE other object.

 ProductCell ──"add to cart tapped"──→ delegate (ProductListViewController)
 TableView   ──"how many rows?"──────→ dataSource (answers back)

 One-to-one. The delegate can RETURN values (unlike notifications).
*/


// ============================================================
// MARK: - 1. Delegate Protocol
// ============================================================

// AnyObject → only classes → can be held weakly
protocol ProductCellDelegate: AnyObject {
    func productCellDidTapAddToCart(productID: Int)
    func productCellShouldShowPrice(productID: Int) -> Bool   // delegate answers back
}

// Optional methods: give a default in an extension
extension ProductCellDelegate {
    func productCellShouldShowPrice(productID: Int) -> Bool {
        true
    }
}


// ============================================================
// MARK: - 2. Delegating Object (the one that asks / reports)
// ============================================================

final class ProductCell {

    let productID: Int

    weak var delegate: ProductCellDelegate?                  // weak → no retain cycle

    init(productID: Int) {
        self.productID = productID
    }

    func render() {
        if let delegate, delegate.productCellShouldShowPrice(productID: productID) {
            print("Cell \(productID): price visible")
        } else {
            print("Cell \(productID): price hidden")
        }
    }

    func addToCartTapped() {
        delegate?.productCellDidTapAddToCart(productID: productID)
    }
}


// ============================================================
// MARK: - 3. Delegate (the one that decides / reacts)
// ============================================================

final class ProductListViewController: ProductCellDelegate {

    private var cart: [Int] = []

    let cell = ProductCell(productID: 42)

    init() {
        cell.delegate = self                                  // connect
    }

    func productCellDidTapAddToCart(productID: Int) {
        cart.append(productID)
        print("🛒 Added \(productID) — cart: \(cart)")
    }

    func productCellShouldShowPrice(productID: Int) -> Bool {
        productID != 99                                      // business decision lives here
    }

    deinit {
        print("ProductListViewController deinit ✅")
    }
}

print("\n========== 03 - Delegate in Action ==========")

var listScreen: ProductListViewController? = ProductListViewController()

listScreen?.cell.render()                                    // price visible

listScreen?.cell.addToCartTapped()                           // 🛒 Added 42

listScreen = nil                                             // deinit prints → weak delegate, no leak


// ============================================================
// MARK: - 4. Why weak? (Retain Cycle)
// ============================================================

/*
 ViewController ──strong──→ Cell
 Cell ──strong──→ delegate (ViewController)   ❌ cycle → never deallocated

 weak var delegate breaks the cycle.
*/

protocol LeakyDelegate: AnyObject {}

final class LeakyCell {
    var delegate: LeakyDelegate?                             // ❌ strong
}

final class LeakyScreen: LeakyDelegate {

    let cell = LeakyCell()

    init() {
        cell.delegate = self
    }

    deinit {
        print("LeakyScreen deinit")                          // never prints
    }
}

print("\n========== 04 - Strong Delegate Leak ==========")

var leaky: LeakyScreen? = LeakyScreen()

leaky = nil

print("LeakyScreen set to nil — no deinit above ❌ (leaked)")


// ============================================================
// MARK: - 5. Delegate vs Closure vs NotificationCenter
// ============================================================

/*
 ┌──────────────────┬────────────────────┬──────────────────┬────────────────────┐
 │                  │ Delegate           │ Closure          │ NotificationCenter │
 ├──────────────────┼────────────────────┼──────────────────┼────────────────────┤
 │ Listeners        │ One                │ One              │ Many               │
 │ Return values    │ Yes                │ Yes              │ No                 │
 │ Many callbacks   │ Groups them neatly │ One per closure  │ One per name       │
 │ Memory           │ weak var delegate  │ [weak self]      │ remove observer    │
 │ Typical use      │ Table/collection,  │ Simple "done"    │ App-wide events    │
 │                  │ cells, pickers     │ callback         │ (logout, theme)    │
 └──────────────────┴────────────────────┴──────────────────┴────────────────────┘
*/


// ============================================================
// MARK: - 6. Apple Examples
// ============================================================

/*
 UITableViewDelegate / UITableViewDataSource
 UICollectionViewDelegate
 UITextFieldDelegate          → textFieldShouldReturn (returns Bool)
 URLSessionDelegate           → auth challenges, SSL pinning
 UIApplicationDelegate        → app lifecycle
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is the Delegate pattern?
     → One object hands events or decisions to one other object through a protocol.

 Q2. Why is the delegate property weak?
     → The owner usually holds the delegating object; strong both ways is a retain cycle.

 Q3. Why AnyObject on the protocol?
     → weak only works with classes.

 Q4. How do you make delegate methods optional in Swift?
     → Default implementations in a protocol extension (or @objc optional).

 Q5. Delegate vs NotificationCenter?
     → Delegate is one-to-one and can return values; notifications broadcast to many.

 Q6. Delegate vs closure?
     → Closure for one simple callback; delegate when there are several related callbacks.
*/
