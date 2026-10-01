import Foundation

// ============================================================
// MARK: - 01_SWIFT_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Each question:
 1. Question + short spoken answer
 2. Follow-up the interviewer usually asks
 3. A tiny code proof with DEBUG output

 Answer out loud BEFORE reading.
*/


// ============================================================
// MARK: - Q01. Struct vs Class
// ============================================================

/*
 Q: Struct vs class — when do you use each?

 Answer:
 Struct = value type, copied, no shared state.
 Class  = reference type, shared identity, inheritance, deinit.
 Default to struct; class for shared mutable state / identity.

 Follow-up: struct containing a class?
 → The REFERENCE is copied — both copies share the object.
*/

struct PointStruct { var x = 0 }

final class PointClass { var x = 0 }

var structA = PointStruct()

var structB = structA

structB.x = 10

let classA = PointClass()

let classB = classA

classB.x = 10

print("DEBUG Q01 - struct A.x:", structA.x, "| class A.x:", classA.x)     // 0 | 10


// ============================================================
// MARK: - Q02. Copy-on-Write
// ============================================================

/*
 Q: What is Copy-on-Write?

 Answer:
 Arrays/Dictionaries/Strings share storage when copied and
 only really copy when one is mutated.

 Follow-up: own structs?
 → Not automatic — use isKnownUniquelyReferenced.
*/

var original = [1, 2, 3]

var copy = original                          // shares storage

copy.append(4)                               // real copy happens now

print("DEBUG Q02 - original:", original, "| copy:", copy)                // [1,2,3] | [1,2,3,4]


// ============================================================
// MARK: - Q03. let with Class vs Struct
// ============================================================

/*
 Q: let vs var for a class instance?

 Answer:
 let fixes the REFERENCE — class properties can still change.
 A let struct is fully immutable.
*/

let fixedClass = PointClass()

fixedClass.x = 5                             // ✅ allowed

let fixedStruct = PointStruct()

// fixedStruct.x = 5                         ❌ Cannot assign: 'fixedStruct' is a 'let' constant

print("DEBUG Q03 - let class changed x:", fixedClass.x)                  // 5


// ============================================================
// MARK: - Q04. Safe Unwrapping
// ============================================================

/*
 Q: How do you unwrap optionals safely?

 Answer:
 if let / guard let, optional chaining, ?? for defaults.
 guard let for early exit.

 Follow-up: force unwrap?
 → Only when nil is a true programmer error.
*/

func greeting(for name: String?) -> String {
    guard let name else {
        return "Hello, Guest"
    }
    return "Hello, \(name)"
}

print("DEBUG Q04 -", greeting(for: nil), "|", greeting(for: "Anil"))


// ============================================================
// MARK: - Q05. Optional Under the Hood
// ============================================================

/*
 Q: What is an optional?

 Answer:
 enum Optional<Wrapped> { case none, case some(Wrapped) }

 Follow-up: optional chaining returns?
 → Always an optional.
*/

let maybeCount: Int? = .some(3)

switch maybeCount {
case .some(let value):
    print("DEBUG Q05 - .some:", value)
case .none:
    print("DEBUG Q05 - .none")
}


// ============================================================
// MARK: - Q06. Enums with Associated Values
// ============================================================

/*
 Q: Why are associated values useful?

 Answer:
 Model states that carry different data; switch is
 exhaustive, so every state must be handled.

 Follow-up: @unknown default?
 → Future cases of enums you don't own.
*/

enum ScreenState {
    case loading
    case loaded([String])
    case failed(String)
}

func describe(_ state: ScreenState) -> String {
    switch state {
    case .loading:
        return "Spinner"
    case .loaded(let items):
        return "\(items.count) items"
    case .failed(let message):
        return "Error: \(message)"
    }
}

print("DEBUG Q06 -", describe(.loaded(["Shoes", "Cap"])))                // 2 items


// ============================================================
// MARK: - Q07. Stored vs Computed vs Lazy
// ============================================================

/*
 Q: Stored vs computed vs lazy?

 Answer:
 Stored keeps a value, computed calculates every time,
 lazy calculates once on first access.

 Follow-up: lazy thread-safe?
 → No.
*/

final class Profile {

    var firstName = "Anil"                                   // stored

    var greeting: String { "Hi \(firstName)" }               // computed

    lazy var expensiveReport: String = {                     // lazy
        print("DEBUG Q07 - lazy created now")
        return "Report"
    }()
}

let profile = Profile()

print("DEBUG Q07 - before lazy access")

_ = profile.expensiveReport


// ============================================================
// MARK: - Q08. Designated vs Convenience Init
// ============================================================

/*
 Q: Designated vs convenience initializers?

 Answer:
 Designated fully initializes and calls super.
 Convenience must call another init in the same class.

 Follow-up: two-phase init?
 → Phase 1 sets all properties, phase 2 can use self.
*/

final class Product {

    let name: String
    let price: Double

    init(name: String, price: Double) {                      // designated
        self.name = name
        self.price = price
    }

    convenience init(freeItem name: String) {                // convenience
        self.init(name: name, price: 0)
    }
}

print("DEBUG Q08 - free item price:", Product(freeItem: "Sticker").price)   // 0.0


// ============================================================
// MARK: - Q09. Escaping vs Non-Escaping
// ============================================================

/*
 Q: Escaping vs non-escaping closures?

 Answer:
 Non-escaping runs before the function returns (default).
 Escaping is stored / called later → @escaping, can create
 retain cycles.
*/

var storedHandlers: [() -> Void] = []

func runNow(_ work: () -> Void) {
    work()                                                   // non-escaping
}

func runLater(_ work: @escaping () -> Void) {
    storedHandlers.append(work)                              // escapes
}

runNow { print("DEBUG Q09 - ran immediately") }

runLater { print("DEBUG Q09 - ran later") }

storedHandlers.forEach { $0() }


// ============================================================
// MARK: - Q10. Capture Lists
// ============================================================

/*
 Q: What is a capture list?

 Answer:
 Controls how a closure captures: [weak self], [unowned self],
 or copying a value at creation time.

 Follow-up: weak vs unowned?
 → weak becomes nil (optional); unowned crashes if freed.
*/

var counter = 1

let capturedValue = { [counter] in print("DEBUG Q10 - captured copy:", counter) }

let capturedReference = { print("DEBUG Q10 - live variable:", counter) }

counter = 99

capturedValue()                                              // 1

capturedReference()                                          // 99


// ============================================================
// MARK: - Q11. @autoclosure
// ============================================================

/*
 Q: What is @autoclosure?

 Answer:
 Wraps an argument in a closure so it's evaluated only if
 needed — used by assert and ??.
*/

func logIfDebug(_ message: @autoclosure () -> String, enabled: Bool) {
    if enabled {
        print("DEBUG Q11 -", message())
    }
}

func expensiveMessage() -> String {
    print("DEBUG Q11 - expensive message built")
    return "Details"
}

logIfDebug(expensiveMessage(), enabled: false)               // nothing built

logIfDebug(expensiveMessage(), enabled: true)                // built only now


// ============================================================
// MARK: - Q12. Protocol-Oriented Programming + Dispatch Trap
// ============================================================

/*
 Q: What is POP?

 Answer:
 Protocols + extensions instead of inheritance; works for
 structs and enums.

 Follow-up: the catch?
 → Extension-only methods use static dispatch — no override.
*/

protocol Greeter {
    func hello() -> String                                   // requirement → dynamic
}

extension Greeter {
    func hello() -> String { "Hello from protocol" }
    func bye() -> String { "Bye from protocol" }             // extension only → static
}

struct FriendlyGreeter: Greeter {
    func hello() -> String { "Hello from struct" }
    func bye() -> String { "Bye from struct" }
}

let greeter: Greeter = FriendlyGreeter()

print("DEBUG Q12 -", greeter.hello(), "|", greeter.bye())   // struct | protocol (!)


// ============================================================
// MARK: - Q13. any vs some
// ============================================================

/*
 Q: any vs some?

 Answer:
 some = one concrete type known to the compiler (fast).
 any  = box holding any conforming type at runtime.
*/

protocol Shape {
    var area: Double { get }
}

struct Square: Shape { let side: Double; var area: Double { side * side } }

struct Circle: Shape { let radius: Double; var area: Double { 3.14 * radius * radius } }

func makeSquare() -> some Shape {                           // always the same type
    Square(side: 2)
}

let mixed: [any Shape] = [Square(side: 2), Circle(radius: 1)]   // different types

print("DEBUG Q13 - some:", makeSquare().area, "| any count:", mixed.count)


// ============================================================
// MARK: - Q14. Associated Types
// ============================================================

/*
 Q: What is an associated type?

 Answer:
 A placeholder type in a protocol, filled in by each
 conforming type.
*/

protocol Container {
    associatedtype Item
    mutating func add(_ item: Item)
    var count: Int { get }
}

struct StringBox: Container {
    private var items: [String] = []
    mutating func add(_ item: String) { items.append(item) }   // Item = String
    var count: Int { items.count }
}

var box = StringBox()

box.add("Shoes")

print("DEBUG Q14 - box count:", box.count)


// ============================================================
// MARK: - Q15. Generics
// ============================================================

/*
 Q: Why generics?

 Answer:
 One implementation for many types, fully type-safe,
 no casting.
*/

struct Stack<Element> {
    private var items: [Element] = []
    mutating func push(_ item: Element) { items.append(item) }
    mutating func pop() -> Element? { items.popLast() }
}

var intStack = Stack<Int>()

intStack.push(1)

intStack.push(2)

print("DEBUG Q15 - popped:", intStack.pop() as Any)          // 2


// ============================================================
// MARK: - Q16. ARC
// ============================================================

/*
 Q: How does ARC work?

 Answer:
 Strong reference count per instance; at zero the object
 is freed and deinit runs. Compile-time, not a GC.
*/

final class Session {
    deinit { print("DEBUG Q16 - Session freed (count hit 0)") }
}

var session: Session? = Session()

session = nil


// ============================================================
// MARK: - Q17. Retain Cycle + Fix
// ============================================================

/*
 Q: How do retain cycles happen?

 Answer:
 Objects / closures holding each other strongly.
 Fix: weak delegate, [weak self], weak parent.
*/

final class Screen {

    var onTap: (() -> Void)?

    func setup() {
        onTap = { [weak self] in _ = self }                  // ✅ no cycle
    }

    deinit { print("DEBUG Q17 - Screen freed ✅") }
}

var screen: Screen? = Screen()

screen?.setup()

screen = nil


// ============================================================
// MARK: - Q18. try vs try? vs try!
// ============================================================

/*
 Q: try vs try? vs try!?

 Answer:
 try propagates, try? gives nil, try! crashes on error.
*/

enum ParseError: Error { case invalid }

func parse(_ text: String) throws -> Int {
    guard let value = Int(text) else { throw ParseError.invalid }
    return value
}

print("DEBUG Q18 - try?:", (try? parse("abc")) as Any)       // nil

do {
    _ = try parse("abc")
} catch {
    print("DEBUG Q18 - try caught:", error)
}

// _ = try! parse("abc")                                    ❌ crashes


// ============================================================
// MARK: - Q19. Static vs Dynamic Dispatch
// ============================================================

/*
 Q: Static vs dynamic dispatch?

 Answer:
 Static: structs, final, private — decided at compile time.
 Dynamic: overridable class methods (vtable) and protocol
 requirements (witness table).
*/

class Animal {
    func sound() -> String { "..." }                         // dynamic (overridable)
}

final class Dog: Animal {
    override func sound() -> String { "Woof" }
}

let pet: Animal = Dog()

print("DEBUG Q19 - dynamic dispatch picks:", pet.sound())   // Woof


// ============================================================
// MARK: - Q20. open vs public
// ============================================================

/*
 Q: open vs public?

 Answer:
 Both visible outside the module; only open can be
 subclassed / overridden outside it.
 Default access = internal.
*/

print("DEBUG Q20 - open = subclass outside module, public = use only")


// ============================================================
// MARK: - Q21. Property Wrappers
// ============================================================

/*
 Q: What is a property wrapper?

 Answer:
 Reusable get/set behaviour for a property (@State,
 @Published). $ gives the projected value.
*/

@propertyWrapper
struct Clamped {
    private var value: Int
    private let range: ClosedRange<Int>

    init(wrappedValue: Int, _ range: ClosedRange<Int>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }

    var wrappedValue: Int {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
}

struct Volume {
    @Clamped(0...10) var level: Int = 5
}

var volume = Volume()

volume.level = 50

print("DEBUG Q21 - clamped level:", volume.level)           // 10


// ============================================================
// MARK: - Q22. map vs compactMap vs flatMap
// ============================================================

/*
 Q: map vs compactMap vs flatMap?

 Answer:
 map transforms, compactMap transforms + drops nils,
 flatMap transforms + flattens.
*/

let raw = ["1", "two", "3"]

print("DEBUG Q22 - map:", raw.map { Int($0) })              // [1, nil, 3]

print("DEBUG Q22 - compactMap:", raw.compactMap { Int($0) }) // [1, 3]

print("DEBUG Q22 - flatMap:", [[1, 2], [3]].flatMap { $0 })  // [1, 2, 3]


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Value types first        → struct, enum
   Safe optionals           → guard let, if let
   Memory                   → weak in escaping closures
   Abstraction              → protocols + generics
   Performance              → final / static dispatch, CoW


 Senior One-Liner:

 "I default to value types and protocols, handle optionals
  safely, use generics for reusable type-safe code, and watch
  memory with weak references in escaping closures."
*/
