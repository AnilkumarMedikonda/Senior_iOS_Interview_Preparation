import Foundation
import XCTest

// ============================================================
// MARK: - XCTEST BASICS
// ============================================================

/*
 Unit test = small, fast code that checks ONE behaviour of
 ONE unit (function / type) and passes or fails by itself.

 XCTest = Apple's testing framework.

 In a project:  ⌘U runs all tests.
 In this playground: SuiteName.defaultTestSuite.run()

 Every test follows Arrange → Act → Assert.
*/


// ============================================================
// MARK: - 1. Code Under Test
// ============================================================

/*
 The "System Under Test" (SUT) — plain Swift, no UI, no network.
*/

enum CartError: Error, Equatable {
    case invalidDiscount
}

struct Cart {

    private(set) var prices: [Double] = []

    var itemCount: Int {
        prices.count
    }

    var total: Double {
        prices.reduce(0, +)
    }

    mutating func add(price: Double) {
        prices.append(price)
    }

    func total(withDiscountPercent percent: Double) throws -> Double {
        guard (0...100).contains(percent) else {
            throw CartError.invalidDiscount
        }
        return total * (1 - percent / 100)
    }
}


// ============================================================
// MARK: - 2. Test Case Structure
// ============================================================

/*
 - Subclass XCTestCase
 - Each test method starts with "test"
 - setUp()    → runs BEFORE every test (fresh state)
 - tearDown() → runs AFTER every test (clean up)

 Naming: test_<unit>_<condition>_<expected>
*/

final class CartTests: XCTestCase {

    private var sut: Cart!                                   // System Under Test

    override func setUp() {
        super.setUp()
        sut = Cart()                                         // ✅ new cart for EVERY test
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }


    // ========================================================
    // MARK: - 3. Arrange → Act → Assert
    // ========================================================

    func test_add_twoItems_totalIsSum() {

        // Arrange
        sut.add(price: 499)

        // Act
        sut.add(price: 1500)

        // Assert
        XCTAssertEqual(sut.total, 1999)
        XCTAssertEqual(sut.itemCount, 2)
    }


    // ========================================================
    // MARK: - 4. Common Assertions
    // ========================================================

    func test_newCart_isEmpty() {
        XCTAssertTrue(sut.prices.isEmpty)
        XCTAssertEqual(sut.total, 0)
    }

    func test_discount_tenPercent_reducesTotal() throws {
        sut.add(price: 1000)

        let discounted = try sut.total(withDiscountPercent: 10)

        XCTAssertEqual(discounted, 900, accuracy: 0.001)      // Doubles → use accuracy
    }

    func test_discount_over100_throwsInvalidDiscount() {
        sut.add(price: 1000)

        XCTAssertThrowsError(try sut.total(withDiscountPercent: 150)) { error in
            XCTAssertEqual(error as? CartError, .invalidDiscount)
        }
    }

    func test_firstPrice_exists_afterAdding() throws {
        sut.add(price: 299)

        let first = try XCTUnwrap(sut.prices.first)          // fails the test (not crash) if nil

        XCTAssertEqual(first, 299)
    }


    // ========================================================
    // MARK: - 5. A Failing Test (on purpose)
    // ========================================================

    /*
     Shows what a failure looks like in the console:
     "XCTAssertEqual failed: ("1") is not equal to ("2") - …"
    */

    func test_intentionalFailure_showsMessage() {
        sut.add(price: 100)

        XCTAssertEqual(sut.itemCount, 2, "Demo: this test fails on purpose")
    }
}


// ============================================================
// MARK: - 6. Run the Tests
// ============================================================

let suite = CartTests.defaultTestSuite

suite.run()

if let run = suite.testRun {
    print("DEBUG Q01 - Tests run:", run.executionCount)                 // 6
    print("DEBUG Q02 - Failures:", run.totalFailureCount)               // 1 (the intentional one)
}


// ============================================================
// MARK: - 7. Assertion Cheat Sheet
// ============================================================

/*
 XCTAssertEqual(a, b)                 → values equal
 XCTAssertEqual(a, b, accuracy: 0.01) → Doubles
 XCTAssertTrue / XCTAssertFalse       → Bool
 XCTAssertNil / XCTAssertNotNil       → Optionals
 XCTAssertThrowsError(try f())        → must throw
 XCTAssertNoThrow(try f())            → must not throw
 try XCTUnwrap(optional)              → unwrap or fail (no crash)
 XCTFail("message")                   → fail manually
*/


// ============================================================
// MARK: - 8. Swift Testing (Xcode 16+)
// ============================================================

/*
 Apple's newer framework — can live next to XCTest.

 import Testing

 @Suite struct CartSwiftTests {

     @Test func addingItemsSumsTotal() {
         var cart = Cart()
         cart.add(price: 499)
         #expect(cart.total == 499)
     }

     @Test(arguments: [10.0, 50.0, 100.0])          // parameterized
     func validDiscountsDoNotThrow(percent: Double) throws {
         #expect(throws: Never.self) {
             try Cart().total(withDiscountPercent: percent)
         }
     }
 }

 #expect   → like XCTAssert (keeps going)
 #require  → like XCTUnwrap (stops the test)
 Structs, not classes; each test gets a fresh instance automatically.
*/


// ============================================================
// MARK: - 9. Good Test Rules (F.I.R.S.T.)
// ============================================================

/*
 Fast             → milliseconds, no network / disk / sleep
 Independent      → setUp gives fresh state; no test depends on another
 Repeatable       → same result every run
 Self-validating  → assertions decide pass / fail
 Timely           → written with the code

 One behaviour per test → when it fails, the name tells you what broke.
*/


// ============================================================
// MARK: - 10. Senior Interview Questions
// ============================================================

/*
 Q1. What is a unit test?

 Answer:
 A fast, isolated test of one behaviour of one unit,
 with no network, database or UI.


 Q2. What do setUp and tearDown do?

 Answer:
 setUp runs before every test to create fresh state;
 tearDown runs after every test to clean up.


 Q3. What is Arrange-Act-Assert?

 Answer:
 Set up the inputs, perform the action, then assert the
 expected result.


 Q4. Why use XCTUnwrap instead of force unwrapping?

 Answer:
 A nil value fails the test with a message instead of
 crashing the whole test run.


 Q5. How do you test that a function throws?

 Answer:
 XCTAssertThrowsError, and check the error inside its closure.


 Q6. XCTest vs Swift Testing?

 Answer:
 Swift Testing (Xcode 16+) uses @Test and #expect, structs,
 and built-in parameterized tests; XCTest uses XCTestCase
 classes and XCTAssert functions. Both can coexist.


 Q7. What makes a good unit test?

 Answer:
 F.I.R.S.T. — fast, independent, repeatable,
 self-validating, timely — and one behaviour per test.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   setUp()          → fresh SUT
      ↓
   Arrange          → inputs
      ↓
   Act              → call the method
      ↓
   Assert           → XCTAssert...
      ↓
   tearDown()       → clean up


 Remember:

 One test
     =
 One behaviour
     =
 One clear name
*/
