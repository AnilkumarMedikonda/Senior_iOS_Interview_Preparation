import Foundation

// ============================================================
// MARK: - ISP: INTERFACE SEGREGATION PRINCIPLE
// ============================================================

/*
 ISP:

 Clients should not be forced to depend on methods
 they do not use.

 Prefer SMALL, FOCUSED protocols over one large protocol.
*/


// ============================================================
// MARK: - 1. ❌ Bad Example
// ============================================================

/*
 One large protocol forces every implementation to provide
 methods it may not need.
*/

protocol Worker {

    func work()
    func eat()
}

final class OldRobot: Worker {

    func work() {
        print("Robot is working")
    }

    func eat() {
        print("❌ Robot can't eat — forced to write a fake method")
    }
}

let oldRobot = OldRobot()

oldRobot.work()

oldRobot.eat()

print("DEBUG Q01 - ❌ Fat protocol forces a fake eat()")


// ============================================================
// MARK: - 2. ✅ ISP Solution
// ============================================================

/*
 Split the large protocol into smaller, focused protocols.
*/

protocol Workable {

    func work()
}

protocol Eatable {

    func eat()
}


// ============================================================
// MARK: - 3. Implementations
// ============================================================

final class Developer: Workable, Eatable {

    func work() {
        print("Developer is working")
    }

    func eat() {
        print("Developer is eating")
    }
}


final class Robot: Workable {

    func work() {
        print("Robot is working")
    }
}


// ============================================================
// MARK: - 4. Usage
// ============================================================

let developer = Developer()
developer.work()
developer.eat()

let robot = Robot()
robot.work()

// Clients ask only for what they use
func startShift(_ worker: Workable) {
    worker.work()
}

startShift(developer)
startShift(robot)

print("DEBUG Q02 - ✅ Robot only implements what it can do")


// ============================================================
// MARK: - 5. Real iOS Example — Fat Service Protocol
// ============================================================

/*
 ❌ One big protocol for every screen:

 protocol ProductServiceProtocol {
     func fetchProducts() -> [String]
     func createProduct(_ name: String)
     func deleteProduct(_ name: String)
     func uploadImage(_ data: Data)
 }

 A read-only Product List screen depends on create/delete/upload
 it never uses, and its mock must fake all four.


 ✅ Split by capability:
*/

protocol ProductFetching {

    func fetchProducts() -> [String]
}

protocol ProductEditing {

    func createProduct(_ name: String)
    func deleteProduct(_ name: String)
}

// Combine when a screen really needs both
typealias ProductManaging = ProductFetching & ProductEditing

final class ProductService: ProductManaging {

    private var products = ["Shoes", "Cap"]

    func fetchProducts() -> [String] {
        products
    }

    func createProduct(_ name: String) {
        products.append(name)
    }

    func deleteProduct(_ name: String) {
        products.removeAll { $0 == name }
    }
}

final class ProductListViewModel {

    private let service: ProductFetching                     // only what it uses

    init(service: ProductFetching) {
        self.service = service
    }

    func titles() -> [String] {
        service.fetchProducts()
    }
}

final class MockProductFetching: ProductFetching {           // tiny mock — one method

    func fetchProducts() -> [String] {
        ["Mock Product"]
    }
}

let service = ProductService()

service.createProduct("Socks")

print("DEBUG Q03 - Real:", ProductListViewModel(service: service).titles())                  // ["Shoes", "Cap", "Socks"]

print("DEBUG Q04 - Mock:", ProductListViewModel(service: MockProductFetching()).titles())    // ["Mock Product"]


// ============================================================
// MARK: - 6. High-Level Flow
// ============================================================

/*
 ❌ Large Interface

 Worker
   ├── work()
   └── eat()      ← Robot forced to fake this


 ✅ Segregated Interfaces

 Workable              Eatable
    ↑                     ↑
    ├── Developer ────────┘
    └── Robot


 Robot does not need to implement eat().
*/


// ============================================================
// MARK: - 7. ISP in Apple Frameworks
// ============================================================

/*
 UITableViewDataSource   vs   UITableViewDelegate   → data vs behaviour
 Encodable & Decodable   =    Codable               → composed small protocols
 Equatable, Hashable, Comparable                    → one capability each
*/


// ============================================================
// MARK: - 8. Senior Point
// ============================================================

/*
 ISP means:

 Keep interfaces small and focused.

 A type should depend only on the capabilities
 it actually needs.
*/


// ============================================================
// MARK: - 9. Senior Interview Questions
// ============================================================

/*
 Q1. What is ISP?

 Answer:
 Clients shouldn't be forced to depend on methods
 they don't use — prefer small, focused protocols.


 Q2. How do you spot a violation?

 Answer:
 Conforming types write empty / fatalError methods,
 or mocks must fake many unused methods.


 Q3. How do you fix a fat protocol?

 Answer:
 Split it by capability and compose with & when a
 type needs several.


 Q4. Give an Apple example.

 Answer:
 UITableViewDataSource vs UITableViewDelegate, and
 Codable = Encodable & Decodable.


 Q5. How does ISP help testing?

 Answer:
 Mocks only implement the few methods the code
 under test actually uses.


 Q6. How is ISP related to LSP?

 Answer:
 Fat protocols force fake methods, which break the
 contract (LSP). Small protocols prevent that.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

        ❌ FAT PROTOCOL

   ProductServiceProtocol
   fetch · create · delete · upload
              ↑
   ListViewModel uses only fetch


        ✅ SEGREGATED

   ProductFetching      ProductEditing
         ↑                    ↑
   ListViewModel        EditViewModel

   ProductManaging = ProductFetching & ProductEditing


 Remember:

 Many small protocols
          >
 One big protocol
*/


// ============================================================
// MARK: - Interview One-Liner
// ============================================================

/*
 "Interface Segregation Principle says clients should not
 be forced to depend on methods they do not use."
*/
