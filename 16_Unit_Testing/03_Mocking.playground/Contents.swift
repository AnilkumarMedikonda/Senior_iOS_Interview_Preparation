import Foundation
import XCTest

// ============================================================
// MARK: - MOCKING & TEST DOUBLES
// ============================================================

/*
 Test double = a stand-in for a real dependency in tests
 (network, database, analytics, payments).

 Five kinds:

 Dummy → passed in but never used
 Stub  → returns fixed data
 Fake  → simple WORKING version (in-memory store)
 Mock  → records calls so the test can VERIFY them
 Spy   → real/stubbed behaviour + records how it was called

 All of them work because the code depends on PROTOCOLS.
*/


// ============================================================
// MARK: - 1. Dependencies (Protocols)
// ============================================================

struct Order: Equatable {
    let transactionID: String
    let amount: Double
}

enum CheckoutError: Error, Equatable {
    case invalidAmount
    case paymentDeclined
}

@MainActor protocol PaymentGateway {
    func charge(amount: Double) async throws -> String        // returns transaction ID
}

@MainActor protocol OrderStore {
    func save(_ order: Order)
    func allOrders() -> [Order]
}

@MainActor protocol AnalyticsTracking {
    func track(_ event: String)
}

@MainActor protocol Logger {
    func log(_ message: String)
}


// ============================================================
// MARK: - 2. Code Under Test
// ============================================================

/*
 Rules:
 - amount <= 0       → throw invalidAmount, never charge
 - payment succeeds  → save order, track "purchase_completed"
 - payment fails     → don't save, track "purchase_failed"
*/

@MainActor
final class CheckoutService {

    private let gateway: PaymentGateway
    private let store: OrderStore
    private let analytics: AnalyticsTracking
    private let logger: Logger

    init(gateway: PaymentGateway, store: OrderStore, analytics: AnalyticsTracking, logger: Logger) {
        self.gateway = gateway
        self.store = store
        self.analytics = analytics
        self.logger = logger
    }

    func checkout(amount: Double) async throws -> Order {
        guard amount > 0 else {
            throw CheckoutError.invalidAmount
        }
        do {
            let transactionID = try await gateway.charge(amount: amount)
            let order = Order(transactionID: transactionID, amount: amount)
            store.save(order)
            analytics.track("purchase_completed")
            return order
        } catch {
            analytics.track("purchase_failed")
            throw CheckoutError.paymentDeclined
        }
    }
}


// ============================================================
// MARK: - 3. Dummy — Never Used
// ============================================================

/*
 The init needs a Logger, but these tests don't care about logs.
*/

@MainActor
final class DummyLogger: Logger {
    func log(_ message: String) {}
}


// ============================================================
// MARK: - 4. Stub — Fixed Answers
// ============================================================

@MainActor
final class StubPaymentGateway: PaymentGateway {

    private let result: Result<String, Error>

    init(result: Result<String, Error>) {
        self.result = result
    }

    func charge(amount: Double) async throws -> String {
        try result.get()
    }
}


// ============================================================
// MARK: - 5. Spy — Stub Behaviour + Records Calls
// ============================================================

@MainActor
final class SpyPaymentGateway: PaymentGateway {

    private(set) var chargedAmounts: [Double] = []

    func charge(amount: Double) async throws -> String {
        chargedAmounts.append(amount)                        // record
        return "TX-\(chargedAmounts.count)"                  // behave
    }
}


// ============================================================
// MARK: - 6. Fake — Simple Working Implementation
// ============================================================

/*
 Real behaviour, in memory instead of Core Data.
*/

@MainActor
final class FakeOrderStore: OrderStore {

    private var orders: [Order] = []

    func save(_ order: Order) {
        orders.append(order)
    }

    func allOrders() -> [Order] {
        orders
    }
}


// ============================================================
// MARK: - 7. Mock — Records What Happened for Verification
// ============================================================

@MainActor
final class MockAnalytics: AnalyticsTracking {

    private(set) var trackedEvents: [String] = []

    func track(_ event: String) {
        trackedEvents.append(event)
    }
}


// ============================================================
// MARK: - 8. Tests
// ============================================================

@MainActor
final class CheckoutServiceTests: XCTestCase {

    private func makeSUT(
        gateway: PaymentGateway
    ) -> (CheckoutService, FakeOrderStore, MockAnalytics) {
        let store = FakeOrderStore()
        let analytics = MockAnalytics()
        let sut = CheckoutService(gateway: gateway, store: store, analytics: analytics, logger: DummyLogger())
        return (sut, store, analytics)
    }


    // Stub success + Fake store + Mock analytics
    func test_checkout_paymentSucceeds_savesOrderAndTracksCompleted() async throws {
        let (sut, store, analytics) = makeSUT(gateway: StubPaymentGateway(result: .success("TX-42")))

        let order = try await sut.checkout(amount: 4999)

        XCTAssertEqual(order, Order(transactionID: "TX-42", amount: 4999))
        XCTAssertEqual(store.allOrders(), [order])                         // fake: real state
        XCTAssertEqual(analytics.trackedEvents, ["purchase_completed"])    // mock: verify calls
    }


    // Stub failure
    func test_checkout_paymentFails_doesNotSaveAndTracksFailed() async {
        let (sut, store, analytics) = makeSUT(gateway: StubPaymentGateway(result: .failure(CheckoutError.paymentDeclined)))

        do {
            _ = try await sut.checkout(amount: 4999)
            XCTFail("Expected paymentDeclined")
        } catch {
            XCTAssertEqual(error as? CheckoutError, .paymentDeclined)
        }

        XCTAssertTrue(store.allOrders().isEmpty)
        XCTAssertEqual(analytics.trackedEvents, ["purchase_failed"])
    }


    // Spy: verify the gateway was NEVER called
    func test_checkout_zeroAmount_neverCharges() async {
        let spy = SpyPaymentGateway()
        let (sut, _, _) = makeSUT(gateway: spy)

        do {
            _ = try await sut.checkout(amount: 0)
            XCTFail("Expected invalidAmount")
        } catch {
            XCTAssertEqual(error as? CheckoutError, .invalidAmount)
        }

        XCTAssertTrue(spy.chargedAmounts.isEmpty)
    }


    // Spy: verify the EXACT amount charged
    func test_checkout_chargesExactAmount() async throws {
        let spy = SpyPaymentGateway()
        let (sut, _, _) = makeSUT(gateway: spy)

        _ = try await sut.checkout(amount: 1299)

        XCTAssertEqual(spy.chargedAmounts, [1299])
    }
}


// ============================================================
// MARK: - 9. Run the Tests
// ============================================================

let suite = CheckoutServiceTests.defaultTestSuite

suite.run()

if let run = suite.testRun {
    print("DEBUG Q01 - Tests run:", run.executionCount)              // 4
    print("DEBUG Q02 - Failures:", run.totalFailureCount)            // 0
}


// ============================================================
// MARK: - 10. Closure-Based Mock (Quick Alternative)
// ============================================================

/*
 For a one-off test, a closure can replace a whole class:

 final class ClosurePaymentGateway: PaymentGateway {
     let handler: (Double) async throws -> String
     init(handler: @escaping (Double) async throws -> String) { self.handler = handler }
     func charge(amount: Double) async throws -> String { try await handler(amount) }
 }

 let gateway = ClosurePaymentGateway { _ in "TX-1" }
*/


// ============================================================
// MARK: - 11. Mocking Pitfalls
// ============================================================

/*
 ❌ Over-mocking         → mocking everything tests nothing real
 ❌ Verifying internals  → tests break on every refactor
 ❌ Mocks that lie       → mock behaves differently from the real
                           type → tests pass, app breaks (LSP)
 ❌ Mocking types you don't own (URLSession, SDKs)
                         → wrap them behind your own protocol (Adapter)
 ✅ Mock at the boundaries: network, storage, analytics, time
*/


// ============================================================
// MARK: - 12. Senior Interview Questions
// ============================================================

/*
 Q1. Mock vs stub?

 Answer:
 A stub returns fixed data so the code can run; a mock
 records calls so the test can verify them.


 Q2. What is a fake?

 Answer:
 A simple working implementation, like an in-memory
 store instead of Core Data.


 Q3. What is a spy?

 Answer:
 A double that behaves normally but also records how it
 was called (arguments, count).


 Q4. Why do mocks need protocols?

 Answer:
 The code depends on the protocol, so tests can inject
 any conforming double instead of the real type.


 Q5. How do you mock URLSession or a third-party SDK?

 Answer:
 Wrap it behind your own protocol (Adapter) and mock that,
 or use URLProtocol for URLSession.


 Q6. What's the danger of too many mocks?

 Answer:
 Tests check wiring instead of behaviour and break on
 every refactor.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

               CheckoutService (SUT)
                       │
     ┌─────────────┬───┴─────────┬──────────────┐
     ↓             ↓             ↓              ↓
  Gateway        Store       Analytics       Logger
  STUB / SPY     FAKE        MOCK            DUMMY
  fixed answer   works in    records calls   never used
  / records      memory      to verify


 Remember:

 Stub → gives answers
 Mock → checks calls
 Fake → really works (simply)
*/
