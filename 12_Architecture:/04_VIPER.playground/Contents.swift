import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - VIPER
// ============================================================

/*
 VIPER =

 V → View
 I → Interactor
 P → Presenter
 E → Entity
 R → Router

 Main goal:
 Strict separation of responsibilities.

 Flow:

 View
   ↓
 Presenter
   ↓
 Interactor
   ↓
 Repository
   ↓
 APIClient
   ↓
 Server

 Navigation:

 Presenter
   ↓
 Router
   ↓
 Next Screen
*/


// ============================================================
// MARK: - 1. Entity
// ============================================================

/*
 Entity:
 Represents application data.

 Entity should not contain UI logic or navigation logic.
*/

struct Product {
    let id: Int
    let name: String
}


// ============================================================
// MARK: - 2. API Client
// ============================================================

/*
 APIClient:
 Reusable networking infrastructure.

 VIPER does NOT replace the networking layer.
*/

protocol APIClientProtocol: Sendable {
    func fetchProducts() async throws -> [Product]
}

final class APIClient: APIClientProtocol {

    func fetchProducts() async throws -> [Product] {

        // Normally URLSession + API request would be here.

        return [
            Product(id: 1, name: "Running Shoes"),
            Product(id: 2, name: "T-Shirt")
        ]
    }
}


// ============================================================
// MARK: - 3. Repository
// ============================================================

/*
 Repository:
 Responsible for data access.

 Interactor does not need to know how data is fetched.
*/

protocol ProductRepositoryProtocol: Sendable {
    func fetchProducts() async throws -> [Product]
}

final class ProductRepository: ProductRepositoryProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts() async throws -> [Product] {
        try await apiClient.fetchProducts()
    }
}


// ============================================================
// MARK: - 4. View
// ============================================================

/*
 View responsibility:

 - Display UI
 - Send user actions to Presenter
 - Display Presenter output

 View does NOT:
 - Call API
 - Contain business logic
 - Perform navigation
*/

@MainActor
protocol ProductViewProtocol: AnyObject {

    func showLoading()
    func showProducts(_ products: [Product])
    func showError(_ message: String)
}

@MainActor
final class ProductView: ProductViewProtocol {

    private let presenter: ProductPresenterProtocol          // View owns Presenter (strong)

    init(presenter: ProductPresenterProtocol) {
        self.presenter = presenter
    }

    func viewDidLoad() {                                     // lifecycle → Presenter
        presenter.viewDidLoad()
    }

    func showLoading() {
        print("Loading...")
    }

    func showProducts(_ products: [Product]) {

        print("Products:")

        products.forEach {
            print("- \($0.name)")
        }
    }

    func showError(_ message: String) {
        print("Error: \(message)")
    }

    func userSelectedProduct(_ product: Product) {

        presenter.didSelectProduct(product)
    }
}


// ============================================================
// MARK: - 5. Presenter
// ============================================================

/*
 Presenter:

 - Receives events from View
 - Tells Interactor what data is needed
 - Formats data for View
 - Tells Router about navigation

 Presenter does NOT directly call API.
*/

@MainActor
protocol ProductPresenterProtocol {
    func viewDidLoad()
    func didSelectProduct(_ product: Product)
}

@MainActor
protocol ProductPresenterOutput: AnyObject {
    func displayProducts(_ products: [Product])
    func displayError(_ message: String)
}

@MainActor
final class ProductPresenter: ProductPresenterProtocol {

    weak var view: ProductViewProtocol?                      // weak → no retain cycle
    private let interactor: ProductInteractorProtocol
    private let router: ProductRouterProtocol

    init(
        view: ProductViewProtocol?,
        interactor: ProductInteractorProtocol,
        router: ProductRouterProtocol
    ) {
        self.view = view
        self.interactor = interactor
        self.router = router
    }

    func viewDidLoad() {

        view?.showLoading()

        Task {
            await interactor.fetchProducts()
        }
    }

    func didSelectProduct(_ product: Product) {

        router.showProductDetails(product)
    }
}


// ============================================================
// MARK: - 6. Interactor
// ============================================================

/*
 Interactor:

 - Contains business/use-case logic
 - Requests data from Repository
 - Does not know about UI
 - Does not perform navigation
*/

@MainActor
protocol ProductInteractorProtocol {
    func fetchProducts() async
}

@MainActor
final class ProductInteractor: ProductInteractorProtocol {

    private let repository: ProductRepositoryProtocol
    weak var presenter: ProductPresenterOutput?              // weak → no retain cycle

    init(
        repository: ProductRepositoryProtocol,
        presenter: ProductPresenterOutput?
    ) {
        self.repository = repository
        self.presenter = presenter
    }

    func fetchProducts() async {

        do {

            let products = try await repository.fetchProducts()

            presenter?.displayProducts(products)

        } catch {

            presenter?.displayError(
                "Unable to load products"
            )
        }
    }
}


// ============================================================
// MARK: - 7. Presenter Output
// ============================================================

extension ProductPresenter: ProductPresenterOutput {

    func displayProducts(_ products: [Product]) {

        view?.showProducts(products)
    }

    func displayError(_ message: String) {

        view?.showError(message)
    }
}


// ============================================================
// MARK: - 8. Router
// ============================================================

/*
 Router:

 - Handles navigation
 - Creates next module/screen
 - Keeps navigation out of Presenter/View

 Router is similar to Coordinator's responsibility.
*/

@MainActor
protocol ProductRouterProtocol {
    func showProductDetails(_ product: Product)
}

@MainActor
final class ProductRouter: ProductRouterProtocol {

    func showProductDetails(_ product: Product) {

        print("Navigate → Product Details")
        print("Selected: \(product.name)")
    }
}


// ============================================================
// MARK: - 9. VIPER Module Builder
// ============================================================

/*
 VIPER usually creates a Module Builder / Assembly.

 Responsibility:
 Wire all VIPER components together.

 View
   ↓
 Presenter
   ↓
 Interactor
   ↓
 Repository
   ↓
 APIClient

 Presenter
   ↓
 Router
*/

@MainActor
final class ProductModuleBuilder {

    static func build() -> ProductView {

        let apiClient = APIClient()

        let repository = ProductRepository(
            apiClient: apiClient
        )

        let router = ProductRouter()

        // Temporary references are connected after creation.

        let interactor = ProductInteractor(
            repository: repository,
            presenter: nil
        )

        let presenter = ProductPresenter(
            view: nil,
            interactor: interactor,
            router: router
        )

        let view = ProductView(
            presenter: presenter
        )

        // Wire the back-references (both weak):
        interactor.presenter = presenter                     // Interactor → Presenter
        presenter.view = view                                // Presenter → View

        return view
    }
}


// ============================================================
// MARK: - Run
// ============================================================

Task { @MainActor in

    let view = ProductModuleBuilder.build()                  // View keeps the module alive

    view.viewDidLoad()                                       // Loading... → Products

    try? await Task.sleep(for: .milliseconds(200))

    view.userSelectedProduct(Product(id: 1, name: "Running Shoes"))   // → Router

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 10. VIPER Responsibility Map
// ============================================================

/*

 ┌──────────────┐
 │     VIEW     │
 │ UI / Events  │
 └──────┬───────┘
        ↓
 ┌──────────────┐
 │   PRESENTER  │
 │ Presentation │
 └──────┬───────┘
        ↓
 ┌──────────────┐
 │  INTERACTOR  │
 │ Business     │
 │ Logic        │
 └──────┬───────┘
        ↓
 ┌──────────────┐
 │  REPOSITORY  │
 │ Data Access  │
 └──────┬───────┘
        ↓
 ┌──────────────┐
 │  APICLIENT   │
 │ Networking   │
 └──────┬───────┘
        ↓
      SERVER


 Presenter
     │
     ↓
 ┌──────────────┐
 │    ROUTER    │
 │ Navigation   │
 └──────────────┘
*/


// ============================================================
// MARK: - 11. VIPER vs MVVM-C
// ============================================================

/*
 MVVM-C:

 View
   ↓
 ViewModel
   ↓
 Repository
   ↓
 APIClient

 Coordinator → Navigation


 VIPER:

 View
   ↓
 Presenter
   ↓
 Interactor
   ↓
 Repository
   ↓
 APIClient

 Router → Navigation


 Main difference:

 MVVM-C
 → Fewer components
 → Simpler
 → ViewModel owns presentation logic

 VIPER
 → More strict separation
 → Presenter + Interactor + Router
 → More files / more boilerplate
*/


// ============================================================
// MARK: - 12. When to Use VIPER
// ============================================================

/*
 Use VIPER when:

 ✅ Large application
 ✅ Large development team
 ✅ Complex business rules
 ✅ Strong module boundaries
 ✅ High testability requirements
 ✅ Feature needs strict separation

 Possible downside:

 ❌ More files
 ❌ More protocols
 ❌ More boilerplate
 ❌ Higher learning curve
 ❌ Can be excessive for simple screens
*/


// ============================================================
// MARK: - 13. Senior Interview Questions
// ============================================================

/*
 Q1. What does VIPER stand for?

 V → View
 I → Interactor
 P → Presenter
 E → Entity
 R → Router


 Q2. What does Interactor do?

 Business/use-case logic.

 It does not handle UI or navigation.


 Q3. What does Presenter do?

 Presenter coordinates communication between
 View, Interactor and Router.

 It prepares data for the View.


 Q4. What does Router do?

 Navigation and module creation.


 Q5. Where should API calls happen?

 Usually:

 Interactor
    ↓
 Repository
    ↓
 APIClient


 Q6. Does VIPER require Repository?

 Not strictly.

 Repository is commonly added as a separate
 data-access abstraction in modern implementations.


 Q7. VIPER vs MVVM?

 MVVM has fewer layers.

 VIPER provides stricter separation by dividing
 presentation, business logic and navigation.


 Q8. Biggest disadvantage of VIPER?

 Boilerplate and increased number of components.


 Q9. Why is VIPER highly testable?

 Each responsibility is isolated behind protocols,
 allowing components to be mocked independently.


 Q10. What is the main senior-level benefit?

 Clear module boundaries and separation of concerns
 in large applications.


 Q11. Why are Presenter.view and Interactor.presenter weak?

 View owns Presenter, Presenter owns Interactor.
 Strong back-references would create retain cycles.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

 VIPER

 V → View
     ↓
 P → Presenter
     ↓
 I → Interactor
     ↓
     Repository
     ↓
     APIClient
     ↓
     Server

 P → Router (R) → Navigation

 E → Entity / Data Model


 Easy memory:

 View       → UI
 Presenter  → Presentation
 Interactor → Business
 Entity     → Data
 Router     → Navigation
 Repository → Data Access
 APIClient  → Network
*/
