import Foundation


// MARK: - Q01. Default Implementation

print("\n========== Q01 - Default Implementation ==========")

protocol Q1Greet {
    func hello()
}

extension Q1Greet {
    func hello() {
        print("Hello from extension")
    }
}

struct Q1Person: Q1Greet {}

// ▶️ Run
Q1Person().hello()


// MARK: - Q02. Protocol Requirement Dispatch

print("\n========== Q02 - Protocol Requirement Dispatch ==========")

protocol Q2Greet {
    func hello()
}

extension Q2Greet {
    func hello() {
        print("Hello from extension")
    }
}

struct Q2Person: Q2Greet {
    func hello() {
        print("Hello from Person")
    }
}

let q2A: Q2Person = Q2Person()

let q2B: Q2Greet = Q2Person()

// ▶️ Run
q2A.hello()

q2B.hello()


// MARK: - Q03. Extension-Only Method (Static Dispatch)

print("\n========== Q03 - Extension-Only Method (Static Dispatch) ==========")

protocol Q3Greet {}

extension Q3Greet {
    func hello() {
        print("Hello from extension")
    }
}

struct Q3Person: Q3Greet {
    func hello() {
        print("Hello from Person")
    }
}

let q3A: Q3Person = Q3Person()

let q3B: Q3Greet = Q3Person()

// ▶️ Run
q3A.hello()

q3B.hello()


// MARK: - Q04. Default Property

print("\n========== Q04 - Default Property ==========")

protocol Q4Vehicle {
    var wheels: Int { get }
}

extension Q4Vehicle {
    var wheels: Int { 4 }

    func describe() {
        print("Wheels:", wheels)
    }
}

struct Q4Car: Q4Vehicle {}

struct Q4Bike: Q4Vehicle {
    var wheels: Int { 2 }
}

// ▶️ Run
Q4Car().describe()

Q4Bike().describe()


// MARK: - Q05. mutating + Struct Copy

print("\n========== Q05 - mutating + Struct Copy ==========")

protocol Q5Counter {
    var count: Int { get set }
    mutating func increment()
}

struct Q5StepCounter: Q5Counter {
    var count = 0
    mutating func increment() {
        count += 1
    }
}

var q5A = Q5StepCounter()

var q5B = q5A

q5A.increment()

q5A.increment()

q5B.increment()

// ▶️ Run
print(q5A.count, q5B.count)


// MARK: - Q06. AnyObject + weak

print("\n========== Q06 - AnyObject + weak ==========")

protocol Q6Listener: AnyObject {
    func notify()
}

final class Q6Screen: Q6Listener {
    func notify() { print("Notified") }
    deinit { print("Screen deinit") }
}

final class Q6Notifier {
    weak var listener: Q6Listener?

    func send() {
        if let listener = listener {
            listener.notify()
        } else {
            print("No listener")
        }
    }
}

let q6Notifier = Q6Notifier()

var q6Screen: Q6Screen? = Q6Screen()

q6Notifier.listener = q6Screen

// ▶️ Run
q6Notifier.send()

q6Screen = nil

q6Notifier.send()


// MARK: - Q07. Multiple Conformance + is

print("\n========== Q07 - Multiple Conformance + is ==========")

protocol Q7Flyable {}

protocol Q7Swimmable {}

struct Q7Duck: Q7Flyable, Q7Swimmable {}

struct Q7Fish: Q7Swimmable {}

let q7Animals: [Any] = [Q7Duck(), Q7Fish(), Q7Duck()]

var q7FlyCount = 0

var q7SwimCount = 0

for animal in q7Animals {
    if animal is Q7Flyable { q7FlyCount += 1 }
    if animal is Q7Swimmable { q7SwimCount += 1 }
}

// ▶️ Run
print(q7FlyCount, q7SwimCount)


// MARK: - Q08. Protocol Composition (&)

print("\n========== Q08 - Protocol Composition (&) ==========")

protocol Q8Named {
    var name: String { get }
}

protocol Q8Aged {
    var age: Int { get }
}

struct Q8User: Q8Named, Q8Aged {
    let name: String
    let age: Int
}

func q8Describe(_ person: Q8Named & Q8Aged) {
    print("\(person.name) is \(person.age)")
}

// ▶️ Run
q8Describe(Q8User(name: "Anil", age: 30))


// MARK: - Q09. Constrained Extension (where Self)

print("\n========== Q09 - Constrained Extension (where Self) ==========")

protocol Q9Describable {}

class Q9Base {}

final class Q9Child: Q9Base, Q9Describable {}

struct Q9Plain: Q9Describable {}

extension Q9Describable {
    func info() { print("Default info") }
}

extension Q9Describable where Self: Q9Base {
    func info() { print("Base class info") }
}

// ▶️ Run
Q9Child().info()

Q9Plain().info()


// MARK: - Q10. associatedtype

print("\n========== Q10 - associatedtype ==========")

protocol Q10Container {
    associatedtype Item
    var items: [Item] { get set }
    mutating func add(_ item: Item)
}

extension Q10Container {
    mutating func add(_ item: Item) {
        items.append(item)
    }
}

struct Q10IntBox: Q10Container {
    var items: [Int] = []
}

var q10Box = Q10IntBox()

q10Box.add(5)

q10Box.add(10)

// ▶️ Run
print(q10Box.items.count, q10Box.items)
