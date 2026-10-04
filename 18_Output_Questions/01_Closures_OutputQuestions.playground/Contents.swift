import Foundation


// MARK: - Q01. Capture by Reference

print("\n========== Q01 - Capture by Reference ==========")

var q1Number = 100

let q1Closure = {
    print("Number:", q1Number)
}

q1Number = 300

q1Closure()


// MARK: - Q02. Capture List (Value Type)

print("\n========== Q02 - Capture List (Value Type) ==========")

var q2Number = 100

let q2Closure = { [q2Number] in
    print("Number:", q2Number)
}

q2Number = 400

q2Closure()


// MARK: - Q03. Counter (Captured State)

print("\n========== Q03 - Counter (Captured State) ==========")

func q3MakeCounter() -> () -> Int {

    var count = 0

    return {
        count += 1
        return count
    }
}

let q3Counter = q3MakeCounter()

print(q3Counter())

print(q3Counter())

let q3Another = q3MakeCounter()

print(q3Another())


// MARK: - Q04. Class Capture (Same Object Mutated)

print("\n========== Q04 - Class Capture (Same Object Mutated) ==========")

final class Q4User {
    var name = "Anil"
}

let q4User = Q4User()

let q4Closure = { [q4User] in
    print("User:", q4User.name)
}

q4User.name = "Kumar"

q4Closure()


// MARK: - Q05. Class Capture List (Variable Reassigned)

print("\n========== Q05 - Class Capture List (Variable Reassigned) ==========")

final class Q5Box {
    var value = 1
}

var q5Box = Q5Box()

let q5Closure = { [q5Box] in
    print("Value:", q5Box.value)
}

q5Box = Q5Box()

q5Box.value = 99

q5Closure()


// MARK: - Q06. No Capture List (Variable Reassigned)

print("\n========== Q06 - No Capture List (Variable Reassigned) ==========")

final class Q6Box {
    var value = 1
}

var q6Box = Q6Box()

let q6Closure = {
    print("Value:", q6Box.value)
}

q6Box = Q6Box()

q6Box.value = 99

q6Closure()


// MARK: - Q07. Struct Capture List

print("\n========== Q07 - Struct Capture List ==========")

struct Q7Point {
    var x = 1
}

var q7Point = Q7Point()

let q7Closure = { [q7Point] in
    print("X:", q7Point.x)
}

q7Point.x = 5

q7Closure()


// MARK: - Q08. Non-Escaping Order

print("\n========== Q08 - Non-Escaping Order ==========")

func q8Process(task: () -> Void) {

    print("Before")

    task()

    print("After")
}

q8Process {
    print("Closure")
}


// MARK: - Q09. Escaping Order

print("\n========== Q09 - Escaping Order ==========")

func q9Process(task: @escaping @Sendable () -> Void) {

    print("Before")

    DispatchQueue.main.async {
        task()
    }

    print("After")
}

q9Process {
    print("Escaping Closure")
}

print("Line after q9Process")


// MARK: - Q10. Closures in a Loop

print("\n========== Q10 - Closures in a Loop ==========")

var q10Closures: [() -> Void] = []

for i in 1...3 {
    q10Closures.append {
        print("Value:", i)
    }
}

for closure in q10Closures {
    closure()
}
