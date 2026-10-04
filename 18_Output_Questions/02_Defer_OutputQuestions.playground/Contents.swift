import Foundation


// MARK: - Q01. Basic Defer

print("\n========== Q01 - Basic Defer ==========")

func q1Defer() {
    defer { print("A") }
    print("B")
}

// ▶️ Run
q1Defer()


// MARK: - Q02. Multiple Defer

print("\n========== Q02 - Multiple Defer ==========")

func q2Defer() {
    defer { print("1") }
    defer { print("2") }
    print("Start")
}

// ▶️ Run
q2Defer()


// MARK: - Q03. Defer with Return

print("\n========== Q03 - Defer with Return ==========")

func q3Defer() {
    defer { print("Defer") }
    print("Before return")
    return
}

// ▶️ Run
q3Defer()


// MARK: - Q04. Variable Read at Exit

print("\n========== Q04 - Variable Read at Exit ==========")

func q4Defer() {

    var x = 10

    defer {
        print(x)
    }

    x = 50
}

// ▶️ Run
q4Defer()


// MARK: - Q05. Multiple Defer + Variable

print("\n========== Q05 - Multiple Defer + Variable ==========")

func q5Defer() {

    var x = 1

    defer { print("A:", x) }

    x = 2

    defer { print("B:", x) }

    x = 3
}

// ▶️ Run
q5Defer()


// MARK: - Q06. Defer in Loop

print("\n========== Q06 - Defer in Loop ==========")

func q6Defer() {
    for i in 1...3 {
        defer { print(i) }
    }
}

// ▶️ Run
q6Defer()


// MARK: - Q07. Nested Scope

print("\n========== Q07 - Nested Scope ==========")

func q7Defer() {

    defer { print("Outer") }

    do {
        defer { print("Inner") }
        print("Inside")
    }
}

// ▶️ Run
q7Defer()


// MARK: - Q08. Return Value Trick

print("\n========== Q08 - Return Value Trick ==========")

func q8Defer() -> Int {

    var x = 10

    defer {
        x = 100
    }

    return x
}

// ▶️ Run
print(q8Defer())


// MARK: - Q09. Conditional Defer

print("\n========== Q09 - Conditional Defer ==========")

func q9Defer(flag: Bool) {

    if flag {
        defer { print("Inside defer") }
        print("Inside if")
    }

    print("End")
}

// ▶️ Run
q9Defer(flag: true)

q9Defer(flag: false)


// MARK: - Q10. Condition Inside Defer

print("\n========== Q10 - Condition Inside Defer ==========")

func q10Defer() {

    var x = 5

    defer {
        if x > 10 {
            print("Big")
        } else {
            print("Small")
        }
    }

    x = 20
}

// ▶️ Run
q10Defer()


// MARK: - Q11. Multiple Returns

print("\n========== Q11 - Multiple Returns ==========")

func q11Defer(_ x: Int) -> Int {

    defer { print("Defer executed") }

    if x > 10 {
        return 1
    }

    return 2
}

// ▶️ Run
print(q11Defer(5))

print(q11Defer(20))


// MARK: - Q12. Defer + Closure Capture

print("\n========== Q12 - Defer + Closure Capture ==========")

func q12Defer() {

    var x = 10

    let closure = {
        print("Closure:", x)
    }

    defer {
        print("Defer:", x)
    }

    x = 50

    closure()
}

// ▶️ Run
q12Defer()


// MARK: - Q13. Defer in Loop with Work

print("\n========== Q13 - Defer in Loop with Work ==========")

func q13Defer() {
    for i in 1...2 {
        defer { print("Loop:", i) }
        print("Running:", i)
    }
}

// ▶️ Run
q13Defer()


// MARK: - Q14. Nested Defer Levels

print("\n========== Q14 - Nested Defer Levels ==========")

func q14Defer() {

    defer { print("Level 1") }

    do {
        defer { print("Level 2") }

        do {
            defer { print("Level 3") }
            print("Inside")
        }
    }
}

// ▶️ Run
q14Defer()


// MARK: - Q15. Defer + Optional

print("\n========== Q15 - Defer + Optional ==========")

func q15Defer() {

    var value: String? = "Hello"

    defer {
        if let value = value {
            print(value)
        } else {
            print("nil")
        }
    }

    value = nil
}

// ▶️ Run
q15Defer()


// MARK: - Q16. Defer + throw

print("\n========== Q16 - Defer + throw ==========")

enum Q16Error: Error {
    case failed
}

func q16Defer() throws {

    defer { print("Cleanup") }

    print("Start")

    throw Q16Error.failed
}

// ▶️ Run
do {
    try q16Defer()
} catch {
    print("Caught")
}


// MARK: - Q17. Defer Registered Before guard

print("\n========== Q17 - Defer Registered Before guard ==========")

func q17Defer(_ value: Int) {

    defer { print("Defer") }

    guard value > 0 else {
        print("Invalid")
        return
    }

    print("Valid")
}

// ▶️ Run
q17Defer(-1)

q17Defer(5)


// MARK: - Q18. Real Use Case — Lock / Unlock

print("\n========== Q18 - Real Use Case — Lock / Unlock ==========")

final class Q18Counter {

    private let lock = NSLock()

    private(set) var count = 0

    func increment() {

        lock.lock()

        defer { lock.unlock() }

        count += 1

        print("Count:", count)
    }
}

let q18Counter = Q18Counter()

// ▶️ Run
q18Counter.increment()

q18Counter.increment()
