import Foundation
import XCTest

// ============================================================
// MARK: - TESTING A VIEWMODEL
// ============================================================

/*
 Why ViewModels are easy to test:
 - No UIKit / SwiftUI inside
 - Dependencies are injected through protocols
 - Output is plain state we can assert on

 What we test:
 ✅ State changes: loading → loaded / empty / error
 ✅ Formatting for display
 ✅ How it calls its dependencies
 ✅ User actions (retry, refresh)
*/


// ============================================================
// MARK: - 1. Code Under Test
// ============================================================

struct Product: Equatable {
    let name: String
    let price: Double
}

enum ViewState: Equatable {
    case idle
    case loading
    case loaded([String])
    case empty
    case failed(String)
}

@MainActor
protocol ProductRepository {
    func fetchProducts() async throws -> [Product]
}

@MainActor
final class ProductListViewModel {

    private(set) var state: ViewState = .idle {
        didSet { onStateChange?(state) }                     // lets tests record every state
    }

    var onStateChange: ((ViewState) -> Void)?

    private let repository: ProductRepository

    init(repository: ProductRepository) {
        self.repository = repository
    }

    func load() async {
        state = .loading
        do {
            let products = try await repository.fetchProducts()
            state = products.isEmpty
                ? .empty
                : .loaded(products.map { "\($0.name) — ₹\(Int($0.price))" })
        } catch {
            state = .failed("Could not load products")
        }
    }

    func retry() async {
        await load()
    }
}


// ============================================================
// MARK: - 2. Test Double — Stub + Spy
// ============================================================

/*
 Returns pre-planned results (stub) and counts calls (spy).
 Each call takes the next result → test failure then success.
*/

enum TestError: Error {
    case offline
}

@MainActor
final class StubProductRepository: ProductRepository {

    private var results: [Result<[Product], Error>]

    private(set) var fetchCallCount = 0

    init(results: [Result<[Product], Error>]) {
        self.results = results
    }

    func fetchProducts() async throws -> [Product] {
        fetchCallCount += 1
        let next = results.count > 1 ? results.removeFirst() : results[0]
        return try next.get()
    }
}


// ============================================================
// MARK: - 3. Tests
// ============================================================

@MainActor
final class ProductListViewModelTests: XCTestCase {

    private func makeSUT(
        _ results: [Result<[Product], Error>]
    ) -> (ProductListViewModel, StubProductRepository) {
        let repository = StubProductRepository(results: results)
        let sut = ProductListViewModel(repository: repository)
        return (sut, repository)
    }


    // ========================================================
    // MARK: - 3a. Success
    // ========================================================

    func test_load_withProducts_setsLoadedRows() async {
        let (sut, _) = makeSUT([.success([Product(name: "Shoes", price: 4999)])])

        await sut.load()

        XCTAssertEqual(sut.state, .loaded(["Shoes — ₹4999"]))
    }


    // ========================================================
    // MARK: - 3b. Empty
    // ========================================================

    func test_load_withNoProducts_setsEmpty() async {
        let (sut, _) = makeSUT([.success([])])

        await sut.load()

        XCTAssertEqual(sut.state, .empty)
    }


    // ========================================================
    // MARK: - 3c. Error
    // ========================================================

    func test_load_whenRepositoryFails_setsFailed() async {
        let (sut, _) = makeSUT([.failure(TestError.offline)])

        await sut.load()

        XCTAssertEqual(sut.state, .failed("Could not load products"))
    }


    // ========================================================
    // MARK: - 3d. State Sequence
    // ========================================================

    func test_load_publishesLoadingThenLoaded() async {
        let (sut, _) = makeSUT([.success([Product(name: "Cap", price: 499)])])
        var states: [ViewState] = []
        sut.onStateChange = { states.append($0) }

        await sut.load()

        XCTAssertEqual(states, [.loading, .loaded(["Cap — ₹499"])])
    }


    // ========================================================
    // MARK: - 3e. Dependency Calls
    // ========================================================

    func test_load_callsRepositoryOnce() async {
        let (sut, repository) = makeSUT([.success([])])

        await sut.load()

        XCTAssertEqual(repository.fetchCallCount, 1)
    }


    // ========================================================
    // MARK: - 3f. User Action — Retry
    // ========================================================

    func test_retry_afterFailure_loadsProducts() async {
        let (sut, repository) = makeSUT([
            .failure(TestError.offline),
            .success([Product(name: "Shoes", price: 4999)])
        ])

        await sut.load()
        XCTAssertEqual(sut.state, .failed("Could not load products"))

        await sut.retry()

        XCTAssertEqual(sut.state, .loaded(["Shoes — ₹4999"]))
        XCTAssertEqual(repository.fetchCallCount, 2)
    }
}


// ============================================================
// MARK: - 4. Run the Tests
// ============================================================

let suite = ProductListViewModelTests.defaultTestSuite

suite.run()

if let run = suite.testRun {
    print("DEBUG Q01 - Tests run:", run.executionCount)              // 6
    print("DEBUG Q02 - Failures:", run.totalFailureCount)            // 0
}


// ============================================================
// MARK: - 5. What NOT to Test in a ViewModel Test
// ============================================================

/*
 ❌ UIKit / SwiftUI rendering   → UI or snapshot tests
 ❌ Real network / database     → inject stubs instead
 ❌ Private implementation      → test behaviour through public API
 ❌ Apple frameworks            → trust them
*/


// ============================================================
// MARK: - 6. Patterns Used
// ============================================================

/*
 makeSUT()          → one place to build the SUT + its doubles
 Stub results list  → script failure → success for retry tests
 Spy call count     → verify how the dependency was used
 State recorder     → onStateChange collects every state in order
 Equatable state    → one XCTAssertEqual per expectation
 @MainActor tests   → ViewModel is @MainActor, so tests are too
*/


// ============================================================
// MARK: - 7. Senior Interview Questions
// ============================================================

/*
 Q1. How do you unit test a ViewModel?

 Answer:
 Inject a stubbed repository, call its methods, and assert
 the published state for success, empty and error cases.


 Q2. Why make the state Equatable?

 Answer:
 So one XCTAssertEqual can compare whole states, including
 associated values.


 Q3. How do you verify the loading state?

 Answer:
 Record every state change (closure / publisher) and assert
 the sequence, e.g. [.loading, .loaded].


 Q4. How do you test retry logic?

 Answer:
 Give the stub a scripted list: first a failure, then a
 success, and assert both states and the call count.


 Q5. Why is the test class @MainActor?

 Answer:
 The ViewModel is @MainActor, so tests must run on the
 main actor to call it.


 Q6. What is makeSUT for?

 Answer:
 Builds the system under test and its doubles in one place,
 so each test stays short and setup changes in one spot.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   StubRepository (scripted results)
            ↓ injected
   ProductListViewModel
            ↓ load() / retry()
   state: loading → loaded / empty / failed
            ↓
   XCTAssertEqual(state, expected)


 Remember:

 Inject the dependency
       ↓
 Trigger the action
       ↓
 Assert the STATE
*/
