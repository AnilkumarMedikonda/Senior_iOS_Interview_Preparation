import Foundation

//==============================================================
// MARK: - 05. Properties
//==============================================================
// Property wrappers → 02_Advanced_Swift/04_Property_Wrappers
//==============================================================

//==============================================================
// MARK: - 1. Stored Properties
//==============================================================

struct User {
    let id: Int
    var name: String
    var isPremium = false
}

print("\n========== 01 - Stored Properties ==========")
var user = User(id: 101, name: "Anil")
user.name = "John"
print(user.name)   // John
// user.id = 102                 ❌ let property
let fixedUser = User(id: 102, name: "Ravi")
// fixedUser.name = "Sam"        ❌ let struct freezes var properties

//==============================================================
// MARK: - 2. Computed Properties
//==============================================================
// No storage, recalculated on every access. Always var.

struct Temperature {
    var celsius: Double

    var fahrenheit: Double {
        get { (celsius * 9 / 5) + 32 }
        set { celsius = (newValue - 32) * 5 / 9 }
    }

    var isFreezing: Bool {
        celsius <= 0
    }
}

print("\n========== 02 - Computed Properties ==========")
var temperature = Temperature(celsius: 25)
print(temperature.fahrenheit)   // 77.0
temperature.fahrenheit = 86
print(temperature.celsius)      // 30.0
print(temperature.isFreezing)   // false
// temperature.isFreezing = true   ❌ Read-only

//==============================================================
// MARK: - 3. Lazy Properties
//==============================================================
// Initialized on first access. Must be var.
// ❌ Not thread-safe  ❌ No observers  ❌ Not accessible on a let struct

final class DataManager {
    lazy var cache: [String: String] = {
        print("Creating cache")
        return ["user": "Anil"]
    }()
}

print("\n========== 03 - Lazy Properties ==========")
let manager = DataManager()
print(manager.cache.count)   // Creating cache → 1
print(manager.cache.count)   // 1 — created once

//==============================================================
// MARK: - 4. Lazy and Retain Cycles
//==============================================================
// { }() runs once → safe. Stored closure using self → needs [weak self].

final class ProductManager {
    var productID = 101
    lazy var productURL = "https://example.com/product/\(productID)"
    lazy var makeTitle: () -> String = { [weak self] in
        guard let self else { return "" }
        return "Product \(self.productID)"
    }

    deinit {
        print("ProductManager deinit")
    }
}

print("\n========== 04 - Lazy and Retain Cycles ==========")
var productManager: ProductManager? = ProductManager()
print(productManager?.makeTitle() as Any)   // Optional("Product 101")
productManager = nil                        // ProductManager deinit

//==============================================================
// MARK: - 5. Property Observers
//==============================================================
// willSet → newValue | didSet → oldValue
// ❌ Not called in the type's own init
// ✅ Called in a subclass init after super.init()
// ✅ inout → fires once, at write-back

var username = "Guest" {
    willSet { print("willSet:", newValue) }
    didSet { print("didSet:", oldValue) }
}

class BaseAccount {
    var balance: Double = 0 {
        didSet { print("didSet:", oldValue, "→", balance) }
    }
}

final class SavingsAccount: BaseAccount {
    override init() {
        super.init()
        balance = 100
    }
}

func addBonus(_ value: inout Int) {
    value += 25
    value += 25
}

var points = 0 {
    didSet { print("points:", oldValue, "→", points) }
}

print("\n========== 05 - Property Observers ==========")
username = "Anil"             // willSet: Anil | didSet: Guest
_ = SavingsAccount()          // didSet: 0.0 → 100.0
addBonus(&points)             // points: 0 → 50 — once

//==============================================================
// MARK: - 6. Overriding Properties
//==============================================================

class Vehicle {
    var speed: Double = 0
}

final class Car: Vehicle {
    override var speed: Double {
        didSet { print("Car speed:", speed) }
    }
}

print("\n========== 06 - Overriding Properties ==========")
Car().speed = 60   // Car speed: 60.0

//==============================================================
// MARK: - 7. private(set)
//==============================================================
// Public read, private write — standard ViewModel pattern.

final class ProductViewModel {
    private(set) var products: [String] = []

    func loadProducts() {
        products = ["Shoes", "Socks"]
    }
}

print("\n========== 07 - private(set) ==========")
let viewModel = ProductViewModel()
viewModel.loadProducts()
print(viewModel.products.count)   // 2
// viewModel.products = []        ❌ Setter inaccessible

//==============================================================
// MARK: - 8. static vs class
//==============================================================
// static let → lazy + thread-safe → singleton
// static     → stored or computed, not overridable, shared by subclasses
// class      → computed only, overridable

final class NetworkManager {
    static let shared = NetworkManager()
    private init() { print("NetworkManager created") }
}

class Parent {
    static var counter = 10
    class var screenName: String { "Parent" }
}

class Child: Parent {
    override class var screenName: String { "Child" }
}

print("\n========== 08 - static vs class ==========")
_ = NetworkManager.shared   // NetworkManager created
_ = NetworkManager.shared   // Same instance
Child.counter = 99
print(Parent.counter)       // 99 — shared storage
print(Child.screenName)     // Child

//==============================================================
// MARK: - 9. Extensions
//==============================================================
// ✅ Computed, static stored  ❌ Instance stored, lazy (changes memory layout)

extension Temperature {
    var kelvin: Double { celsius + 273.15 }
    // var label = "Temp"   ❌
}

print("\n========== 09 - Extensions ==========")
print(temperature.kelvin)   // 303.15

//==============================================================
// MARK: - 10. Key Paths
//==============================================================
// Reference to a property itself. Used in SwiftUI (id: \.id), KVO, Combine.

struct Customer {
    var name: String
    var age: Int
}

print("\n========== 10 - Key Paths ==========")
let customers = [Customer(name: "Ravi", age: 30), Customer(name: "Anil", age: 25)]
print(customers.map(\.name))                             // ["Ravi", "Anil"]
print(customers[0][keyPath: \Customer.age])              // 30
var firstCustomer = customers[0]
firstCustomer[keyPath: \.name] = "Ravi Kumar"            // WritableKeyPath
print(firstCustomer.name)                                // Ravi Kumar

//==============================================================
// MARK: - Interview Questions
//==============================================================
// 1. Stored vs computed vs lazy?
// 2. Why must lazy be var? Is it thread-safe?
// 3. Does a lazy initializer using self cause a retain cycle?
// 4. Do observers fire in init? In a subclass init? With inout?
// 5. Can computed or lazy properties have observers?
// 6. Why use private(set) in a ViewModel?
// 7. static vs class? Why is static let safe for singletons?
// 8. Why can't extensions add stored properties?
// 9. What is a key path, and where is it used in iOS?
//==============================================================
