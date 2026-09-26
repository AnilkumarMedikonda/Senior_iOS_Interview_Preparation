import Foundation

//==============================================================
// MARK: - 02. Value vs Reference Types
//==============================================================
// Value → struct, enum, tuple | Reference → class, closure

//==============================================================
// MARK: - 1. Copy vs Shared Reference
//==============================================================

struct PersonStruct {
    var age: Int
}

final class PersonClass {
    var age: Int
    init(age: Int) { self.age = age }
}

print("\n========== 01 - Copy vs Shared Reference ==========")
let person1 = PersonStruct(age: 20)
var person2 = person1
person2.age = 40
print(person1.age, person2.age)             // 20 40 — independent

let classPerson1 = PersonClass(age: 20)
let classPerson2 = classPerson1
classPerson2.age = 40
print(classPerson1.age, classPerson2.age)   // 40 40 — same object

//==============================================================
// MARK: - 2. let Behavior
//==============================================================
// struct + let → whole value frozen
// class + let → reference frozen, object still mutable
// let property → set once in init

print("\n========== 02 - let Behavior ==========")
let fixedStruct = PersonStruct(age: 20)
// fixedStruct.age = 30        ❌
let fixedClass = PersonClass(age: 20)
fixedClass.age = 30            // ✅ object mutates
// fixedClass = PersonClass(age: 50)   ❌ reference cannot change
print(fixedClass.age)          // 30

//==============================================================
// MARK: - 3. mutating
//==============================================================
// Struct methods need mutating to change self. Not callable on a let.

struct Counter {
    var count = 0
    mutating func increment() { count += 1 }
}

print("\n========== 03 - mutating ==========")
var counter = Counter()
counter.increment()
print(counter.count)   // 1
// let fixedCounter = Counter(); fixedCounter.increment()   ❌

//==============================================================
// MARK: - 4. Equality vs Identity
//==============================================================
// == → same value (synthesized for structs, manual for classes)
// === → same instance (classes only)

final class User: Equatable {
    let id: Int
    init(id: Int) { self.id = id }
    static func == (lhs: User, rhs: User) -> Bool { lhs.id == rhs.id }
}

print("\n========== 04 - Equality vs Identity ==========")
let user1 = User(id: 1)
let user2 = User(id: 1)
print(user1 == user2)    // true
print(user1 === user2)   // false
print(user1 === user1)   // true

//==============================================================
// MARK: - 5. Struct Containing a Class
//==============================================================
// Trap: a struct has value semantics only if everything inside it does.

final class Address {
    var city: String
    init(city: String) { self.city = city }
}

struct Employee {
    var address: Address
}

print("\n========== 05 - Struct Containing a Class ==========")
let employee1 = Employee(address: Address(city: "Bangalore"))
let employee2 = employee1
employee2.address.city = "Hyderabad"   // Compiles even on let
print(employee1.address.city)          // Hyderabad — shared object
// Fix: make Address a struct, or implement copy-on-write.

//==============================================================
// MARK: - 6. Copy-on-Write
//==============================================================
// Collections share storage until the first write.
// Custom CoW: class storage + isKnownUniquelyReferenced before mutating.

final class ImageStorage {
    var pixels: [Int]
    init(pixels: [Int]) { self.pixels = pixels }
}

struct Image {
    private var storage: ImageStorage
    init(pixels: [Int]) { storage = ImageStorage(pixels: pixels) }
    var pixels: [Int] { storage.pixels }

    mutating func setPixel(_ value: Int, at index: Int) {
        if !isKnownUniquelyReferenced(&storage) {
            print("Copying storage")
            storage = ImageStorage(pixels: storage.pixels)
        }
        storage.pixels[index] = value
    }
}

print("\n========== 06 - Copy-on-Write ==========")
let image1 = Image(pixels: [0, 0, 0])
var image2 = image1
image2.setPixel(9, at: 0)          // Copying storage
image2.setPixel(7, at: 1)          // No copy — now unique
print(image1.pixels, image2.pixels)   // [0, 0, 0] [9, 7, 0]

//==============================================================
// MARK: - 7. Passing to Functions
//==============================================================
// struct → copy | struct + inout → caller changes | class → same object

func updateStruct(_ person: inout PersonStruct) { person.age = 100 }
func updateClass(_ person: PersonClass) { person.age = 100 }

print("\n========== 07 - Passing to Functions ==========")
var inoutPerson = PersonStruct(age: 20)
updateStruct(&inoutPerson)
print(inoutPerson.age)       // 100
let sharedPerson = PersonClass(age: 20)
updateClass(sharedPerson)
print(sharedPerson.age)      // 100

//==============================================================
// MARK: - 8. Struct or Class
//==============================================================
//
// Default to STRUCT: models, DTOs, view state, configs.
// Thread-safe to pass around — each owner gets its own copy.
//
// Use CLASS when you need:
// identity / shared mutable state (cache, session, store)
// inheritance (UIViewController)
// deinit (cleanup)
// weak references (delegates)
// Objective-C interop (NSObject, KVO)
// ObservableObject ViewModels
//
// Myth: "structs live on the stack, classes on the heap".
// The real difference is semantics; storage depends on the compiler.
//
// Structs don't create retain cycles, but closures or classes inside them can.
//
//==============================================================

//==============================================================
// MARK: - Interview Questions
//==============================================================
// 1. Value vs reference semantics?
// 2. let on a struct vs let on a class?
// 3. Why does a struct method need mutating?
// 4. == vs ===?
// 5. Can a let struct still change? (struct holding a class)
// 6. What is copy-on-write? How do you implement it?
// 7. When would you choose a class over a struct?
// 8. Are structs always on the stack?
// 9. Can structs cause retain cycles?
//==============================================================
