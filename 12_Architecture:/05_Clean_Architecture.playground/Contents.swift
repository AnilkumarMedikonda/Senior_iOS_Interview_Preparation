import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - CLEAN ARCHITECTURE
// ============================================================

/*
 Clean Architecture separates the application into layers.

 Main layers:

 ┌──────────────────────────────┐
 │        Presentation          │
 │ View / ViewModel             │
 └──────────────┬───────────────┘
                ↓
 ┌──────────────────────────────┐
 │           Domain             │
 │ Entity / UseCase / Repository│
 │          Protocol            │
 └──────────────┬───────────────┘
                ↓
 ┌──────────────────────────────┐
 │            Data              │
 │ Repository / APIClient       │
 │ URLSession / DTO             │
 └──────────────────────────────┘


 IMPORTANT:

 Dependencies should point INWARD.

 Presentation → Domain
 Data         → Domain

 Domain should NOT depend on:
 - UIKit
 - SwiftUI
 - URLSession
 - APIClient
 - Database
 - Networking framework
*/


// ============================================================
// MARK: - 1. Domain Entity
// ============================================================

/*
 Entity:

 Represents core business data.

 Domain Entity should be independent of networking/UI.

 It should not know:
 - JSON
 - URLSession
 - UIKit
*/

struct Product {

    let id: Int
    let name: String
    let price: Double
}


// ============================================================
// MARK: - 2. Domain Repository Protocol
// ============================================================

/*
 Repository protocol belongs to DOMAIN.

 Domain says:

 "I need products."

 It does NOT care whether products come from:
 - API
 - Database
 - Cache
 - Mock
*/

protocol ProductRepository: Sendable {

    func fetchProducts() async throws -> [Product]
}


// ============================================================
// MARK: - 3. Use Case
// ============================================================

/*
 UseCase contains application/business rules.

 ViewModel should not directly contain complex business rules.

 Example:

 ViewModel
     ↓
 FetchProductsUseCase
     ↓
 ProductRepository
*/

protocol FetchProductsUseCaseProtocol: Sendable {

    func execute() async throws -> [Product]
}

final class FetchProductsUseCase: FetchProductsUseCaseProtocol {

    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Product] {

        let products = try await repository.fetchProducts()

        // Business rule lives here:
        // hide invalid prices, show cheapest first
        return products
            .filter { $0.price > 0 }
            .sorted { $0.price < $1.price }
    }
}


// ============================================================
// MARK: - 4. Data Layer - APIClient
// ============================================================

/*
 APIClient belongs to DATA / infrastructure.

 It knows:
 - URLSession
 - HTTP
 - JSON
 - API endpoints

 Domain does not know any of these details.
*/

protocol APIClientProtocol: Sendable {

    func fetchProducts() async throws -> [ProductDTO]
}

/*
 DTO = exact API JSON shape.

 In real apps it often differs from the Entity
 (snake_case keys, cents instead of price, extra fields).
 Kept identical here for simplicity — the mapping in
 RepositoryImpl is where those differences get handled.
*/
struct ProductDTO: Decodable {

    let id: Int
    let name: String
    let price: Double
}

final class APIClient: APIClientProtocol {

    func fetchProducts() async throws -> [ProductDTO] {

        // Real implementation:
        // URLSession + URLRequest + JSONDecoder

        return [
            ProductDTO(
                id: 1,
                name: "Running Shoes",
                price: 99.0
            ),
            ProductDTO(
                id: 2,
                name: "T-Shirt",
                price: 29.0
            )
        ]
    }
}


// ============================================================
// MARK: - 5. Data Layer - Repository Implementation
// ============================================================

/*
 This is the concrete implementation of the
 Domain's ProductRepository protocol.

 Dependency direction:

 Data → Domain

 The Domain only knows the protocol.
*/

final class ProductRepositoryImpl: ProductRepository {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts() async throws -> [Product] {

        let dtos = try await apiClient.fetchProducts()

        // DTO → Entity mapping
        return dtos.map {
            Product(
                id: $0.id,
                name: $0.name,
                price: $0.price
            )
        }
    }
}


// ============================================================
// MARK: - 6. Presentation - ViewModel
// ============================================================

/*
 ViewModel belongs to PRESENTATION.

 It:
 - Calls UseCase
 - Manages UI state
 - Prepares data for View

 It should not know:
 - URLSession
 - API endpoint
 - JSONDecoder
*/

@MainActor
final class ProductViewModel {

    private let fetchProductsUseCase:
        FetchProductsUseCaseProtocol

    private(set) var products: [Product] = []
    private(set) var isLoading = false
    private(set) var errorMessage: String?

    init(
        fetchProductsUseCase:
        FetchProductsUseCaseProtocol
    ) {
        self.fetchProductsUseCase =
            fetchProductsUseCase
    }

    func loadProducts() async {

        isLoading = true
        errorMessage = nil                                   // reset old error

        do {

            products =
                try await fetchProductsUseCase.execute()

        } catch {

            errorMessage = "Unable to load products"
        }

        isLoading = false
    }
}


// ============================================================
// MARK: - 7. Presentation - View
// ============================================================

/*
 View responsibility:

 - Display UI
 - Send user actions
 - Observe ViewModel

 View does not access Repository or APIClient.
*/

@MainActor
final class ProductView {

    private let viewModel: ProductViewModel

    init(viewModel: ProductViewModel) {
        self.viewModel = viewModel
    }

    func display() {

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
            print("\($0.name) - $\($0.price)")
        }
    }
}


// ============================================================
// MARK: - 8. Dependency Injection / Composition Root
// ============================================================

/*
 This is where concrete implementations are connected.

 APIClient
     ↓
 RepositoryImpl
     ↓
 UseCase
     ↓
 ViewModel
     ↓
 View

 The Domain itself never creates these concrete objects.
*/

let apiClient = APIClient()

let repository = ProductRepositoryImpl(
    apiClient: apiClient
)

let useCase = FetchProductsUseCase(
    repository: repository
)

let viewModel = ProductViewModel(
    fetchProductsUseCase: useCase
)

let view = ProductView(
    viewModel: viewModel
)


// ============================================================
// MARK: - 9. Run
// ============================================================

Task { @MainActor in

    await viewModel.loadProducts()

    view.display()                                           // T-Shirt first (sorted by UseCase)
}


// ============================================================
// MARK: - 10. Testing with Mock
// ============================================================

/*
 One major benefit of Clean Architecture:

 ViewModel does not need a real API.

 We can replace Repository with a Mock.
*/

final class MockProductRepository: ProductRepository {

    func fetchProducts() async throws -> [Product] {

        return [
            Product(
                id: 100,
                name: "Test Product",
                price: 50
            ),
            Product(
                id: 101,
                name: "Broken Product",
                price: 0                                     // filtered by UseCase rule
            )
        ]
    }
}

let mockRepository = MockProductRepository()

let mockUseCase = FetchProductsUseCase(
    repository: mockRepository
)

let testViewModel = ProductViewModel(
    fetchProductsUseCase: mockUseCase
)

Task { @MainActor in

    await testViewModel.loadProducts()

    print("\nDEBUG - Clean Architecture Test")

    testViewModel.products.forEach {
        print($0.name)                                       // only "Test Product"
    }
}


// ============================================================
// MARK: - 11. Dependency Rule
// ============================================================

/*
 MOST IMPORTANT CLEAN ARCHITECTURE RULE:

 Dependencies point inward.

              PRESENTATION
                   ↓
                DOMAIN
                   ↑
                  DATA


 Domain:

 ❌ Cannot depend on UIKit
 ❌ Cannot depend on URLSession
 ❌ Cannot depend on APIClient
 ❌ Cannot depend on database implementation

 Domain defines business contracts.

 Data implements those contracts.
*/


// ============================================================
// MARK: - 12. Clean Architecture Flow
// ============================================================

/*

                 USER
                   ↓
                VIEW
                   ↓
              VIEWMODEL
                   ↓
                USECASE
                   ↓
          REPOSITORY PROTOCOL
                   ↑
                   │
        REPOSITORY IMPLEMENTATION
                   ↓
               APICLIENT
                   ↓
              URLSESSION
                   ↓
                SERVER


 Important:

 UseCase knows Repository protocol.

 Repository implementation knows APIClient.

 Domain does NOT know APIClient.
*/


// ============================================================
// MARK: - 13. Clean Architecture vs MVVM-C
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


 Clean Architecture:

 View
   ↓
 ViewModel
   ↓
 UseCase
   ↓
 Repository Protocol
   ↑
 Repository Implementation
   ↓
 APIClient


 Key difference:

 MVVM-C focuses mainly on:
 → Presentation + Navigation


 Clean Architecture focuses on:
 → Dependency direction
 → Business rules
 → Layer boundaries
 → Testability
*/


// ============================================================
// MARK: - 14. Clean Architecture vs VIPER
// ============================================================

/*
 VIPER:

 View
 Presenter
 Interactor
 Entity
 Router

 Focus:
 Strict separation of module responsibilities.


 Clean Architecture:

 Presentation
 Domain
 Data

 Focus:
 Dependency inversion and protection of business rules.


 They can also be combined.

 Example:

 Clean Architecture
       +
     MVVM-C
       ↓
 Presentation → ViewModel + Coordinator
 Domain       → UseCases + Entities
 Data         → Repository + APIClient
*/


// ============================================================
// MARK: - 15. When to Use
// ============================================================

/*
 Good fit:

 ✅ Large applications
 ✅ Long-lived products
 ✅ Complex business rules
 ✅ Multiple data sources
 ✅ Offline support
 ✅ Large development teams
 ✅ High testability requirements
 ✅ Multiple UI frameworks


 Can be excessive for:

 ❌ Small screens
 ❌ Simple CRUD
 ❌ Small prototypes
 ❌ Very small applications


 Senior point:

 Architecture should solve actual complexity.

 Do not add layers only because Clean Architecture
 is popular.
*/


// ============================================================
// MARK: - 16. Senior Interview Questions
// ============================================================

/*
 Q1. What is Clean Architecture?

 Answer:
 An architectural approach that separates business rules
 from frameworks and external systems while controlling
 dependency direction.


 Q2. What are the main layers?

 Answer:

 Presentation
 Domain
 Data


 Q3. Which layer contains business rules?

 Answer:

 Domain.

 Usually:
 - Entities
 - UseCases
 - Repository protocols


 Q4. Can Domain import UIKit?

 Answer:

 No.

 Domain should remain framework-independent.


 Q5. Where should Repository protocol live?

 Answer:

 Domain.

 The concrete Repository implementation belongs
 to the Data layer.


 Q6. Why?

 Answer:

 It follows Dependency Inversion.

 Domain defines what it needs.
 Data provides the implementation.


 Q7. Where should APIClient live?

 Answer:

 Data / Infrastructure.


 Q8. What is the biggest benefit?

 Answer:

 Business logic becomes independent from UI,
 networking and data-storage implementation.


 Q9. Why is it testable?

 Answer:

 Dependencies are abstracted through protocols,
 allowing mocks and fakes.


 Q10. What is the biggest downside?

 Answer:

 More layers, protocols and boilerplate.


 Q11. Does Clean Architecture require MVVM?

 Answer:

 No.

 Clean Architecture is independent of the
 presentation pattern.

 It can use:
 - MVC
 - MVVM
 - VIPER
 - SwiftUI
 - MVVM-C


 Q12. What is Dependency Inversion?

 Answer:

 High-level business logic should depend on
 abstractions, not concrete low-level implementations.


 Q13. Why map DTOs to Entities?

 Answer:

 API changes stay inside the Data layer;
 the rest of the app keeps using stable Entities.
*/


// ============================================================
// MARK: - FINAL SENIOR MENTAL MODEL
// ============================================================

/*

             CLEAN ARCHITECTURE

        ┌──────────────────────┐
        │    PRESENTATION      │
        │                      │
        │ View                 │
        │ ViewModel            │
        └──────────┬───────────┘
                   ↓
        ┌──────────────────────┐
        │       DOMAIN         │
        │                      │
        │ Entity               │
        │ UseCase              │
        │ Repository Protocol  │
        └──────────┬───────────┘
                   ↑
                   │
        ┌──────────┴───────────┐
        │        DATA          │
        │                      │
        │ Repository Impl      │
        │ APIClient            │
        │ URLSession           │
        └──────────────────────┘


 Remember:

 DOMAIN = Business

 PRESENTATION = UI

 DATA = External world


 Most important interview concept:

 "The Domain should not depend on the Data
  or Presentation layers."
*/
