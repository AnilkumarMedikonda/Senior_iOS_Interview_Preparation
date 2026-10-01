import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

/*
 ============================================================
                         MVVM
 ============================================================

 MVVM = Model + View + ViewModel

 Model
   → Application data

 View
   → Displays UI

 ViewModel
   → Presentation logic + UI state

 Repository
   → Data access

 APIClient
   → Reusable networking


 ============================================================
                         FLOW
 ============================================================

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

 Response:

 Server
   ↓
 APIClient
   ↓
 Repository
   ↓
 ViewModel
   ↓
 View
*/


// MARK: - 1. Model

/*
 Model represents application data.

 It should not depend on UIKit.
*/

struct Product: Codable {

    let id: Int
    let name: String
    let price: Double

    // API sends "title" → map it to our "name"
    enum CodingKeys: String, CodingKey {
        case id
        case name = "title"
        case price
    }
}


// MARK: - 2. Endpoint

/*
 Endpoint keeps API information centralized.

 The ViewModel does NOT know URLs.
*/

enum ProductEndpoint {

    case products

    var path: String {

        switch self {
        case .products:
            return "/products?limit=3"
        }
    }
}


// MARK: - 3. API Client

/*
 APIClient is reusable networking infrastructure.

 Responsibilities:

 • Build request
 • Call URLSession
 • Decode response
 • Return Result

 ViewModel should NOT directly use URLSession.
*/

protocol APIClientProtocol {

    func request<T: Decodable>(
        endpoint: ProductEndpoint,
        completion: @escaping (Result<T, Error>) -> Void
    )
}


final class APIClient: APIClientProtocol {

    private let baseURL = "https://fakestoreapi.com"          // free test API

    func request<T: Decodable>(
        endpoint: ProductEndpoint,
        completion: @escaping (Result<T, Error>) -> Void
    ) {

        guard let url = URL(
            string: baseURL + endpoint.path
        ) else {
            completion(.failure(URLError(.badURL)))           // always call completion
            return
        }

        var request = URLRequest(url: url)

        request.httpMethod = "GET"

        request.setValue(
            "application/json",
            forHTTPHeaderField: "Accept"
        )

        URLSession.shared.dataTask(
            with: request
        ) { data, response, error in

            if let error {
                completion(.failure(error))
                return
            }

            if let http = response as? HTTPURLResponse,
               !(200...299).contains(http.statusCode) {      // 404 / 500 don't throw
                completion(.failure(URLError(.badServerResponse)))
                return
            }

            guard let data else {
                completion(.failure(URLError(.zeroByteResource)))
                return
            }

            do {

                let response = try JSONDecoder().decode(
                    T.self,
                    from: data
                )

                completion(.success(response))

            } catch {

                completion(.failure(error))
            }

        }.resume()
    }
}


// MARK: - 4. Repository

/*
 Repository hides the data source from ViewModel.

 ViewModel says:

 "Give me products."

 Repository decides:

 "I'll get them from the API."

 Later, Repository could use:

 API
 +
 Memory Cache
 +
 Disk Cache
 +
 Core Data
*/

protocol ProductRepositoryProtocol {

    func fetchProducts(
        completion: @escaping (Result<[Product], Error>) -> Void
    )
}


final class ProductRepository: ProductRepositoryProtocol {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts(
        completion: @escaping (Result<[Product], Error>) -> Void
    ) {

        apiClient.request(endpoint: .products) {
            (result: Result<[Product], Error>) in

            completion(result)
        }
    }
}


// MARK: - 5. ViewModel

/*
 ViewModel is the heart of MVVM.

 Responsibilities:

 • Presentation logic
 • UI state
 • Loading state
 • Error state
 • Transform Model → UI data
 • Handle user actions

 ViewModel should NOT know about:

 • UILabel
 • UIViewController
 • UIView
 • UIKit
*/

final class ProductViewModel {

    private let repository: ProductRepositoryProtocol

    private(set) var products: [Product] = []

    private(set) var isLoading = false

    private(set) var errorMessage: String?

    // Simple binding mechanism for this Playground.
    var onStateChange: (() -> Void)?

    init(repository: ProductRepositoryProtocol) {
        self.repository = repository
    }

    func loadProducts() {

        isLoading = true
        errorMessage = nil

        onStateChange?()

        repository.fetchProducts { [weak self] result in

            // Network callback is on a background thread →
            // update state + notify the View on main
            DispatchQueue.main.async {

                guard let self else {
                    return
                }

                self.isLoading = false

                switch result {

                case .success(let products):

                    self.products = products

                case .failure:

                    self.products = []
                    self.errorMessage = "Unable to load products"
                }

                self.onStateChange?()
            }
        }
    }
}


// MARK: - 6. View

/*
 View displays the state provided by ViewModel.

 View does not know:

 • API
 • URLSession
 • Repository
 • JSONDecoder
*/

final class ProductView {

    func render(viewModel: ProductViewModel) {

        if viewModel.isLoading {
            print("Loading...")
            return
        }

        if let errorMessage = viewModel.errorMessage {
            print("Error: \(errorMessage)")
            return
        }

        if viewModel.products.isEmpty {
            print("No products found")
            return
        }

        for product in viewModel.products {

            print(
                "Product: \(product.name) | Price: $\(product.price)"
            )
        }
    }
}


// MARK: - 7. ViewController

/*
 In UIKit:

 UIViewController connects the View and ViewModel.

 Its responsibility should remain small.

 ViewController:

 • Observes ViewModel
 • Updates UI
 • Sends user actions to ViewModel
*/

final class ProductViewController {

    private let view = ProductView()

    private let viewModel: ProductViewModel

    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }

    func viewDidLoad() {

        viewModel.onStateChange = { [weak self] in

            guard let self else {
                return
            }

            self.view.render(
                viewModel: self.viewModel
            )
        }

        viewModel.loadProducts()
    }
}


// MARK: - 8. Dependency Injection

/*
 Dependencies are injected from outside.

 This gives us:

 ProductViewController
        ↓
 ProductViewModel
        ↓
 ProductRepository
        ↓
 APIClient


 The ViewModel does not create its own Repository.

 This improves:

 • Testability
 • Flexibility
 • Loose coupling
*/

let apiClient = APIClient()

let repository = ProductRepository(
    apiClient: apiClient
)

let viewModel = ProductViewModel(
    repository: repository
)

let viewController = ProductViewController(
    viewModel: viewModel
)

viewController.viewDidLoad()


// MARK: - 9. MVVM Diagram

/*
 
                 ┌───────────────┐
                 │      VIEW     │
                 │  UIKit/SwiftUI│
                 └───────┬───────┘
                         │
                         ↓
                 ┌───────────────┐
                 │   VIEW MODEL  │
                 │               │
                 │ UI State      │
                 │ Presentation  │
                 │ Logic         │
                 └───────┬───────┘
                         │
                         ↓
                 ┌───────────────┐
                 │   REPOSITORY  │
                 │               │
                 │ Data Access   │
                 └───────┬───────┘
                         │
                         ↓
                 ┌───────────────┐
                 │   API CLIENT  │
                 │   Reusable    │
                 └───────┬───────┘
                         │
                         ↓
                    URLSession
                         │
                         ↓
                      SERVER

*/


// MARK: - 10. MVC vs MVVM

/*
 MVC:

 View
   ↓
 ViewController
   ↓
 Model


 MVVM:

 View
   ↓
 ViewController
   ↓
 ViewModel
   ↓
 Repository
   ↓
 APIClient
   ↓
 Server


 Main improvement:

 MVC:
 ViewController can become large.

 MVVM:
 Presentation logic moves into ViewModel.
*/


// MARK: - 11. MVVM + Coordinator

/*
 MVVM does NOT handle navigation.

 For complex navigation we add Coordinator.

                    Coordinator
                         │
                         ↓
                  ViewController
                         │
                         ↓
                    ViewModel
                         │
                         ↓
                    Repository
                         │
                         ↓
                    APIClient
                         │
                         ↓
                      Server


 This combination is commonly called:

                    MVVM-C

 MVVM  → Presentation
 C     → Coordinator / Navigation
*/


// MARK: - 12. When to Use MVVM

/*
 Use MVVM when:

 ✓ Screen has meaningful presentation logic
 ✓ Multiple UI states
 ✓ Loading / Success / Empty / Error
 ✓ Complex UI transformation
 ✓ ViewController is becoming large
 ✓ Unit testing is important
 ✓ SwiftUI is being used
 ✓ Combine / async-await is being used


 Examples:

 Product List
 Search
 PLP
 PDP
 Checkout
 Dashboard
*/


// MARK: - 13. When NOT to Use MVVM

/*
 For a very simple screen:

 About
 Help
 Static Settings

 MVC may be simpler.

 Do not add MVVM only because it is popular.

 Architecture should solve a real problem.
*/


// MARK: - 14. Pros

/*
 ✓ Separation of presentation logic
 ✓ Smaller ViewController
 ✓ Better testability
 ✓ Better state management
 ✓ Dependency Injection friendly
 ✓ Works well with UIKit
 ✓ Works well with SwiftUI
 ✓ Works well with async/await
*/


// MARK: - 15. Cons

/*
 ✗ More files
 ✗ More abstraction
 ✗ ViewModel can become too large
 ✗ Can be over-engineered
 ✗ Requires clear responsibility boundaries
*/


// MARK: - 16. Senior Interview Questions

/*
 Q1. What is MVVM?
     → A pattern where a ViewModel holds presentation logic and UI state; the View just displays it.

 Q2. What is the responsibility of ViewModel?
     → Turn data into UI state (loading, error, content) and handle user actions.

 Q3. Should ViewModel know about UIKit?
     → No — no UILabel or UIViewController; that keeps it testable.

 Q4. Should ViewModel directly use URLSession?
     → No — it goes through a Repository / APIClient that can be mocked.

 Q5. Why use Repository?
     → It hides where data comes from (API, cache, Core Data) behind one interface.

 Q6. Why use APIClient?
     → One reusable place for requests, headers, status checks, and decoding.

 Q7. How do you unit test ViewModel?
     → Inject a mock repository, call loadProducts(), assert products / errorMessage.

 Q8. What is Dependency Injection?
     → Passing dependencies in from outside (init) instead of creating them inside.

 Q9. MVC vs MVVM?
     → MVVM moves presentation logic and state from the controller into a ViewModel.

 Q10. MVVM vs MVVM-C?
     → MVVM-C adds a Coordinator that owns navigation.

 Q11. Can MVVM work with SwiftUI?
     → Yes — it's SwiftUI's natural pattern (ObservableObject / @Observable).

 Q12. What happens if ViewModel becomes too large?
     → Split it: child ViewModels, use cases, or separate services.

 Q13. When would you choose MVC instead?
     → Very simple or static screens with little logic.

 Q14. Where does business logic belong?
     → In models, services, or use cases — not in the View.

 Q15. Where does navigation belong?
     → In a Coordinator (or Router), not the ViewModel.
*/


// MARK: - 17. Senior Interview Answer

/*
 "MVVM separates presentation logic from the View.

 The ViewModel owns presentation state and transforms
 application data into UI-friendly state.

 I keep data access behind a Repository and networking
 behind a reusable APIClient.

 The ViewController mainly connects the View and ViewModel.

 For complex navigation, I combine MVVM with Coordinator,
 which is commonly referred to as MVVM-C."
*/


// MARK: - FINAL MEMORY MAP

/*
 
 MVC

 View
   ↓
 ViewController
   ↓
 Model


 MVVM

 View
   ↓
 ViewModel        ← Presentation Logic
   ↓
 Repository       ← Data Access
   ↓
 APIClient        ← Networking
   ↓
 URLSession
   ↓
 Server


 MVVM-C

 Coordinator      ← Navigation
       │
       ↓
 View
       ↓
 ViewModel        ← Presentation
       ↓
 Repository       ← Data
       ↓
 APIClient        ← Networking
       ↓
 Server


 Remember:

 ViewModel    = What should the UI display?
 Repository   = Where does the data come from?
 APIClient    = How do we communicate with server?
 Coordinator  = Which screen should we navigate to?
*/
