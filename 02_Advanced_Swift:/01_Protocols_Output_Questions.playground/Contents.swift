import Foundation

// ============================================================
// PROTOCOLS & POP — OUTPUT / DEBUG QUESTIONS
// Senior iOS Interview Preparation
// ============================================================


// MARK: - Q01. Protocol Requirement + Default Implementation

protocol Vehicle01 {
    func start()
}

extension Vehicle01 {
    func start() {
        print("Q01 → Protocol")
    }
}

struct Car01: Vehicle01 {
    func start() {
        print("Q01 → Car")
    }
}

let car01 = Car01()
let vehicle01: Vehicle01 = car01

print("\n========== DEBUG Q01 ==========")
car01.start()
vehicle01.start()
print("================================")

// Expected:
// Q01 → Car
// Q01 → Car


// MARK: - Q02. Protocol Default Implementation

protocol Vehicle02 {
    func start()
}

extension Vehicle02 {
    func start() {
        print("Q02 → Protocol")
    }
}

struct Car02: Vehicle02 {}

let car02 = Car02()
let vehicle02: Vehicle02 = car02

print("\n========== DEBUG Q02 ==========")
car02.start()
vehicle02.start()
print("================================")

// Expected:
// Q02 → Protocol
// Q02 → Protocol


// MARK: - Q03. Extension-Only Method
// Method is NOT declared in the protocol.

protocol Vehicle03 {}

extension Vehicle03 {
    func start() {
        print("Q03 → Protocol")
    }
}

struct Car03: Vehicle03 {
    func start() {
        print("Q03 → Car")
    }
}

let car03 = Car03()
let vehicle03: Vehicle03 = car03

print("\n========== DEBUG Q03 ==========")
car03.start()
vehicle03.start()
print("================================")

// Expected:
// Q03 → Car
// Q03 → Protocol


// MARK: - Q04. Class Inheritance + Protocol Witness

protocol Vehicle04 {
    func start()
}

extension Vehicle04 {
    func start() {
        print("Q04 → Protocol")
    }
}

class Car04: Vehicle04 {}

class BMW04: Car04 {
    func start() {
        print("Q04 → BMW")
    }
}

let bmw04 = BMW04()
let vehicle04: Vehicle04 = bmw04

print("\n========== DEBUG Q04 ==========")
bmw04.start()
vehicle04.start()
print("================================")

// Expected:
// Q04 → BMW
// Q04 → Protocol


// MARK: - Q05. Class Dynamic Dispatch + Protocol Requirement

protocol Vehicle05 {
    func start()
}

extension Vehicle05 {
    func start() {
        print("Q05 → Protocol")
    }
}

class Car05: Vehicle05 {
    func start() {
        print("Q05 → Car")
    }
}

class BMW05: Car05 {
    override func start() {
        print("Q05 → BMW")
    }
}

let car05: Car05 = BMW05()
let vehicle05: Vehicle05 = BMW05()

print("\n========== DEBUG Q05 ==========")
car05.start()
vehicle05.start()
print("================================")

// Expected:
// Q05 → BMW
// Q05 → BMW


// MARK: - Q06. Concrete Type vs Protocol Type

protocol Vehicle06 {
    func start()
}

struct Car06: Vehicle06 {
    func start() {
        print("Q06 → Car")
    }
}

let car06 = Car06()
let vehicle06: Vehicle06 = car06

print("\n========== DEBUG Q06 ==========")
car06.start()
vehicle06.start()
print("================================")

// Expected:
// Q06 → Car
// Q06 → Car


// MARK: - Q07. Multiple Protocols

protocol Flyable07 {
    func fly()
}

protocol Swimmable07 {
    func swim()
}

struct Duck07: Flyable07, Swimmable07 {
    func fly() {
        print("Q07 → Flying")
    }

    func swim() {
        print("Q07 → Swimming")
    }
}

let duck07: Flyable07 & Swimmable07 = Duck07()

print("\n========== DEBUG Q07 ==========")
duck07.fly()
duck07.swim()
print("================================")

// Expected:
// Q07 → Flying
// Q07 → Swimming


// MARK: - Q08. Protocol Composition

protocol Printable08 {
    func printData()
}

protocol Identifiable08 {
    var id: Int { get }
}

struct Product08: Printable08, Identifiable08 {
    let id: Int

    func printData() {
        print("Q08 → Product")
    }
}

let product08: Printable08 & Identifiable08 = Product08(id: 101)

print("\n========== DEBUG Q08 ==========")
product08.printData()
print("Q08 → ID:", product08.id)
print("================================")

// Expected:
// Q08 → Product
// Q08 → ID: 101


// MARK: - Q09. AnyObject — Class-Only Protocol

protocol Delegate09: AnyObject {
    func completed()
}

class Controller09: Delegate09 {
    func completed() {
        print("Q09 → Completed")
    }
}

let delegate09: Delegate09 = Controller09()

print("\n========== DEBUG Q09 ==========")
delegate09.completed()
print("================================")

// Expected:
// Q09 → Completed


// MARK: - Q10. Weak Delegate

protocol LoginDelegate10: AnyObject {
    func loginCompleted()
}

class LoginViewController10 {
    weak var delegate: LoginDelegate10?

    func login() {
        delegate?.loginCompleted()
    }
}

class LoginCoordinator10: LoginDelegate10 {
    func loginCompleted() {
        print("Q10 → Login Completed")
    }
}

let loginVC10 = LoginViewController10()
let coordinator10 = LoginCoordinator10()

loginVC10.delegate = coordinator10

print("\n========== DEBUG Q10 ==========")
loginVC10.login()
print("================================")

// Expected:
// Q10 → Login Completed


// MARK: - Q11. Protocol Inheritance

protocol Animal11 {
    func eat()
}

protocol Pet11: Animal11 {
    func play()
}

struct Dog11: Pet11 {
    func eat() {
        print("Q11 → Eating")
    }

    func play() {
        print("Q11 → Playing")
    }
}

let dog11 = Dog11()

print("\n========== DEBUG Q11 ==========")
dog11.eat()
dog11.play()
print("================================")

// Expected:
// Q11 → Eating
// Q11 → Playing


// MARK: - Q12. Protocol Initializer Requirement

protocol Identifiable12 {
    init(id: Int)
}

struct User12: Identifiable12 {
    let id: Int

    init(id: Int) {
        self.id = id
    }
}

let user12 = User12(id: 100)

print("\n========== DEBUG Q12 ==========")
print("Q12 → ID:", user12.id)
print("================================")

// Expected:
// Q12 → ID: 100


// MARK: - Q13. Required Initializer

protocol ServiceProtocol13 {
    init(name: String)
}

class Service13: ServiceProtocol13 {
    let name: String

    required init(name: String) {
        self.name = name
    }
}

let service13 = Service13(name: "API")

print("\n========== DEBUG Q13 ==========")
print("Q13 →", service13.name)
print("================================")

// Expected:
// Q13 → API


// MARK: - Q14. Associated Type

protocol Storage14 {
    associatedtype Item

    func save(_ item: Item)
}

struct StringStorage14: Storage14 {
    func save(_ item: String) {
        print("Q14 → String:", item)
    }
}

struct IntStorage14: Storage14 {
    func save(_ item: Int) {
        print("Q14 → Int:", item)
    }
}

print("\n========== DEBUG Q14 ==========")
StringStorage14().save("Swift")
IntStorage14().save(100)
print("================================")

// Expected:
// Q14 → String: Swift
// Q14 → Int: 100


// MARK: - Q15. Self Requirement

protocol Copyable15 {
    func copy() -> Self
}

final class User15: Copyable15 {
    func copy() -> Self {
        return self
    }
}

let user15 = User15()
let copy15 = user15.copy()

print("\n========== DEBUG Q15 ==========")
print("Q15 →", type(of: copy15))
print("================================")

// Expected:
// Q15 → User15


// MARK: - Q16. Protocol-Oriented Programming

protocol Logger16 {
    func log(_ message: String)
}

extension Logger16 {
    func log(_ message: String) {
        print("Q16 → [LOG]", message)
    }
}

struct NetworkManager16: Logger16 {}
struct DatabaseManager16: Logger16 {}

print("\n========== DEBUG Q16 ==========")
NetworkManager16().log("Request Started")
DatabaseManager16().log("Database Updated")
print("================================")

// Expected:
// Q16 → [LOG] Request Started
// Q16 → [LOG] Database Updated


// MARK: - Q17. Protocol Dependency Injection

protocol APIClient17 {
    func fetch()
}

struct ProductionAPI17: APIClient17 {
    func fetch() {
        print("Q17 → Production API")
    }
}

struct MockAPI17: APIClient17 {
    func fetch() {
        print("Q17 → Mock API")
    }
}

struct UserViewModel17 {
    let apiClient: APIClient17

    func load() {
        apiClient.fetch()
    }
}

let productionVM17 = UserViewModel17(apiClient: ProductionAPI17())
let testVM17 = UserViewModel17(apiClient: MockAPI17())

print("\n========== DEBUG Q17 ==========")
productionVM17.load()
testVM17.load()
print("================================")

// Expected:
// Q17 → Production API
// Q17 → Mock API


// MARK: - Q18. Protocol Composition with Concrete Type

protocol Readable18 {
    func read()
}

protocol Writable18 {
    func write()
}

struct File18: Readable18, Writable18 {
    func read() {
        print("Q18 → Read")
    }

    func write() {
        print("Q18 → Write")
    }
}

let file18: Readable18 & Writable18 = File18()

print("\n========== DEBUG Q18 ==========")
file18.read()
file18.write()
print("================================")

// Expected:
// Q18 → Read
// Q18 → Write


// MARK: - Q19. Protocol Requirement Dispatch

protocol Device19 {
    func run()
}

extension Device19 {
    func run() {
        print("Q19 → Protocol")
    }
}

struct Phone19: Device19 {
    func run() {
        print("Q19 → Phone")
    }
}

let phone19 = Phone19()
let device19: Device19 = phone19

print("\n========== DEBUG Q19 ==========")
phone19.run()
device19.run()
print("================================")

// Expected:
// Q19 → Phone
// Q19 → Phone


// MARK: - Q20. Extension-Only Dispatch Trap

protocol Device20 {}

extension Device20 {
    func run() {
        print("Q20 → Protocol")
    }
}

struct Phone20: Device20 {
    func run() {
        print("Q20 → Phone")
    }
}

let phone20 = Phone20()
let device20: Device20 = phone20

print("\n========== DEBUG Q20 ==========")
phone20.run()
device20.run()
print("================================")

// Expected:
// Q20 → Phone
// Q20 → Protocol
