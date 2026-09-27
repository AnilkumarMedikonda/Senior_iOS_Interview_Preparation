import Foundation

//==============================================================
// MARK: - Any vs some vs any
//==============================================================
// Any      → any type at all, type info lost, needs casting
// any P    → existential: any conforming type, decided at runtime
// some P   → opaque: ONE hidden concrete type, fixed at compile time

protocol Vehicle {
    func start()
}

struct Car: Vehicle {
    func start() { print("Car Started") }
}

struct Bike: Vehicle {
    func start() { print("Bike Started") }
}

//==============================================================
// MARK: - 01. Any and AnyObject
//==============================================================
// Any → any value. AnyObject → class instances only.

print("\n========== 01 - Any and AnyObject ==========")
let things: [Any] = [1, "Swift", Car()]
for thing in things {
    if let number = thing as? Int {
        print("Int:", number)             // Int: 1
    } else if let text = thing as? String {
        print("String:", text)            // String: Swift
    } else {
        print("Other:", type(of: thing))  // Other: Car
    }
}

final class Session {}
let object: AnyObject = Session()
// let invalid: AnyObject = Car()   ❌ Car is a struct

//==============================================================
// MARK: - 02. any Protocol (Existential)
//==============================================================
// Holds different conforming types — decided at runtime.

func makeAnyVehicle(_ useBike: Bool) -> any Vehicle {
    useBike ? Bike() : Car()
}

print("\n========== 02 - any Protocol ==========")
let vehicles: [any Vehicle] = [Car(), Bike()]
for vehicle in vehicles {
    vehicle.start() // Car Started | Bike Started
}
makeAnyVehicle(true).start() // Bike Started

//==============================================================
// MARK: - 03. some Protocol (Opaque)
//==============================================================
// One concrete type, hidden from the caller but known to the compiler.

func makeCar() -> some Vehicle {
    Car()
}

// func makeVehicle(_ useBike: Bool) -> some Vehicle {
//     useBike ? Bike() : Car()
// }
// ❌ Car and Bike are different concrete types

print("\n========== 03 - some Protocol ==========")
makeCar().start() // Car Started

//==============================================================
// MARK: - 04. some in Parameters = Generics
//==============================================================
// func run(_ v: some Vehicle) is shorthand for func run<T: Vehicle>(_ v: T)

func run(_ vehicle: some Vehicle) {
    vehicle.start()
}

func runGeneric<T: Vehicle>(_ vehicle: T) {
    vehicle.start()
}

print("\n========== 04 - some in Parameters ==========")
run(Bike())        // Bike Started
runGeneric(Bike()) // Bike Started

//==============================================================
// MARK: - 05. Associated Types and Existentials
//==============================================================
// any Storage → Item unknown → can't call save ❌
// Primary associated type Storage<Item> → any Storage<String> works (Swift 5.7)

protocol Storage<Item> {
    associatedtype Item
    func save(_ item: Item)
}

struct StringStorage: Storage {
    func save(_ item: String) { print("Saved:", item) }
}

struct IntStorage: Storage {
    func save(_ item: Int) { print("Saved:", item) }
}

print("\n========== 05 - Associated Types and Existentials ==========")
let unknownStorage: any Storage = StringStorage()
// unknownStorage.save("Swift")   ❌ Item type is unknown
print(type(of: unknownStorage))    // StringStorage

let stringStorage: any Storage<String> = StringStorage()
stringStorage.save("Swift")        // Saved: Swift

//==============================================================
// MARK: - 06. Protocol Composition
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

func makeDuck() -> some Flyable & Swimmable {
    Duck()
}

print("\n========== 06 - Protocol Composition ==========")
let anyDuck: any Flyable & Swimmable = Duck()
anyDuck.fly()     // Flying
makeDuck().swim() // Swimming

//==============================================================
// MARK: - 07. Type Erasure
//==============================================================
// Wrap any conforming type behind one concrete generic type.
// Same idea as AnyPublisher, AnyView, AnyHashable.

struct AnyStorage<Item>: Storage {
    private let saveHandler: (Item) -> Void

    init<S: Storage>(_ storage: S) where S.Item == Item {
        saveHandler = storage.save
    }

    func save(_ item: Item) {
        saveHandler(item)
    }
}

print("\n========== 07 - Type Erasure ==========")
let erased: [AnyStorage<Int>] = [AnyStorage(IntStorage())]
for storage in erased {
    storage.save(42) // Saved: 42
}

//==============================================================
// MARK: - 08. Performance and SwiftUI
//==============================================================
//
// some → compiler knows the type → static dispatch, specialization, no boxing.
// any  → existential box → dynamic dispatch, possible heap allocation.
// Prefer some / generics by default; use any when you truly need
// different types in one place (heterogeneous arrays).
//
// SwiftUI: var body: some View
// body returns ONE deeply nested concrete type (VStack<TupleView<...>>).
// some View hides it; the compiler still knows it → fast diffing.
//
//==============================================================

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Any vs AnyObject?
// 2. any P vs some P?
// 3. Why can't a some function return two different types?
// 4. Why does SwiftUI use some View?
// 5. What does some mean in a parameter position?
// 6. Why can't you call save() on any Storage? How do primary associated types fix it?
// 7. What is type erasure? Give iOS examples.
// 8. Performance difference between some and any?
//
//==============================================================
