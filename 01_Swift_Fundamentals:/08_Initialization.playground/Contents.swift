import UIKit

//==============================================================
// MARK: - 08. Initialization
//==============================================================
//
// Delegation rules:
// Designated  → delegates UP      (super.init)
// Convenience → delegates ACROSS  (self.init)
// Every convenience init must end in a designated init.
//==============================================================

//==============================================================
// MARK: - 01. Designated Initializer
//==============================================================
// Primary initializer. Must initialize every property the class introduces.

class Person {
    let name: String

    init(name: String) {
        self.name = name
    }
}

print("\n========== 01 - Designated Initializer ==========")
let person = Person(name: "Anil")
print(person.name) // Anil

//==============================================================
// MARK: - 02. Convenience Initializer
//==============================================================
// Alternative init. Must call self.init(...) of the same class.

class Developer {
    let name: String
    let experience: Int

    init(name: String, experience: Int) {
        self.name = name
        self.experience = experience
    }

    convenience init(name: String) {
        self.init(name: name, experience: 8)
    }
}

print("\n========== 02 - Convenience Initializer ==========")
let developer = Developer(name: "Anil")
print(developer.name, developer.experience) // Anil 8

//==============================================================
// MARK: - 03. Initializer Delegation (Struct)
//==============================================================
// Structs have no convenience keyword — just self.init(...).

struct Address {
    let city: String
    let country: String

    init(city: String, country: String) {
        self.city = city
        self.country = country
    }

    init(city: String) {
        self.init(city: city, country: "India")
    }
}

print("\n========== 03 - Initializer Delegation ==========")
let address = Address(city: "Tirupati")
print(address.city, address.country) // Tirupati India

//==============================================================
// MARK: - 04. Failable Initializer
//==============================================================
// init? returns nil for invalid input.

struct UserID {
    let value: String

    init?(value: String) {
        guard !value.isEmpty else { return nil }
        self.value = value
    }
}

print("\n========== 04 - Failable Initializer ==========")
print(UserID(value: "123")?.value as Any) // Optional("123")
print(UserID(value: "") as Any)           // nil

//==============================================================
// MARK: - 05. Required Initializer
//==============================================================
// Every subclass must implement it. Subclass writes `required`, not `override`.

class Employee {
    let name: String

    required init(name: String) {
        self.name = name
    }
}

class IOSDeveloper: Employee {
    required init(name: String) {
        super.init(name: name)
    }
}

// Real-world: UIView / UIViewController declare required init?(coder:)
// Any custom init in a subclass forces you to add it.
final class ProductCardView: UIView {
    let title: String

    init(title: String) {
        self.title = title
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

print("\n========== 05 - Required Initializer ==========")
print(IOSDeveloper(name: "Anil").name)        // Anil
print(ProductCardView(title: "Shoes").title)  // Shoes

//==============================================================
// MARK: - 06. Two-Phase Initialization
//==============================================================
// Phase 1: every stored property gets a value (subclass first, then super.init).
// Phase 2: self is fully ready — call methods, use self.

class Animal {
    let name: String

    init(name: String) {
        self.name = name
    }
}

class Dog: Animal {
    let breed: String

    init(name: String, breed: String) {
        self.breed = breed          // Phase 1 — own properties
        // print(self.name)         ❌ self used before super.init
        super.init(name: name)      // Phase 1 — parent properties
        print("Phase 2:", describe())   // ✅ self is ready
    }

    func describe() -> String {
        "\(name) the \(breed)"
    }
}

print("\n========== 06 - Two-Phase Initialization ==========")
let dog = Dog(name: "Rocky", breed: "Labrador") // Phase 2: Rocky the Labrador

//==============================================================
// MARK: - 07. Struct vs Class Initialization
//==============================================================
// Struct → free memberwise init. Class → no memberwise init.
// Trap: a custom init INSIDE a struct removes the memberwise init.
// Fix: put the custom init in an extension to keep both.

struct User {
    let name: String
    let age: Int
}

extension User {
    init(name: String) {
        self.init(name: name, age: 0)
    }
}

class Profile {
    let name: String

    init(name: String) {
        self.name = name
    }
}

print("\n========== 07 - Struct vs Class Initialization ==========")
print(User(name: "Anil", age: 30).name) // Anil — memberwise still available
print(User(name: "Ravi").age)           // 0 — custom init from extension
print(Profile(name: "Anil").name)       // Anil — explicit init required

//==============================================================
// MARK: - 08. Initializer Inheritance
//==============================================================
// A subclass inherits all parent designated inits automatically
// if it defines no designated init of its own
// (possible when its new properties all have default values).

class Cat: Animal {
    var isIndoor = true
}

print("\n========== 08 - Initializer Inheritance ==========")
print(Cat(name: "Kitty").name) // Kitty — init(name:) inherited

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Designated vs convenience initializer?
// 2. What are the delegation rules (up vs across)?
// 3. What is two-phase initialization, and why does Swift use it?
// 4. Why can't you use self before super.init?
// 5. When do you use a failable initializer?
// 6. What does required mean? Why must UIView subclasses add init?(coder:)?
// 7. When does a struct lose its memberwise initializer? How do you keep it?
// 8. When does a subclass inherit its parent's initializers?
//
//==============================================================
