import Foundation
import XCTest

// ============================================================
// MARK: - TESTABLE ARCHITECTURE
// ============================================================

/*
 Code is hard to test when it reaches out for HIDDEN things:

 Date()                    → time changes every run
 UserDefaults.standard     → shared, persists between tests
 URLSession.shared         → real network
 Int.random / UUID()       → different every run
 Singletons / UIKit        → global state, needs the UI

 Testable code makes every outside thing a SEAM:
 a protocol, a closure, or a parameter the test can control.
*/


// ============================================================
// MARK: - 1. ❌ Hard to Test
// ============================================================

/*
 Uses the real clock and real UserDefaults.
 Test result depends on TODAY'S date and what's on disk.
*/

final class HardCouponService {

    func canUse(code: String, expiry: Date) -> Bool {
        let used = UserDefaults.standard.bool(forKey: "used_\(code)")   // ❌ hidden global state
        return !used && Date() < expiry                                 // ❌ real time
    }
}

print("DEBUG Q01 - ❌ HardCouponService depends on today's date + disk")


// ============================================================
// MARK: - 2. ✅ Seam 1 — Inject Time
// ============================================================

/*
 Pass "now" in as a closure. App uses Date(), tests use a fixed date.
*/

typealias DateProvider = () -> Date


// ============================================================
// MARK: - 3. ✅ Seam 2 — Storage Behind a Protocol
// ============================================================

protocol CouponStorage {
    func isUsed(_ code: String) -> Bool
    func markUsed(_ code: String)
}

final class UserDefaultsCouponStorage: CouponStorage {          // real (app)

    private let defaults: UserDefaults

    init(defaults: UserDefaults = .standard) {
        self.defaults = defaults
    }

    func isUsed(_ code: String) -> Bool {
        defaults.bool(forKey: "used_\(code)")
    }

    func markUsed(_ code: String) {
        defaults.set(true, forKey: "used_\(code)")
    }
}

final class InMemoryCouponStorage: CouponStorage {              // fake (tests)

    private var used: Set<String> = []

    func isUsed(_ code: String) -> Bool {
        used.contains(code)
    }

    func markUsed(_ code: String) {
        used.insert(code)
    }
}


// ============================================================
// MARK: - 4. ✅ Seam 3 — Pure Function for the Rule
// ============================================================

/*
 "Functional core, imperative shell":
 the decision is a PURE function — same inputs, same output,
 no side effects. The easiest thing in the world to test.
*/

enum CouponRules {

    static func isValid(isUsed: Bool, now: Date, expiry: Date) -> Bool {
        !isUsed && now < expiry
    }
}


// ============================================================
// MARK: - 5. ✅ Testable Service
// ============================================================

final class CouponService {

    private let storage: CouponStorage
    private let now: DateProvider

    init(storage: CouponStorage = UserDefaultsCouponStorage(),
         now: @escaping DateProvider = { Date() }) {              // defaults → app code stays simple
        self.storage = storage
        self.now = now
    }

    func canUse(code: String, expiry: Date) -> Bool {
        CouponRules.isValid(isUsed: storage.isUsed(code), now: now(), expiry: expiry)
    }

    func redeem(code: String, expiry: Date) -> Bool {
        guard canUse(code: code, expiry: expiry) else {
            return false
        }
        storage.markUsed(code)
        return true
    }
}


// ============================================================
// MARK: - 6. ✅ Seam 4 — Control Randomness
// ============================================================

final class SpinWheel {

    private let random: (ClosedRange<Int>) -> Int

    init(random: @escaping (ClosedRange<Int>) -> Int = { Int.random(in: $0) }) {
        self.random = random
    }

    func discountPercent() -> Int {
        random(5...50)
    }
}


// ============================================================
// MARK: - 7. Tests
// ============================================================

final class TestableArchitectureTests: XCTestCase {

    private let jan1 = Date(timeIntervalSince1970: 1_767_225_600)          // fixed "now"

    private var expiryJan10: Date {
        jan1.addingTimeInterval(9 * 24 * 60 * 60)
    }

    private func makeSUT(now: Date) -> (CouponService, InMemoryCouponStorage) {
        let storage = InMemoryCouponStorage()
        let sut = CouponService(storage: storage, now: { now })
        return (sut, storage)
    }


    // Pure function — no setup at all
    func test_rules_unusedAndNotExpired_isValid() {
        XCTAssertTrue(CouponRules.isValid(isUsed: false, now: jan1, expiry: expiryJan10))
    }

    func test_rules_expired_isInvalid() {
        XCTAssertFalse(CouponRules.isValid(isUsed: false, now: expiryJan10, expiry: jan1))
    }


    // Injected time
    func test_canUse_beforeExpiry_true() {
        let (sut, _) = makeSUT(now: jan1)

        XCTAssertTrue(sut.canUse(code: "SALE10", expiry: expiryJan10))
    }

    func test_canUse_afterExpiry_false() {
        let (sut, _) = makeSUT(now: expiryJan10.addingTimeInterval(1))

        XCTAssertFalse(sut.canUse(code: "SALE10", expiry: expiryJan10))
    }


    // Injected storage
    func test_redeem_twice_secondFails() {
        let (sut, storage) = makeSUT(now: jan1)

        XCTAssertTrue(sut.redeem(code: "SALE10", expiry: expiryJan10))
        XCTAssertFalse(sut.redeem(code: "SALE10", expiry: expiryJan10))
        XCTAssertTrue(storage.isUsed("SALE10"))
    }


    // Injected randomness
    func test_spinWheel_usesInjectedRandom() {
        let sut = SpinWheel(random: { _ in 25 })

        XCTAssertEqual(sut.discountPercent(), 25)
    }
}


// ============================================================
// MARK: - 8. Run the Tests
// ============================================================

let suite = TestableArchitectureTests.defaultTestSuite

suite.run()

if let run = suite.testRun {
    print("DEBUG Q02 - Tests run:", run.executionCount)              // 6
    print("DEBUG Q03 - Failures:", run.totalFailureCount)            // 0
}


// ============================================================
// MARK: - 9. Hidden Dependency → Seam Cheat Sheet
// ============================================================

/*
 ┌──────────────────────────┬────────────────────────────────────────┐
 │ Hidden dependency        │ Seam                                   │
 ├──────────────────────────┼────────────────────────────────────────┤
 │ Date()                   │ now: () -> Date  /  Clock protocol     │
 │ UserDefaults.standard    │ storage protocol / injected suite      │
 │ URLSession.shared        │ APIClient protocol / URLProtocol stub  │
 │ Int.random / UUID()      │ injected generator closure             │
 │ Singleton.shared         │ protocol + default value .shared       │
 │ UIKit in logic           │ move logic to ViewModel / pure function│
 │ DispatchQueue.main.after │ inject delay / scheduler               │
 └──────────────────────────┴────────────────────────────────────────┘
*/


// ============================================================
// MARK: - 10. Testable Architecture Checklist
// ============================================================

/*
 ✅ Dependencies injected (init + protocols)        → 13_Design_Patterns/05_DI
 ✅ Logic in ViewModels / UseCases, not views       → 12_Architecture
 ✅ Pure functions for rules and calculations
 ✅ Time, randomness, IDs injected
 ✅ One composition root swaps real ↔ test doubles
 ✅ Small types with one job                         → 14_SOLID/01_SRP

 Test pyramid:
 Many unit tests  →  some integration tests  →  few UI tests
*/


// ============================================================
// MARK: - 11. Senior Interview Questions
// ============================================================

/*
 Q1. What makes code hard to test?

 Answer:
 Hidden dependencies — Date(), singletons, UserDefaults,
 real network, randomness, and logic inside UIKit views.


 Q2. What is a seam?

 Answer:
 A place where a test can swap behaviour — a protocol,
 closure, or parameter instead of a hard-coded call.


 Q3. How do you test time-based logic?

 Answer:
 Inject the current date (closure or Clock protocol) and
 pass fixed dates in tests.


 Q4. What is "functional core, imperative shell"?

 Answer:
 Keep decisions in pure functions, and keep side effects
 (storage, network) in a thin outer layer.


 Q5. How do you keep app code simple while injecting everything?

 Answer:
 Use default parameter values for the real dependencies;
 tests pass doubles explicitly.


 Q6. What is the test pyramid?

 Answer:
 Many fast unit tests, fewer integration tests, and only
 a few slow UI tests.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   ❌ Hidden:   CouponService ──→ Date()  ──→ UserDefaults.standard

   ✅ Seams:    CouponService(storage: CouponStorage, now: () -> Date)
                       ↓                      ↓
                 App: UserDefaults      App: Date()
                 Test: InMemory         Test: fixed date


 Remember:

 If a test can't control it
          ↓
 make it a seam
*/
