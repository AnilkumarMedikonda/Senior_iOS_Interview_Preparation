import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - MVVM-C
// ============================================================

/*
 MVVM-C = Model + View + ViewModel + Coordinator

 Main responsibility:

 View         → Displays UI
 ViewModel    → Presentation logic / UI state
 Coordinator → Navigation
 Repository   → Data access
 APIClient    → Networking
 Model        → Data

 Flow:

 View
   ↓
 ViewModel
   ↓
 Repository
   ↓
 APIClient
   ↓
 URLSession
   ↓
 Server

 Navigation:

 ViewModel / View
        ↓
   Coordinator
        ↓
   Next Screen


 Senior Interview Point:
 MVVM-C separates navigation from ViewController/View.
 This prevents ViewControllers from becoming responsible for
 UI + business/presentation logic + navigation.
*/


// ============================================================
// MARK: - 1. Model
// ============================================================

struct Product: Codable {
    let id: Int
    let name: String

    // API sends "title" → map it to our "name"
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
    }
}


// ============================================================
// MARK: - 2. API Client
// ============================================================

/*
 APIClient is reusable networking infrastructure.

 It is NOT part of MVVM-C itself.

 Responsibility:
 - Create request
 - Call URLSession
 - Decode response
*/

protocol APIClientProtocol: Sendable {
    func request<T: Decodable>(
        _ type: T.Type,
        from url: URL
    ) async throws -> T
}

final class APIClient: APIClientProtocol {

    func request<T: Decodable>(
        _ type: T.Type,
        from url: URL
    ) async throws -> T {

        let (data, response) = try await URLSession.shared.data(
            from: url
        )

        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw URLError(.badServerResponse)
        }

        return try JSONDecoder().decode(T.self, from: data)
    }
}


// ============================================================
// MARK: - 3. Repository
// ============================================================

/*
 Repository hides the data source from ViewModel.

 ViewModel does NOT need to know:
 - URLSession
 - HTTP
 - API endpoint
 - JSON decoding

 ViewModel only asks:
 "Give me products."
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

        guard let url = URL(
            string: "https://fakestoreapi.com/products?limit=3"   // free test API
        ) else {
            throw URLError(.badURL)
        }

        return try await apiClient.request(
            [Product].self,
            from: url
        )
    }
}


// ============================================================
// MARK: - 4. ViewModel
// ============================================================

/*
 ViewModel responsibilities:

 - Presentation state
 - Loading state
 - Error state
 - Transform data for View
 - Ask Repository for data

 ViewModel should NOT handle navigation directly.

 Navigation belongs to Coordinator.
*/

@MainActor
final class ProductViewModel {

    private let repository: ProductRepositoryProtocol

    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    var onStateChange: (() -> Void)?

    // Event → Coordinator decides where to go
    var onProductSelected: ((Product) -> Void)?

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func loadProducts() async {

        isLoading = true
        errorMessage = nil                                   // reset old error
        onStateChange?()

        do {
            products = try await repository.fetchProducts()
        } catch {
            errorMessage = "Failed to load products"
        }

        isLoading = false
        onStateChange?()
    }

    func didSelectProduct(_ product: Product) {

        // ViewModel knows WHAT happened.
        // Coordinator decides WHERE to navigate.
        onProductSelected?(product)
    }
}


// ============================================================
// MARK: - 5. View
// ============================================================

/*
 View responsibility:

 - Display UI
 - Forward user actions
 - Observe ViewModel state

 View should NOT contain navigation logic.
*/

@MainActor
final class ProductViewController {

    private let viewModel: ProductViewModel

    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }

    func viewDidLoad() {

        viewModel.onStateChange = { [weak self] in
            self?.render()
        }
    }

    func render() {

        if viewModel.isLoading {
            print("Loading...")
            return
        }

        if let error = viewModel.errorMessage {
            print("Error: \(error)")
            return
        }

        print("Products:")
        viewModel.products.forEach {
            print("- \($0.name)")
        }
    }

    func userSelectedProduct(_ product: Product) {

        // View forwards the tap → ViewModel → Coordinator
        viewModel.didSelectProduct(product)
    }
}


// ============================================================
// MARK: - 6. Coordinator
// ============================================================

/*
 Coordinator responsibility:

 - Navigation
 - Create screens
 - Manage navigation flow
 - Deep linking
 - Authentication flow
 - Checkout flow

 Coordinator does NOT contain UI business logic.
*/

@MainActor
final class ProductCoordinator {

    // Coordinator OWNS the screens (like a navigation stack).
    // Without this, the ViewController is freed right after start().
    private var navigationStack: [ProductViewController] = []

    func start() {

        let apiClient = APIClient()

        let repository = ProductRepository(
            apiClient: apiClient
        )

        let viewModel = ProductViewModel(
            repository: repository
        )

        viewModel.onProductSelected = { [weak self] product in
            self?.showProductDetails(product)
        }

        let viewController = ProductViewController(
            viewModel: viewModel
        )

        navigationStack.append(viewController)

        viewController.viewDidLoad()

        Task {
            await viewModel.loadProducts()

            // Demo: simulate the user tapping the first product
            if let first = viewModel.products.first {
                viewController.userSelectedProduct(first)
            }
        }
    }

    func showProductDetails(_ product: Product) {

        print("Navigate → Product Details")
        print("Product: \(product.name)")
    }

    func showCart() {

        print("Navigate → Cart")
    }
}


// ============================================================
// MARK: - 7. Dependency Injection
// ============================================================

/*
 Dependency Injection:

 Coordinator creates dependencies and injects them.

 ProductCoordinator
       ↓
 APIClient
       ↓
 Repository
       ↓
 ViewModel
       ↓
 ViewController

 Benefits:
 - Loose coupling
 - Easy testing
 - Easy mocking
*/

let coordinator = ProductCoordinator()

coordinator.start()                                          // ← actually run the flow


// ============================================================
// MARK: - 8. Mock Repository
// ============================================================

final class MockProductRepository: ProductRepositoryProtocol {

    func fetchProducts() async throws -> [Product] {

        return [
            Product(id: 1, name: "Running Shoes"),
            Product(id: 2, name: "T-Shirt")
        ]
    }
}


// ============================================================
// MARK: - 9. Testing with Mock
// ============================================================

/*
 ViewModel can now be tested without:
 - Internet
 - URLSession
 - Real API
*/

let mockRepository = MockProductRepository()

let testViewModel = ProductViewModel(
    repository: mockRepository
)

Task { @MainActor in

    await testViewModel.loadProducts()

    print("\nDEBUG - MVVM-C Test")

    testViewModel.products.forEach {
        print($0.name)
    }
}


// ============================================================
// MARK: - 10. MVVM vs MVVM-C
// ============================================================

/*
 MVVM:

 View
   ↓
 ViewModel
   ↓
 Repository
   ↓
 APIClient

 Navigation may still be handled by ViewController.


 MVVM-C:

 View
   ↓
 ViewModel
   ↓
 Repository
   ↓
 APIClient

 ViewModel (event)
   ↓
 Coordinator
   ↓
 Navigation


 Main difference:

 MVVM  → Presentation separation
 MVVM-C → Presentation + Navigation separation
*/


// ============================================================
// MARK: - 11. When to Use MVVM-C
// ============================================================

/*
 Use MVVM-C when:

 ✅ Multiple screens
 ✅ Complex navigation
 ✅ Deep linking
 ✅ Authentication flows
 ✅ Checkout flows
 ✅ Multiple navigation paths
 ✅ Large/medium iOS applications

 Avoid unnecessary MVVM-C for:

 ❌ Very small screen
 ❌ Simple prototype
 ❌ One-screen feature
*/


// ============================================================
// MARK: - 12. Senior Interview Questions
// ============================================================

/*
 Q1. What is MVVM-C?

 Answer:
 MVVM-C combines MVVM with Coordinator pattern.
 MVVM handles presentation logic while Coordinator
 handles navigation.


 Q2. Why use Coordinator with MVVM?

 Answer:
 To remove navigation responsibility from ViewController
 and keep navigation flow separate from presentation logic.


 Q3. Does Coordinator replace ViewModel?

 Answer:
 No.

 ViewModel → Presentation logic
 Coordinator → Navigation


 Q4. Can ViewModel directly push a ViewController?

 Answer:
 Preferably no.

 ViewModel should communicate an event/intention.
 Coordinator handles the actual navigation.


 Q5. Where should API calls happen?

 Answer:

 View
   ↓
 ViewModel
   ↓
 Repository
   ↓
 APIClient
   ↓
 URLSession


 Q6. Is APIClient part of MVVM-C?

 Answer:
 No.

 APIClient is reusable networking infrastructure.


 Q7. What is the main benefit of MVVM-C?

 Answer:
 Separation of responsibilities and scalable navigation.


 Q8. What is MVVM-C commonly called?

 Answer:
 MVVM + Coordinator = MVVM-C.


 Q9. Why [weak self] in the event closure?

 Answer:
 Coordinator owns the ViewModel. A strong capture back
 to the Coordinator would create a retain cycle.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

              MVVM-C

       ┌───────────────┐
       │     View      │
       │      UI       │
       └───────┬───────┘
               ↓
       ┌───────────────┐
       │   ViewModel   │
       │ Presentation  │
       └───────┬───────┘
               ↓
       ┌───────────────┐
       │  Repository   │
       │  Data Access  │
       └───────┬───────┘
               ↓
       ┌───────────────┐
       │   APIClient   │
       │  Networking   │
       └───────┬───────┘
               ↓
             Server


       Navigation
            ↑
            │
       ┌────┴──────┐
       │Coordinator│
       └───────────┘


 Senior Mental Model:

 View        → UI
 ViewModel   → Presentation
 Coordinator → Navigation
 Repository  → Data
 APIClient   → Network
 Model       → Data
*/
