import Foundation

// ============================================================
// MARK: - S — SINGLE RESPONSIBILITY PRINCIPLE (SRP)
// ============================================================

/*
 SRP:

 "A type should have ONE reason to change."

 Not "one method".

 One JOB, owned by one kind of change.

 Simple test:

 "Who would ask me to change this class?"

 - Backend team
 - Designer
 - Product owner
 - Analytics team

 More than one answer → more than one responsibility.
*/


// ============================================================
// MARK: - 1. Model
// ============================================================

struct Product: Decodable {
    let id: Int
    let name: String
    let price: Double
    let stock: Int
}


// ============================================================
// MARK: - 2. ❌ SRP Violation
// ============================================================

/*
 One class does EVERYTHING.

 ProductScreenEverything
 ├── Networking + JSON     → backend team
 ├── Price formatting      → designer
 ├── Business rules        → product owner
 ├── UserDefaults          → storage changes
 ├── Analytics             → analytics team
 └── UI                    → layout changes

 6 reasons to change → 6 responsibilities.
*/

final class ProductScreenEverything {

    func showProduct() {

        // 1. Networking + JSON
        let json = #"{"id":42,"name":"Running Shoes","price":4999,"stock":3}"#

        guard let product = try? JSONDecoder().decode(
            Product.self,
            from: Data(json.utf8)
        ) else {
            return
        }

        // 2. Formatting
        let price = "₹" + String(format: "%.0f", product.price)

        // 3. Business rule
        let canBuy = product.stock > 0 && product.price > 0

        // 4. Persistence
        UserDefaults.standard.set(product.id, forKey: "lastViewedProduct")

        // 5. Analytics
        print("Analytics: product_viewed \(product.id)")

        // 6. UI
        print("UI → \(product.name) | \(price) | Buy: \(canBuy)")
    }
}

ProductScreenEverything().showProduct()

print("DEBUG Q01 - ❌ One class, 6 responsibilities")


// ============================================================
// MARK: - 3. Problems with the Violation
// ============================================================

/*
 ❌ Huge class, hard to read
 ❌ Merge conflicts between teams
 ❌ Can't test the price rule without networking + UserDefaults
 ❌ A formatting change can break networking
*/


// ============================================================
// MARK: - 4. ✅ Fix - Product Service
// ============================================================

/*
 Responsibility:
 Get product data.

 Reason to change:
 The API changes.
*/

protocol ProductService {
    func fetchProduct(id: Int) -> Product?
}

final class FakeProductService: ProductService {

    func fetchProduct(id: Int) -> Product? {

        let json = #"{"id":42,"name":"Running Shoes","price":4999,"stock":3}"#

        return try? JSONDecoder().decode(
            Product.self,
            from: Data(json.utf8)
        )
    }
}


// ============================================================
// MARK: - 5. ✅ Fix - Price Formatter
// ============================================================

/*
 Responsibility:
 Format price for display.

 Reason to change:
 Designer changes the price format.
*/

struct PriceFormatter {

    func format(_ price: Double) -> String {
        "₹" + String(format: "%.0f", price)
    }
}


// ============================================================
// MARK: - 6. ✅ Fix - Purchase Rules
// ============================================================

/*
 Responsibility:
 Business rule — can this product be bought?

 Reason to change:
 Product owner changes the rule.
*/

struct PurchaseRules {

    func canBuy(_ product: Product) -> Bool {
        product.stock > 0 && product.price > 0
    }
}


// ============================================================
// MARK: - 7. ✅ Fix - Store + Analytics
// ============================================================

/*
 RecentlyViewedStore:
 Responsibility → persistence
 Reason to change → storage changes (UserDefaults → Core Data)

 AnalyticsTracker:
 Responsibility → tracking events
 Reason to change → analytics team requirements
*/

final class RecentlyViewedStore {

    func save(productID: Int) {
        UserDefaults.standard.set(productID, forKey: "lastViewedProduct")
    }
}

final class AnalyticsTracker {

    func track(_ event: String) {
        print("Analytics: \(event)")
    }
}


// ============================================================
// MARK: - 8. ✅ Fix - ViewModel
// ============================================================

/*
 Responsibility:
 Prepare screen state.

 It does NOT fetch, format, store or track itself.

 It COORDINATES the small types.
*/

final class ProductViewModel {

    private let service: ProductService
    private let formatter: PriceFormatter
    private let rules: PurchaseRules
    private let store: RecentlyViewedStore
    private let analytics: AnalyticsTracker

    private(set) var title = ""
    private(set) var price = ""
    private(set) var isBuyEnabled = false

    init(
        service: ProductService,
        formatter: PriceFormatter = PriceFormatter(),
        rules: PurchaseRules = PurchaseRules(),
        store: RecentlyViewedStore = RecentlyViewedStore(),
        analytics: AnalyticsTracker = AnalyticsTracker()
    ) {
        self.service = service
        self.formatter = formatter
        self.rules = rules
        self.store = store
        self.analytics = analytics
    }

    func load(id: Int) {

        guard let product = service.fetchProduct(id: id) else {
            return
        }

        title = product.name
        price = formatter.format(product.price)
        isBuyEnabled = rules.canBuy(product)

        store.save(productID: product.id)
        analytics.track("product_viewed \(product.id)")
    }
}


// ============================================================
// MARK: - 9. ✅ Fix - Screen (UI Only)
// ============================================================

/*
 Responsibility:
 Display UI.

 Reason to change:
 Layout changes.
*/

final class ProductScreen {

    private let viewModel: ProductViewModel

    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }

    func show() {

        viewModel.load(id: 42)

        print("UI → \(viewModel.title) | \(viewModel.price) | Buy: \(viewModel.isBuyEnabled)")
    }
}

let screen = ProductScreen(
    viewModel: ProductViewModel(
        service: FakeProductService()
    )
)

screen.show()

print("DEBUG Q02 - ✅ Same output, one job per type")


// ============================================================
// MARK: - 10. Payoff - Test a Rule Alone
// ============================================================

/*
 PurchaseRules can be tested WITHOUT:
 - Networking
 - UserDefaults
 - UI
*/

let rules = PurchaseRules()

let outOfStock = Product(id: 1, name: "Cap", price: 499, stock: 0)

let freeItem = Product(id: 2, name: "Sticker", price: 0, stock: 10)

print("DEBUG Q03 - Out of stock can buy:", rules.canBuy(outOfStock))     // false

print("DEBUG Q04 - Free item can buy:", rules.canBuy(freeItem))          // false

print("DEBUG Q05 - Formatter:", PriceFormatter().format(1299))           // ₹1299


// ============================================================
// MARK: - 11. Don't Over-Split
// ============================================================

/*
 SRP does NOT mean one method per class.

 ❌ PriceFormatterHelperManager with one line in it

 ✅ Group code that changes TOGETHER for the SAME reason

 Split only when two parts:
 - change for different reasons, or
 - are owned by different people
*/


// ============================================================
// MARK: - 12. SRP in iOS
// ============================================================

/*
 Massive View Controller   → classic SRP violation

 ViewModel                 → presentation logic
 Service / Repository      → data
 Formatter                 → display formatting
 Coordinator               → navigation
 Cell                      → render one row
*/


// ============================================================
// MARK: - 13. Senior Interview Questions
// ============================================================

/*
 Q1. What is SRP?

 Answer:
 A type should have only one reason to change.


 Q2. How do you spot an SRP violation?

 Answer:
 Ask who would request changes to the class.
 More than one answer means too many responsibilities.


 Q3. Give an iOS example.

 Answer:
 Massive View Controller doing networking, formatting,
 storage, analytics and UI.


 Q4. How do you fix it?

 Answer:
 Extract services, formatters, rules and stores.
 The ViewModel coordinates them; the ViewController
 only displays UI.


 Q5. Does SRP mean one method per class?

 Answer:
 No.

 It means one job. Group code that changes together
 for the same reason.


 Q6. How does SRP help testing?

 Answer:
 Each small type can be tested alone, without UI,
 networking or storage.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

          ❌ BEFORE

   ┌──────────────────────┐
   │  ProductScreen       │
   │                      │
   │  Network             │
   │  Format              │
   │  Rules               │
   │  Storage             │
   │  Analytics           │
   │  UI                  │
   └──────────────────────┘


          ✅ AFTER

          ProductScreen (UI)
                 ↓
          ProductViewModel
                 ↓
   ┌─────────┬──────────┬─────────┬─────────┬───────────┐
   ↓         ↓          ↓         ↓         ↓
 Service  Formatter   Rules     Store    Analytics


 Remember:

 One type
     =
 One job
     =
 One reason to change
*/
