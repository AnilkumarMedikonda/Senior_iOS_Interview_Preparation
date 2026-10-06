import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - MVVM + CLEAN ARCHITECTURE
// ============================================================

/*
 MVVM + Clean = MVVM for the SCREEN + Clean layers for the APP.

 MVVM  → how one screen is organised   (View + ViewModel)
 Clean → how the whole app is layered  (Presentation / Domain / Data)

 ┌──────────────────────────────────────┐
 │           PRESENTATION (MVVM)        │
 │  View  ──▶  ViewModel (UI state)     │
 └──────────────────┬───────────────────┘
                    ↓ calls UseCase
 ┌──────────────────────────────────────┐
 │               DOMAIN                 │
 │  UseCase / Entity / Repository Proto │
 └──────────────────┬───────────────────┘
                    ↑ implements
 ┌──────────────────────────────────────┐
 │                DATA                  │
 │  RepositoryImpl / APIClient / DTO    │
 └──────────────────────────────────────┘


 KEY CHANGE vs plain MVVM:

 Plain MVVM      → ViewModel calls Repository / API directly
 MVVM + Clean    → ViewModel calls a UseCase only
*/


// ============================================================
// MARK: - 1. DOMAIN — Entity
// ============================================================

/*
 Pure business data.
 No JSON keys, no UIKit, no formatting.
*/

struct Product: Equatable {

    let id: Int
    let name: String
    let price: Double
    let stock: Int
}


// ============================================================
// MARK: - 2. DOMAIN — Repository Protocol
// ============================================================

/*
 Domain says WHAT it needs.
 Data layer decides HOW (API / DB / cache).
*/

protocol ProductRepository: Sendable {

    func fetchProducts() async throws -> [Product]
}


// ============================================================
// MARK: - 3. DOMAIN — UseCases (one business action each)
// ============================================================

/*
 Each UseCase = one business action.
 Business rules live HERE, not in the ViewModel.
*/

protocol FetchAvailableProductsUseCase: Sendable {

    func execute() async throws -> [Product]
}

final class FetchAvailableProductsUseCaseImpl: FetchAvailableProductsUseCase {

    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func execute() async throws -> [Product] {

        let products = try await repository.fetchProducts()

        // Business rule: only in-stock items, cheapest first
        return products
            .filter { $0.stock > 0 }
            .sorted { $0.price < $1.price }
    }
}


// ============================================================
// MARK: - 4. DATA — DTO + APIClient
// ============================================================

/*
 DTO = exact API JSON shape (snake_case, different names).
 Only the Data layer knows it.
*/

struct ProductDTO: Decodable {

    let id: Int
    let title: String
    let priceInCents: Int
    let availableQty: Int
}

protocol APIClientProtocol: Sendable {

    func fetchProducts() async throws -> [ProductDTO]
}

final class APIClient: APIClientProtocol {

    func fetchProducts() async throws -> [ProductDTO] {

        // Real app: URLSession + JSONDecoder (.convertFromSnakeCase)

        try await Task.sleep(for: .milliseconds(100))        // fake network delay

        return [
            ProductDTO(id: 1, title: "Running Shoes", priceInCents: 9900, availableQty: 4),
            ProductDTO(id: 2, title: "T-Shirt",       priceInCents: 2900, availableQty: 10),
            ProductDTO(id: 3, title: "Smart Watch",   priceInCents: 19900, availableQty: 0)
        ]
    }
}


// ============================================================
// MARK: - 5. DATA — Repository Implementation
// ============================================================

/*
 Implements the DOMAIN protocol.
 Maps DTO → Entity, so API changes stay inside Data.
*/

final class ProductRepositoryImpl: ProductRepository {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func fetchProducts() async throws -> [Product] {

        let dtos = try await apiClient.fetchProducts()

        return dtos.map {
            Product(
                id: $0.id,
                name: $0.title,
                price: Double($0.priceInCents) / 100,
                stock: $0.availableQty
            )
        }
    }
}


// ============================================================
// MARK: - 6. PRESENTATION — UI Model
// ============================================================

/*
 What the View actually shows — already formatted.
 Entity (business) ≠ UI Model (display).
*/

struct ProductRowItem: Equatable {

    let title: String
    let priceText: String
    let badge: String?
}


// ============================================================
// MARK: - 7. PRESENTATION — ViewModel (MVVM)
// ============================================================

/*
 ViewModel:
 ✅ Calls UseCase
 ✅ Holds UI state (loading / loaded / empty / error)
 ✅ Maps Entity → UI Model (formatting)

 ❌ No URLSession, no APIClient, no Repository
 ❌ No business rules (those are in the UseCase)
 ❌ No UIKit → easy to unit test
*/

enum ProductListState: Equatable {

    case idle
    case loading
    case loaded([ProductRowItem])
    case empty
    case error(String)
}

@MainActor
final class ProductListViewModel {

    private let fetchProducts: FetchAvailableProductsUseCase

    var onStateChange: ((ProductListState) -> Void)?         // binding

    private(set) var state: ProductListState = .idle {
        didSet { onStateChange?(state) }                     // notify View
    }

    init(fetchProducts: FetchAvailableProductsUseCase) {
        self.fetchProducts = fetchProducts
    }

    func onAppear() async {

        state = .loading

        do {
            let products = try await fetchProducts.execute()

            state = products.isEmpty
                ? .empty
                : .loaded(products.map(makeRow))

        } catch {
            state = .error("Unable to load products")
        }
    }

    // Presentation formatting (NOT a business rule)
    private func makeRow(_ product: Product) -> ProductRowItem {
        ProductRowItem(
            title: product.name,
            priceText: String(format: "₹%.2f", product.price),
            badge: product.stock < 5 ? "Only \(product.stock) left" : nil
        )
    }
}


// ============================================================
// MARK: - 8. PRESENTATION — View
// ============================================================

/*
 View only:
 - observes state
 - renders it
 - forwards user actions

 (Real app: UIViewController or SwiftUI View)
*/

@MainActor
final class ProductListView {

    private let viewModel: ProductListViewModel

    init(viewModel: ProductListViewModel) {
        self.viewModel = viewModel

        viewModel.onStateChange = { [weak self] state in
            self?.render(state)
        }
    }

    func appear() async {
        await viewModel.onAppear()
    }

    private func render(_ state: ProductListState) {
        switch state {
        case .idle:
            break
        case .loading:
            print("⏳ Loading...")
        case .loaded(let rows):
            rows.forEach { row in
                let badge = row.badge.map { "  [\($0)]" } ?? ""
                print("🛍️ \(row.title) — \(row.priceText)\(badge)")
            }
        case .empty:
            print("📭 No products available")
        case .error(let message):
            print("❌ \(message)")
        }
    }
}


// ============================================================
// MARK: - 9. Composition Root (DI)
// ============================================================

/*
 Real app: SceneDelegate / Coordinator / DIContainer.

 APIClient → RepositoryImpl → UseCase → ViewModel → View
*/

@MainActor
func makeProductListScreen() -> ProductListView {

    let apiClient = APIClient()
    let repository = ProductRepositoryImpl(apiClient: apiClient)
    let useCase = FetchAvailableProductsUseCaseImpl(repository: repository)
    let viewModel = ProductListViewModel(fetchProducts: useCase)

    return ProductListView(viewModel: viewModel)
}


// ============================================================
// MARK: - 10. Testing — Mock the UseCase
// ============================================================

/*
 ViewModel test → mock the USECASE (not API, not Repository).
 UseCase test   → mock the REPOSITORY.

 Each layer is tested alone.
*/

struct MockFetchProductsUseCase: FetchAvailableProductsUseCase {

    let result: Result<[Product], Error>

    func execute() async throws -> [Product] {
        try result.get()
    }
}

struct MockProductRepository: ProductRepository {

    let products: [Product]

    func fetchProducts() async throws -> [Product] {
        products
    }
}

struct TestError: Error {}


// ============================================================
// MARK: - Run
// ============================================================

Task { @MainActor in

    print("\n========== 01 - Real Flow (View → VM → UseCase → Repo → API) ==========")

    let screen = makeProductListScreen()
    await screen.appear()
    // T-Shirt first (cheapest), Smart Watch hidden (stock 0)


    print("\n========== 02 - ViewModel Test: Success (mock UseCase) ==========")

    let successVM = ProductListViewModel(
        fetchProducts: MockFetchProductsUseCase(
            result: .success([Product(id: 9, name: "Test Bag", price: 10, stock: 2)])
        )
    )
    await successVM.onAppear()
    print("State:", successVM.state)


    print("\n========== 03 - ViewModel Test: Empty ==========")

    let emptyVM = ProductListViewModel(
        fetchProducts: MockFetchProductsUseCase(result: .success([]))
    )
    await emptyVM.onAppear()
    print("State:", emptyVM.state)


    print("\n========== 04 - ViewModel Test: Error ==========")

    let errorVM = ProductListViewModel(
        fetchProducts: MockFetchProductsUseCase(result: .failure(TestError()))
    )
    await errorVM.onAppear()
    print("State:", errorVM.state)


    print("\n========== 05 - UseCase Test: Business Rule (mock Repository) ==========")

    let ruleUseCase = FetchAvailableProductsUseCaseImpl(
        repository: MockProductRepository(products: [
            Product(id: 1, name: "Pen",    price: 5,  stock: 0),     // filtered out
            Product(id: 2, name: "Book",   price: 20, stock: 3),
            Product(id: 3, name: "Pencil", price: 2,  stock: 8)
        ])
    )
    let ruled = try await ruleUseCase.execute()
    print("Names:", ruled.map(\.name))                        // ["Pencil", "Book"]


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 11. Plain MVVM vs MVVM + Clean
// ============================================================

/*
 PLAIN MVVM

 class ProductViewModel {
     let repository = ProductRepository()      // ❌ concrete, knows data source
     func load() {
         // filtering + sorting rules here     // ❌ business logic in VM
     }
 }


 MVVM + CLEAN

 class ProductViewModel {
     let fetchProducts: FetchAvailableProductsUseCase   // ✅ protocol, injected
     func load() {
         // only UI state + formatting                  // ✅ rules in UseCase
     }
 }


 |                    | Plain MVVM       | MVVM + Clean          |
 |--------------------|------------------|-----------------------|
 | VM depends on      | Repository / API | UseCase protocol      |
 | Business rules     | ViewModel        | UseCase (Domain)      |
 | Layers             | View/VM/Model    | Presentation/Domain/Data |
 | Files per feature  | Fewer            | More                  |
 | Testability        | Good             | Very good (per layer) |
*/


// ============================================================
// MARK: - 12. Who Owns What
// ============================================================

/*
 | Responsibility              | Layer         | Type              |
 |-----------------------------|---------------|-------------------|
 | Show UI, forward taps       | Presentation  | View              |
 | UI state + formatting       | Presentation  | ViewModel         |
 | Business rules              | Domain        | UseCase           |
 | Business data               | Domain        | Entity            |
 | Data contract               | Domain        | Repository proto  |
 | Choose source, map DTO      | Data          | RepositoryImpl    |
 | HTTP + JSON                 | Data          | APIClient / DTO   |
 | Navigation                  | Presentation  | Coordinator (+C)  |
*/


// ============================================================
// MARK: - 13. Project Structure
// ============================================================

/*
 ProductFeature/
 ├── Presentation/
 │   ├── ProductListView.swift
 │   ├── ProductListViewModel.swift
 │   └── ProductRowItem.swift
 ├── Domain/
 │   ├── Entities/Product.swift
 │   ├── UseCases/FetchAvailableProductsUseCase.swift
 │   └── Repositories/ProductRepository.swift      ← protocol
 └── Data/
     ├── Repositories/ProductRepositoryImpl.swift
     ├── Network/APIClient.swift
     └── DTOs/ProductDTO.swift
*/


// ============================================================
// MARK: - 14. Pitfalls
// ============================================================

/*
 ❌ ViewModel still calls Repository directly → skipped Domain
 ❌ Business rules in ViewModel → rules can't be reused / tested alone
 ❌ Formatting (₹, dates) in UseCase → that's presentation, keep in VM
 ❌ Domain importing UIKit / SwiftUI → breaks dependency rule
 ❌ Passing DTOs up to the ViewModel → API leaks into UI
 ❌ "Pass-through" UseCases everywhere → ok to start, but don't add
    layers that never hold logic in tiny apps
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is MVVM + Clean?
     → MVVM in the Presentation layer; the ViewModel calls UseCases in
       the Domain, which use Repository protocols implemented in Data.

 Q2. Main difference from plain MVVM?
     → ViewModel talks to a UseCase instead of the Repository/API,
       and business rules move from the ViewModel into the UseCase.

 Q3. Where do business rules go? Where does formatting go?
     → Business rules → UseCase (Domain).
       Display formatting (currency text, badges) → ViewModel.

 Q4. What do you mock to test the ViewModel?
     → The UseCase protocol. To test the UseCase, mock the Repository.

 Q5. Why map DTO → Entity → UI Model?
     → DTO = API shape, Entity = business shape, UI Model = display shape.
       A change in one doesn't ripple into the others.

 Q6. Where does navigation go?
     → Add a Coordinator → MVVM-C + Clean.

 Q7. Who creates all the objects?
     → A Composition Root (SceneDelegate / Coordinator / DIContainer).

 Q8. When is it overkill?
     → Small apps or simple CRUD screens with no real business rules.
*/


// ============================================================
// MARK: - FINAL MENTAL MODEL
// ============================================================

/*
   View        → shows
   ViewModel   → prepares (state + formatting)
   UseCase     → decides (business rules)
   Repository  → fetches (API / DB / cache)

   "ViewModel knows the UseCase. Nobody in Domain knows the UI or the API."
*/
