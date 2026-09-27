import Foundation

//==============================================================
// MARK: - Generics
//==============================================================
// Write code once, use it with any type — and keep full type safety.
// The compiler specializes generic code per type → no runtime cost.

//==============================================================
// MARK: - 01. Generic Function
//==============================================================

func swapValues<T>(_ a: inout T, _ b: inout T) {
    let temp = a
    a = b
    b = temp
}

print("\n========== 01 - Generic Function ==========")
var first = 1
var second = 2
swapValues(&first, &second)
print(first, second) // 2 1
var left = "A"
var right = "B"
swapValues(&left, &right)
print(left, right)   // B A
// swapValues(&first, &left)   ❌ T must be the same type

//==============================================================
// MARK: - 02. Generic Type
//==============================================================

struct Stack<Element> {
    private var items: [Element] = []

    mutating func push(_ item: Element) {
        items.append(item)
    }

    mutating func pop() -> Element? {
        items.popLast()
    }

    func peek() -> Element? {
        items.last
    }
}

print("\n========== 02 - Generic Type ==========")

var stack = Stack<Int>()
stack.push(10)
stack.push(20)
print(stack.peek() as Any) // Optional(20)
print(stack.pop() as Any)  // Optional(20)
print(stack.pop() as Any)  // Optional(10)

//==============================================================
// MARK: - 03. Constraints
//==============================================================
// T: Protocol → only types that conform. where → same thing, more room.

func findMax<T: Comparable>(_ values: [T]) -> T? {
    values.max()
}

func areEqual<T>(_ a: T, _ b: T) -> Bool where T: Equatable {
    a == b
}

print("\n========== 03 - Constraints ==========")
print(findMax([10, 20, 5]) as Any)   // Optional(20)
print(findMax(["A", "C"]) as Any)    // Optional("C")
print(areEqual("Swift", "iOS"))      // false

//==============================================================
// MARK: - 04. Constrained Extension
//==============================================================

extension Array where Element: Hashable {
    func containsDuplicates() -> Bool {
        Set(self).count != count
    }
}

print("\n========== 04 - Constrained Extension ==========")
print([1, 2, 3, 2].containsDuplicates()) // true
print(["A", "B"].containsDuplicates())   // false

//==============================================================
// MARK: - 05. Same-Type Constraint
//==============================================================
// Two different generic types whose elements must match.

func merge<S: Sequence, T: Sequence>(_ a: S, _ b: T) -> [S.Element] where S.Element == T.Element {
    Array(a) + Array(b)
}

print("\n========== 05 - Same-Type Constraint ==========")
print(merge([1, 2], Set([3]))) // [1, 2, 3]
// merge([1], ["A"])            ❌ Int ≠ String

//==============================================================
// MARK: - 06. Generics + Protocols (DI)
//==============================================================

protocol APIClient {
    func fetch()
}

struct ProductionAPI: APIClient {
    func fetch() { print("Production API") }
}

struct MockAPI: APIClient {
    func fetch() { print("Mock API") }
}

final class ViewModel<Client: APIClient> {
    private let client: Client

    init(client: Client) {
        self.client = client
    }

    func load() {
        client.fetch()
    }
}

print("\n========== 06 - Generics + Protocols ==========")
ViewModel(client: ProductionAPI()).load() // Production API
ViewModel(client: MockAPI()).load()       // Mock API

//==============================================================
// MARK: - 07. Generic Decoding
//==============================================================
// One function decodes any Decodable model — the classic iOS use.

struct Product: Decodable {
    let id: Int
    let name: String
}

func decode<T: Decodable>(_ type: T.Type, from data: Data) -> T? {
    do {
        return try JSONDecoder().decode(type, from: data)
    } catch {
        print("Decoding failed:", error)
        return nil
    }
}

print("\n========== 07 - Generic Decoding ==========")
let json = Data(#"[{"id": 1, "name": "Shoes"}]"#.utf8)
if let products = decode([Product].self, from: json) {
    print(products[0].name) // Shoes
}

//==============================================================
// MARK: - 08. Generics vs Any
//==============================================================
// Generic keeps the type. Any loses it → needs a cast.

func identity<T>(_ value: T) -> T {
    value
}

func identityAny(_ value: Any) -> Any {
    value
}

print("\n========== 08 - Generics vs Any ==========")
let genericResult = identity(10)
print(genericResult + 1)            // 11 — still an Int
let anyResult = identityAny(10)
// print(anyResult + 1)             ❌ Any has no +
if let number = anyResult as? Int {
    print(number + 1)               // 11 — only after casting
}

//==============================================================
// MARK: - 09. Generics vs any Protocol
//==============================================================
// Generic → concrete type known at compile time → specialized, static dispatch.
// any     → existential box → dynamic dispatch, possible heap allocation.
// Use any only when you need mixed types together, e.g. [any APIClient].

func processGeneric<T: APIClient>(_ client: T) {
    client.fetch()
}

func processExistential(_ client: any APIClient) {
    client.fetch()
}

print("\n========== 09 - Generics vs any Protocol ==========")
processGeneric(ProductionAPI())     // Production API
processExistential(MockAPI())       // Mock API
let clients: [any APIClient] = [ProductionAPI(), MockAPI()] // only any allows mixing
print(clients.count)                // 2

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Why use generics instead of Any?
// 2. What does T: Comparable mean? When do you need where?
// 3. What is a same-type constraint?
// 4. Why does containsDuplicates need Hashable, not Equatable?
// 5. How would you write a generic decode / network call?
// 6. Generics vs any Protocol — performance and flexibility?
// 7. What is specialization?
//
//==============================================================
