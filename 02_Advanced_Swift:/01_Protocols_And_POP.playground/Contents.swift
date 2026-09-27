import Foundation

//==============================================================
// MARK: - Protocols & POP
//==============================================================
// Protocol = a contract. POP = build behavior by composing protocols
// + extensions instead of deep class inheritance.
// some / any → 02_Any_vs_Some

//==============================================================
// MARK: - 01. Protocol Basics
//==============================================================

protocol Vehicle {
    var brand: String { get }
    func start()
}

struct Car: Vehicle {
    let brand: String

    func start() {
        print("Car Started")
    }
}

print("\n========== 01 - Protocol Basics ==========")
let car = Car(brand: "BMW")
print(car.brand) // BMW
car.start()      // Car Started

//==============================================================
// MARK: - 02. Property Requirements
//==============================================================
// { get } → let or var allowed. { get set } → must be var.

protocol UserProfile {
    var name: String { get }
    var age: Int { get set }
}

struct User: UserProfile {
    let name: String
    var age: Int
}

print("\n========== 02 - Property Requirements ==========")
var user = User(name: "Anil", age: 30)
user.age = 31
print(user.name, user.age) // Anil 31

//==============================================================
// MARK: - 03. Default Implementation
//==============================================================
// Extension gives shared behavior — conformers get it for free.

protocol Logger {
    func log(_ message: String)
}

extension Logger {
    func log(_ message: String) {
        print("[LOG]", message)
    }
}

struct NetworkManager: Logger {}
struct DatabaseManager: Logger {}

print("\n========== 03 - Default Implementation ==========")
NetworkManager().log("Request Started")  // [LOG] Request Started
DatabaseManager().log("Database Updated") // [LOG] Database Updated

//==============================================================
// MARK: - 04. Requirement vs Extension-Only Method
//==============================================================
// Requirement → dynamic dispatch (uses the conforming type's version).
// Extension-only → static dispatch (uses the declared type's version).

protocol Device {
    func start()
}

extension Device {
    func start() { print("Protocol Start") }
    func reset() { print("Protocol Reset") }
}

struct Phone: Device {
    func start() { print("Phone Start") }
    func reset() { print("Phone Reset") }
}

print("\n========== 04 - Requirement vs Extension-Only Method ==========")
let phone = Phone()
phone.start()  // Phone Start
phone.reset()  // Phone Reset

let device: Device = phone
device.start() // Phone Start    — requirement
device.reset() // Protocol Reset — extension-only, static dispatch

//==============================================================
// MARK: - 05. Protocol Composition
//==============================================================

protocol Flyable {
    func fly()
}

protocol Swimmable {
    func swim()
}

struct Duck: Flyable, Swimmable {
    func fly() { print("Flying") }
    func swim() { print("Swimming") }
}

print("\n========== 05 - Protocol Composition ==========")
let duck: Flyable & Swimmable = Duck()
duck.fly()  // Flying
duck.swim() // Swimming

//==============================================================
// MARK: - 06. Class-Only Protocol + Delegate
//==============================================================
// AnyObject → only classes conform → allows weak var delegate.

protocol LoginDelegate: AnyObject {
    func loginDidComplete()
}

final class LoginViewController {
    weak var delegate: LoginDelegate?

    func login() {
        print("Login")
        delegate?.loginDidComplete()
    }
}

final class LoginCoordinator: LoginDelegate {
    func loginDidComplete() {
        print("Login Completed")
    }
}

print("\n========== 06 - Class-Only Protocol + Delegate ==========")
let loginVC = LoginViewController()
let coordinator = LoginCoordinator()
loginVC.delegate = coordinator
loginVC.login() // Login | Login Completed

//==============================================================
// MARK: - 07. mutating Requirement
//==============================================================
// Needed so structs can change self. Classes implement it without mutating.

protocol Toggleable {
    mutating func toggle()
}

struct Switch: Toggleable {
    var isOn = false

    mutating func toggle() {
        isOn.toggle()
    }
}

final class Light: Toggleable {
    var isOn = false

    func toggle() {
        isOn.toggle()
    }
}

print("\n========== 07 - mutating Requirement ==========")
var lightSwitch = Switch()
lightSwitch.toggle()
print(lightSwitch.isOn) // true
let light = Light()
light.toggle()
print(light.isOn)       // true

//==============================================================
// MARK: - 08. Optional Requirements
//==============================================================
// @objc optional → Objective-C style, classes only, called with ?.
// Swift way → default implementation in an extension (section 03).

@objc protocol TableDelegate {
    func didSelect()
    @objc optional func didHighlight()
}

final class TableHandler: NSObject, TableDelegate {
    func didSelect() {
        print("Selected")
    }
}

print("\n========== 08 - Optional Requirements ==========")
let tableDelegate: TableDelegate = TableHandler()
tableDelegate.didSelect()      // Selected
tableDelegate.didHighlight?()  // Nothing — not implemented, no crash

//==============================================================
// MARK: - 09. Associated Type
//==============================================================
// Placeholder type chosen by each conforming type.

protocol Storage {
    associatedtype Item
    func save(_ item: Item)
}

struct StringStorage: Storage {
    func save(_ item: String) {
        print("Saved:", item)
    }
}

struct IntStorage: Storage {
    func save(_ item: Int) {
        print("Saved:", item)
    }
}

print("\n========== 09 - Associated Type ==========")
StringStorage().save("Swift") // Saved: Swift
IntStorage().save(100)        // Saved: 100

//==============================================================
// MARK: - 10. Self Requirement
//==============================================================
// Self = the concrete conforming type.

protocol Copyable {
    func copy() -> Self
}

struct Point: Copyable {
    var x: Int

    func copy() -> Self {
        self // value type → returns an independent copy
    }
}

print("\n========== 10 - Self Requirement ==========")
let original = Point(x: 1)
var copied = original.copy()
copied.x = 99
print(original.x, copied.x) // 1 99

//==============================================================
// MARK: - 11. Protocol Inheritance
//==============================================================

protocol Animal {
    func eat()
}

protocol Pet: Animal {
    func play()
}

struct Dog: Pet {
    func eat() { print("Dog Eating") }
    func play() { print("Dog Playing") }
}

print("\n========== 11 - Protocol Inheritance ==========")
let dog = Dog()
dog.eat()  // Dog Eating
dog.play() // Dog Playing

//==============================================================
// MARK: - 12. Initializer Requirement
//==============================================================
// Struct → plain init. Non-final class → must be `required`
// so every subclass also satisfies the protocol.

protocol Configurable {
    init(name: String)
}

struct LocalConfig: Configurable {
    let name: String

    init(name: String) {
        self.name = name
    }
}

class Service: Configurable {
    let name: String

    required init(name: String) {
        self.name = name
    }
}

print("\n========== 12 - Initializer Requirement ==========")
print(LocalConfig(name: "Local").name) // Local
print(Service(name: "API").name)       // API

//==============================================================
// MARK: - 13. Constrained Extension
//==============================================================
// Add behavior only when a condition holds.

extension Collection where Element: Numeric {
    func total() -> Element {
        var sum: Element = 0
        for element in self { sum += element }
        return sum
    }
}

print("\n========== 13 - Constrained Extension ==========")
print([1, 2, 3].total())  // 6
print([1.5, 2.5].total()) // 4.0
// ["a", "b"].total()     ❌ String is not Numeric

//==============================================================
// MARK: - 14. Protocol-Based Dependency Injection
//==============================================================
// Depend on the protocol, not the concrete type → easy to mock in tests.

protocol APIClient {
    func fetchData()
}

final class ProductionAPIClient: APIClient {
    func fetchData() { print("Production API") }
}

final class MockAPIClient: APIClient {
    func fetchData() { print("Mock API") }
}

final class UserViewModel {
    private let apiClient: APIClient

    init(apiClient: APIClient) {
        self.apiClient = apiClient
    }

    func loadUsers() {
        apiClient.fetchData()
    }
}

print("\n========== 14 - Protocol-Based Dependency Injection ==========")
UserViewModel(apiClient: ProductionAPIClient()).loadUsers() // Production API
UserViewModel(apiClient: MockAPIClient()).loadUsers()       // Mock API

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a protocol? What is POP?
// 2. POP vs class inheritance — why prefer protocols?
// 3. Requirement vs extension-only method — which version gets called?
// 4. Why does a delegate protocol need AnyObject?
// 5. Why do protocol methods need mutating?
// 6. Can protocols have optional methods? @objc optional vs default implementation?
// 7. What is an associatedtype?
// 8. Why must a class mark a protocol's init as required?
// 9. What is a constrained extension?
// 10. How do protocols help with dependency injection and testing?
//
//==============================================================
