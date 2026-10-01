import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - REPOSITORY PATTERN
// ============================================================

/*
 Repository = ONE place to get data, hiding WHERE it comes from.

 ViewModel: "Give me products."
       ↓
 Repository (protocol)
       ├── Local data source  (cache / Core Data)
       └── Remote data source (API Client → Server)

 The ViewModel never knows if data came from the cache or the network.
*/


// ============================================================
// MARK: - 1. Domain Model
// ============================================================

struct Product {
    let id: Int
    let name: String
}


// ============================================================
// MARK: - 2. Data Sources
// ============================================================

enum DataError: Error {
    case offline
}

// 🌐 Remote — talks to the API (fake here)
@MainActor
final class RemoteProductDataSource {

    var isOnline = true

    func fetchProducts() async throws -> [Product] {
        try await Task.sleep(for: .milliseconds(100))
        guard isOnline else {
            throw DataError.offline
        }
        print("🌐 Network call")
        return [Product(id: 1, name: "Running Shoes"), Product(id: 2, name: "Cap")]
    }
}

// 💾 Local — cache / database (in-memory here)
@MainActor
final class LocalProductDataSource {

    private var cached: [Product] = []

    func load() -> [Product] {
        cached
    }

    func save(_ products: [Product]) {
        cached = products
    }
}


// ============================================================
// MARK: - 3. Repository Protocol
// ============================================================

// What the app depends on — no mention of API, cache, or database.
@MainActor
protocol ProductRepository {
    func products(forceRefresh: Bool) async throws -> [Product]
}


// ============================================================
// MARK: - 4. Repository Implementation (Cache-First)
// ============================================================

/*
 1. Cache has data and no refresh asked → return cache
 2. Otherwise → fetch remote → save to cache → return
 3. Remote fails → fall back to cache if we have it
*/

@MainActor
final class CachedProductRepository: ProductRepository {

    private let remote: RemoteProductDataSource

    private let local: LocalProductDataSource

    init(remote: RemoteProductDataSource, local: LocalProductDataSource) {
        self.remote = remote
        self.local = local
    }

    func products(forceRefresh: Bool = false) async throws -> [Product] {

        let cached = local.load()

        if !forceRefresh && !cached.isEmpty {
            print("💾 Cache hit")
            return cached
        }

        do {
            let fresh = try await remote.fetchProducts()
            local.save(fresh)                                // keep cache up to date
            return fresh
        } catch {
            if !cached.isEmpty {
                print("📴 Offline → showing cached data")
                return cached
            }
            throw error
        }
    }
}


// ============================================================
// MARK: - 5. ViewModel — Only Knows the Protocol
// ============================================================

@MainActor
final class ProductListViewModel {

    private let repository: ProductRepository

    private(set) var names: [String] = []

    private(set) var errorMessage: String?

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func load(forceRefresh: Bool = false) async {
        do {
            names = try await repository.products(forceRefresh: forceRefresh).map(\.name)
            errorMessage = nil
        } catch {
            errorMessage = "Could not load products"
        }
    }
}


// ============================================================
// MARK: - 6. Mock Repository (Tests)
// ============================================================

@MainActor
final class MockProductRepository: ProductRepository {

    func products(forceRefresh: Bool) async throws -> [Product] {
        [Product(id: 99, name: "Mock Product")]
    }
}


// ============================================================
// MARK: - Run
// ============================================================

Task { @MainActor in

    let remote = RemoteProductDataSource()

    let repository = CachedProductRepository(remote: remote, local: LocalProductDataSource())

    let viewModel = ProductListViewModel(repository: repository)


    print("\n========== 01 - First Load → Network ==========")

    await viewModel.load()

    print("Shows:", viewModel.names)


    print("\n========== 02 - Second Load → Cache ==========")

    await viewModel.load()

    print("Shows:", viewModel.names)


    print("\n========== 03 - Pull to Refresh While Offline ==========")

    remote.isOnline = false

    await viewModel.load(forceRefresh: true)

    print("Shows:", viewModel.names)                         // still shows cached data


    print("\n========== 04 - Mock Repository ==========")

    let testViewModel = ProductListViewModel(repository: MockProductRepository())

    await testViewModel.load()

    print("Shows:", testViewModel.names)                     // ["Mock Product"]


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 7. Repository vs API Client vs Data Source
// ============================================================

/*
 ┌──────────────┬────────────────────────────────────────────────┐
 │ API Client   │ HTTP only: build request, status, decode       │
 │ Data Source  │ ONE source: remote API, or local cache / DB    │
 │ Repository   │ Combines sources, decides which to use, maps   │
 │              │ to domain models — the app's single data door  │
 └──────────────┴────────────────────────────────────────────────┘
*/


// ============================================================
// MARK: - 8. Rules
// ============================================================

/*
 ✅ Return domain models, never DTOs or Core Data objects
 ✅ Hide caching / offline logic inside the repository
 ✅ Expose a protocol → mock in tests
 ✅ One repository per feature / data type (Products, Orders, User)
 ❌ UI logic or formatting in the repository → ViewModel
 ❌ A giant repository for everything
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is the Repository pattern?
     → One access point for data that hides whether it comes from cache, DB, or network.

 Q2. Why use a Repository?
     → ViewModels stay simple, caching/offline lives in one place, and it's easy to mock.

 Q3. Repository vs API Client?
     → API Client only does HTTP; Repository combines sources and returns domain models.

 Q4. How would you add caching?
     → Inside the repository: check local first, fetch remote, save, fall back offline.

 Q5. What should a repository return?
     → Domain models — never DTOs or Core Data managed objects.

 Q6. Where does the Repository protocol live in Clean Architecture?
     → In the Domain layer; the implementation lives in Data.
*/
