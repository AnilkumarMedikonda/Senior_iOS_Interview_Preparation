import Foundation

//==============================================================
// MARK: - 04. Optionals
//==============================================================
// enum Optional<Wrapped> { case none; case some(Wrapped) }

//==============================================================
// MARK: - 1. Basic Optional
//==============================================================

print("\n========== 01 - Basic Optional ==========")
var name: String? = "Anil"
print(name as Any)   // Optional("Anil")
name = .none
print(name as Any)   // nil
// let plain: String = nil   ❌ nil only valid for Optionals

//==============================================================
// MARK: - 2. if let vs guard let
//==============================================================

func greet(_ name: String?) {
    guard let name else { return print("Name missing") }
    print("Hello", name)   // name stays in scope after guard
}

print("\n========== 02 - if let vs guard let ==========")
let age: Int? = 25
if let age, age >= 18 {
    print("Adult")         // Scoped to braces
}
greet("Anil")              // Hello Anil
greet(nil)                 // Name missing

//==============================================================
// MARK: - 3. Optional Chaining
//==============================================================
// Result is always Optional. Assignment through a chain returns Void?.

final class Address {
    var city: String
    init(city: String) { self.city = city }
}

final class Profile {
    var address: Address?
    init(address: Address?) { self.address = address }
}

print("\n========== 03 - Optional Chaining ==========")
let profile: Profile? = Profile(address: Address(city: "Bangalore"))
print(profile?.address?.city as Any)             // Optional("Bangalore")
print(type(of: profile?.address?.city.count))    // Optional<Int>
if (profile?.address?.city = "Hyderabad") != nil {
    print("Updated")                             // Updated
}

//==============================================================
// MARK: - 4. Nil-Coalescing
//==============================================================
// Right side is an @autoclosure — evaluated only if left is nil.

func loadDefault() -> String {
    print("loadDefault called")
    return "Guest"
}

print("\n========== 04 - Nil-Coalescing ==========")
let cached: String? = "Anil"
print(cached ?? loadDefault())          // Anil — loader NOT called
let missing: String? = nil
print(missing ?? loadDefault())         // loadDefault called → Guest
print(missing ?? cached ?? "Guest")     // Anil — chaining

//==============================================================
// MARK: - 5. Force Unwrap and IUO
//==============================================================
// ! crashes on nil. String! is an Optional, force-unwrapped only when
// the context needs a String (Swift 4.2+).

print("\n========== 05 - Force Unwrap and IUO ==========")
let forceName: String? = "Anil"
print(forceName!)                  // Anil
var title: String! = "iOS"
print(title as Any)                // Optional("iOS") — stays Optional
let unwrapped: String = title      // Force-unwrapped here
print(unwrapped)                   // iOS
// Legit IUO: @IBOutlet weak var label: UILabel!

//==============================================================
// MARK: - 6. map, flatMap, compactMap
//==============================================================

print("\n========== 06 - map, flatMap, compactMap ==========")
let text: String? = "123"
print(text.map { Int($0) } as Any)       // Optional(Optional(123)) — Int??
print(text.flatMap { Int($0) } as Any)   // Optional(123) — Int?
let items: [String?] = ["Shoes", nil, "Cap"]
print(items.compactMap { $0 })           // ["Shoes", "Cap"]

//==============================================================
// MARK: - 7. Pattern Matching
//==============================================================

print("\n========== 07 - Pattern Matching ==========")
let scores: [Int?] = [90, nil, 75]
for case let score? in scores {
    print(score)   // 90, 75
}

//==============================================================
// MARK: - 8. Nested Optional
//==============================================================
// [K: V?] lookup returns V?? → "key missing" vs "value is nil".

let middleNames: [String: String?] = ["Anil": nil, "Ravi": "Kumar"]

func describe(_ person: String) {
    switch middleNames[person] {
    case .none: print(person, "→ key missing")
    case .some(.none): print(person, "→ value is nil")
    case .some(.some(let middle)): print(person, "→", middle)
    }
}

print("\n========== 08 - Nested Optional ==========")
describe("Ravi")   // Ravi → Kumar
describe("Anil")   // Anil → value is nil
describe("Sam")    // Sam → key missing

//==============================================================
// MARK: - 9. try?
//==============================================================
// Error → nil. Swift 5 flattens: try? on a func returning Int? gives Int?.

enum AppError: Error {
    case failed
}

func parseAge(_ text: String) throws -> Int? {
    if text.isEmpty { throw AppError.failed }
    return Int(text)
}

print("\n========== 09 - try? ==========")
print((try? parseAge("")) as Any)        // nil
print(type(of: try? parseAge("30")))     // Optional<Int>, not Int??

//==============================================================
// MARK: - 10. weak Must Be Optional
//==============================================================
// ARC sets weak references to nil on dealloc.

protocol ProfileDelegate: AnyObject {}
final class Screen: ProfileDelegate {}
final class ViewModel {
    weak var delegate: ProfileDelegate?   // non-optional ❌
}

print("\n========== 10 - weak Must Be Optional ==========")
var screen: Screen? = Screen()
let viewModel = ViewModel()
viewModel.delegate = screen
screen = nil
print(viewModel.delegate == nil)   // true

//==============================================================
// MARK: - 11. Memory Layout
//==============================================================

print("\n========== 11 - Memory Layout ==========")
print(MemoryLayout<Int>.size, MemoryLayout<Int?>.size)              // 8 9
print(MemoryLayout<Address>.size, MemoryLayout<Address?>.size)      // 8 8 — nil is the null pointer

//==============================================================
// MARK: - 12. Codable and Optionals
//==============================================================
// Optional property: missing key or null → nil. Wrong type still fails.

struct Product: Codable {
    let id: Int
    let price: Double?
}

print("\n========== 12 - Codable and Optionals ==========")
let json = Data(#"[{"id": 1, "price": 9.99}, {"id": 2}, {"id": 3, "price": null}]"#.utf8)
do {
    let products = try JSONDecoder().decode([Product].self, from: json)
    for product in products {
        print(product.id, product.price as Any)   // 1 Optional(9.99) | 2 nil | 3 nil
    }
} catch {
    print(error)
}

//==============================================================
// MARK: - Interview Questions
//==============================================================
// 1. How is Optional implemented?
// 2. if let vs guard let?
// 3. Why does optional chaining return an Optional?
// 4. Is the right side of ?? always evaluated?
// 5. When is force unwrapping acceptable?
// 6. How do IUOs behave since Swift 4.2?
// 7. map vs flatMap vs compactMap?
// 8. When do you get T??, and why does it matter?
// 9. How does try? behave on a func returning an Optional?
// 10. Why must weak be Optional?
// 11. Memory cost of Int? vs SomeClass??
// 12. How do Optional properties affect Codable?
// 13. When should a model property be Optional?
//==============================================================
