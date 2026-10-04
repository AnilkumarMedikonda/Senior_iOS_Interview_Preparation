import Foundation


// MARK: - Q01. Any — Type Check with is

print("\n========== Q01 - Any — Type Check with is ==========")

let q1Values: [Any] = [10, "Swift", 3.5, true]

var q1Count = 0

for value in q1Values {
    if value is Int || value is Double {
        q1Count += 1
    }
}

// ▶️ Run
print(q1Count)


// MARK: - Q02. Any — Casting with as?

print("\n========== Q02 - Any — Casting with as? ==========")

let q2Values: [Any] = [5, "10", 15, "Twenty"]

var q2Total = 0

for value in q2Values {
    if let number = value as? Int {
        q2Total += number
    }
}

// ▶️ Run
print(q2Total)


// MARK: - Q03. any Protocol — Mixed Types

print("\n========== Q03 - any Protocol — Mixed Types ==========")

protocol Q3Shape {
    func area() -> Double
}

struct Q3Square: Q3Shape {
    let side: Double
    func area() -> Double { side * side }
}

struct Q3Rect: Q3Shape {
    let w: Double
    let h: Double
    func area() -> Double { w * h }
}

let q3Shapes: [any Q3Shape] = [Q3Square(side: 2), Q3Rect(w: 3, h: 4)]

var q3Sum = 0.0

for shape in q3Shapes {
    q3Sum += shape.area()
}

// ▶️ Run
print(q3Sum)


// MARK: - Q04. some — One Hidden Concrete Type

print("\n========== Q04 - some — One Hidden Concrete Type ==========")

protocol Q4Animal {
    func sound() -> String
}

struct Q4Dog: Q4Animal {
    func sound() -> String { "Woof" }
}

func q4MakeAnimal() -> some Q4Animal {
    Q4Dog()
}

let q4Animal = q4MakeAnimal()

// ▶️ Run
print(q4Animal.sound())

print(type(of: q4Animal))


// MARK: - Q05. any — Different Types at Runtime

print("\n========== Q05 - any — Different Types at Runtime ==========")

protocol Q5Animal {
    func sound() -> String
}

struct Q5Dog: Q5Animal {
    func sound() -> String { "Woof" }
}

struct Q5Cat: Q5Animal {
    func sound() -> String { "Meow" }
}

func q5MakeAnimal(isDog: Bool) -> any Q5Animal {
    if isDog {
        return Q5Dog()
    } else {
        return Q5Cat()
    }
}

let q5Animals = [q5MakeAnimal(isDog: true), q5MakeAnimal(isDog: false)]

// ▶️ Run
for animal in q5Animals {
    print(animal.sound())
}

// ❓ Would q5MakeAnimal compile if the return type were `some Q5Animal`?


// MARK: - Q06. some Parameter

print("\n========== Q06 - some Parameter ==========")

protocol Q6Describable {
    var text: String { get }
}

struct Q6Item: Q6Describable {
    let text: String
}

func q6Show(_ item: some Q6Describable) {
    print("Item:", item.text)
}

// ▶️ Run
q6Show(Q6Item(text: "Shoe"))


// MARK: - Q07. Any Holding a Class vs Struct

print("\n========== Q07 - Any Holding a Class vs Struct ==========")

final class Q7RefBox {
    var value = 1
}

struct Q7ValBox {
    var value = 1
}

let q7Ref = Q7RefBox()

var q7Val = Q7ValBox()

let q7Items: [Any] = [q7Ref, q7Val]

q7Ref.value = 50

q7Val.value = 50

// ▶️ Run
if let ref = q7Items[0] as? Q7RefBox {
    print("Ref:", ref.value)
}

if let val = q7Items[1] as? Q7ValBox {
    print("Val:", val.value)
}
