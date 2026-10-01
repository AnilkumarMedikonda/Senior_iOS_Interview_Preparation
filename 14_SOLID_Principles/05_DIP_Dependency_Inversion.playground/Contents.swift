import Foundation

// ============================================================
// MARK: - DIP: DEPENDENCY INVERSION PRINCIPLE
// ============================================================

/*
 DIP:

 High-level modules should not depend directly on
 low-level concrete implementations.

 Both should depend on an abstraction.
*/


// ============================================================
// MARK: - 1. ❌ Without DIP
// ============================================================

/*
 ViewModel directly creates APIClient.

 ViewModel → APIClient

 This creates tight coupling.
*/

final class OldAPIClient {

    func fetchProducts() {
        print("Fetching products from API")
    }
}

final class OldProductViewModel {

    private let apiClient = OldAPIClient()

    func loadProducts() {
        apiClient.fetchProducts()
    }
}

OldProductViewModel().loadProducts()

print("DEBUG Q01 - ❌ Always the real API — no way to swap or mock it")


// ============================================================
// MARK: - 2. ✅ DIP Solution
// ============================================================

/*
 Create an abstraction.

 ViewModel depends on the protocol,
 not the concrete APIClient.
*/

protocol APIClientProtocol {

    func fetchProducts()
}


// ============================================================
// MARK: - 3. Low-Level Module
// ============================================================

final class APIClient: APIClientProtocol {

    func fetchProducts() {
        print("Fetching products from API")
    }
}


// ============================================================
// MARK: - 4. High-Level Module
// ============================================================

final class ProductViewModel {

    private let apiClient: APIClientProtocol

    init(apiClient: APIClientProtocol) {
        self.apiClient = apiClient
    }

    func loadProducts() {
        apiClient.fetchProducts()
    }
}


// ============================================================
// MARK: - 5. Usage
// ============================================================

let apiClient = APIClient()

let viewModel = ProductViewModel(
    apiClient: apiClient
)

viewModel.loadProducts()

print("DEBUG Q02 - ✅ ViewModel uses the protocol, real client injected")


// ============================================================
// MARK: - 6. Mock Implementation
// ============================================================

/*
 Because ViewModel depends on the protocol,
 we can replace the real API with a Mock.
*/

final class MockAPIClient: APIClientProtocol {

    private(set) var fetchCount = 0

    func fetchProducts() {
        fetchCount += 1
        print("Fetching mock products")
    }
}


// ============================================================
// MARK: - 7. Testing
// ============================================================

let mockClient = MockAPIClient()

let testViewModel = ProductViewModel(
    apiClient: mockClient
)

testViewModel.loadProducts()

print("DEBUG Q03 - ✅ Mock called:", mockClient.fetchCount, "time(s)")      // 1


// ============================================================
// MARK: - 8. High-Level Flow
// ============================================================

/*

  ❌ Before:

  ProductViewModel ──depends on──→ APIClient (concrete)


  ✅ After (dependency INVERTED):

  ProductViewModel ──depends on──→ APIClientProtocol
                                         ↑
                                  implements (depends on)
                               ┌─────────┴─────────┐
                           APIClient          MockAPIClient


 ProductViewModel depends on the abstraction,
 not a concrete implementation.

 The low-level APIClient now ALSO depends on the abstraction —
 the arrow points UP. That is the "inversion".
*/


// ============================================================
// MARK: - 9. Who Owns the Abstraction?
// ============================================================

/*
 The protocol belongs to the HIGH-LEVEL side
 (the one that NEEDS it), not the low-level side.

 Clean Architecture:

 Domain   → defines ProductRepository (protocol)
 Data     → RemoteProductRepository implements it

 Domain never imports Data.
 Data imports Domain.

 That is DIP at the architecture level.
*/


// ============================================================
// MARK: - 10. Senior Point
// ============================================================

/*
 DIP = Depend on abstractions.

 Dependency Injection = A technique used to provide
 those dependencies from outside.

 DIP:
 "What should I depend on?"

 DI:
 "How do I provide that dependency?"
*/


// ============================================================
// MARK: - 11. Senior Interview Questions
// ============================================================

/*
 Q1. What is DIP?

 Answer:
 High-level and low-level modules both depend on
 abstractions, not on each other's concrete types.


 Q2. What is being "inverted"?

 Answer:
 The dependency direction — the low-level class now
 depends on (implements) an abstraction owned by the
 high-level side.


 Q3. DIP vs Dependency Injection?

 Answer:
 DIP is the principle (depend on protocols).
 DI is the technique (pass them in from outside).


 Q4. Where should the protocol live?

 Answer:
 With the high-level code that needs it — e.g. the
 Repository protocol in the Domain layer.


 Q5. How does DIP help testing?

 Answer:
 Tests inject a mock that conforms to the protocol —
 no real network or database.


 Q6. Can you over-apply DIP?

 Answer:
 Yes. A protocol for every type with only one
 implementation and no test need adds noise.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

        ❌ BEFORE

   ViewModel  ───→  APIClient


        ✅ AFTER

   ViewModel  ───→  Protocol  ←───  APIClient
                       ↑
                    MockAPIClient


 Remember:

 Depend on WHAT (protocol)
        not
 on HOW (concrete class)
*/


// ============================================================
// MARK: - Interview One-Liner
// ============================================================

/*
 "DIP means high-level and low-level modules should depend
 on abstractions rather than the high-level module directly
 depending on a concrete implementation."
*/
