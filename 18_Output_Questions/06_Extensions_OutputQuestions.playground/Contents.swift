import Foundation


// MARK: - Q01. Computed Property on Int

print("\n========== Q01 - Computed Property on Int ==========")

extension Int {
    var q1IsEven: Bool { self % 2 == 0 }
    var q1Squared: Int { self * self }
}

// ▶️ Run
print(4.q1IsEven, 7.q1IsEven)

print(5.q1Squared)


// MARK: - Q02. Method on String

print("\n========== Q02 - Method on String ==========")

extension String {
    func q2Repeated(_ times: Int) -> String {
        var result = ""
        for _ in 0..<times {
            result += self
        }
        return result
    }
}

// ▶️ Run
print("Hi".q2Repeated(3))


// MARK: - Q03. Struct Init in Extension (Memberwise Kept)

print("\n========== Q03 - Struct Init in Extension (Memberwise Kept) ==========")

struct Q3Point {
    var x: Int
    var y: Int
}

extension Q3Point {
    init(value: Int) {
        self.init(x: value, y: value)
    }
}

let q3A = Q3Point(x: 1, y: 2)

let q3B = Q3Point(value: 7)

// ▶️ Run
print(q3A.x, q3A.y)

print(q3B.x, q3B.y)


// MARK: - Q04. Static Property in Extension

print("\n========== Q04 - Static Property in Extension ==========")

struct Q4Config {}

extension Q4Config {
    static let baseURL = "https://shop.com"
    static let timeout = 30
}

// ▶️ Run
print(Q4Config.baseURL, Q4Config.timeout)


// MARK: - Q05. Protocol Conformance via Extension

print("\n========== Q05 - Protocol Conformance via Extension ==========")

struct Q5User {
    let first: String
    let last: String
}

extension Q5User: CustomStringConvertible {
    var description: String { "\(first) \(last)" }
}

let q5User = Q5User(first: "Anil", last: "Kumar")

// ▶️ Run
print(q5User)


// MARK: - Q06. Constrained Extension (where Element: Numeric)

print("\n========== Q06 - Constrained Extension (where Element: Numeric) ==========")

extension Array where Element: Numeric {
    func q6Total() -> Element {
        var sum: Element = 0
        for value in self {
            sum += value
        }
        return sum
    }
}

// ▶️ Run
print([1, 2, 3, 4].q6Total())

print([1.5, 2.5].q6Total())


// MARK: - Q07. mutating Method in Extension

print("\n========== Q07 - mutating Method in Extension ==========")

struct Q7Counter {
    var value = 0
}

extension Q7Counter {
    mutating func increment(by amount: Int) {
        value += amount
    }
}

var q7Counter = Q7Counter()

q7Counter.increment(by: 5)

q7Counter.increment(by: 3)

// ▶️ Run
print(q7Counter.value)


// MARK: - Q08. Extension Method on Class + Subclass

print("\n========== Q08 - Extension Method on Class + Subclass ==========")

class Q8Animal {
    func name() -> String { "Animal" }
}

extension Q8Animal {
    func describe() -> String {
        "I am \(name())"
    }
}

final class Q8Dog: Q8Animal {
    override func name() -> String { "Dog" }
}

let q8Pet: Q8Animal = Q8Dog()

// ▶️ Run
print(q8Pet.describe())


// MARK: - Q09. Nested Type in Extension

print("\n========== Q09 - Nested Type in Extension ==========")

struct Q9Order {
    var statusCode: Int
}

extension Q9Order {
    enum Status: String {
        case placed
        case shipped
        case unknown
    }

    var status: Status {
        switch statusCode {
        case 1: return .placed
        case 2: return .shipped
        default: return .unknown
        }
    }
}

// ▶️ Run
print(Q9Order(statusCode: 2).status.rawValue)

print(Q9Order(statusCode: 9).status.rawValue)
