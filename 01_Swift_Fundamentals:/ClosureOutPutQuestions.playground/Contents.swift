import UIKit

//==============================================================
// MARK: - Closure Coding Practice
//==============================================================


//==============================================================
// MARK: - Q01. Normal Capture
//==============================================================

var number = 10

let closure = {
    print(number)
}

number = 20

closure()


//==============================================================
// MARK: - Q02. Capture List
//==============================================================

var number2 = 10

let closure2 = { [number2] in
    print(number2)
}

number2 = 20

closure2()


//==============================================================
// MARK: - Q03. Captured Mutable State
//==============================================================

var count = 0

let counter = {
    count += 1
    print(count)
}

counter()
counter()
counter()


//==============================================================
// MARK: - Q04. Shared Closure State
//==============================================================

func makeCounter() -> () -> Int {

    var count = 0

    return {
        count += 1
        return count
    }
}

let counterOne = makeCounter()
let counterTwo = counterOne

print(counterOne())
print(counterTwo())
print(counterOne())


//==============================================================
// MARK: - Q05. Capture List + Class
//==============================================================

final class User {

    var name = "Anil"
}

let user = User()

let userClosure = { [user] in
    print(user.name)
}

user.name = "Kumar"

userClosure()


//==============================================================
// MARK: - Q06. Escaping Closure
//==============================================================

var storedClosure: (() -> Void)?

@MainActor func performTask(completion: @escaping () -> Void) {

    print("Start")

    storedClosure = completion

    print("End")
}

performTask {
    print("Closure")
}

print("After")

storedClosure?()


//==============================================================
// MARK: - Q07. Escaping + DispatchQueue
//==============================================================

func performAsyncTask(completion: @escaping @Sendable () -> Void) {

    print("1")

    DispatchQueue.main.async {

        print("2")
        completion()
    }

    print("3")
}

print("5")

performAsyncTask {

    print("4")
}


//==============================================================
// MARK: - Q08. Weak Self
//==============================================================

final class ViewModel {

    var completion: (() -> Void)?

    func start() {

        completion = { [weak self] in

            guard let self else { return }

            print(self)
        }
    }
}

let viewModel = ViewModel()

viewModel.start()
viewModel.completion?()


//==============================================================
// MARK: - Q09. @autoclosure
//==============================================================

func check(_ condition: @autoclosure () -> Bool) {

    print(condition())
}

check(10 > 5)


//==============================================================
// MARK: - Q10. Closure Returning Closure
//==============================================================

func multiplier(_ value: Int) -> (Int) -> Int {

    return { number in
        number * value
    }
}

let multiplyByTwo = multiplier(2)

print(multiplyByTwo(10))


//==============================================================
// MARK: - Q11. Capture List + Struct
//==============================================================

struct Point {

    var x = 1
}

var point = Point()

let pointClosure = { [point] in
    print(point.x)
}

point.x = 99

pointClosure()


//==============================================================
// MARK: - Q12. Read at Creation or Call?
//==============================================================

var factor = 2

let multiply = { (value: Int) in
    value * factor
}

factor = 10

print(multiply(3))


//==============================================================
// MARK: - Q13. When Is the Capture List Evaluated?
//==============================================================

var value = 1

let first = { [value] in
    print(value)
}

value = 2

let second = { [value] in
    print(value)
}

value = 3

first()
second()


//==============================================================
// MARK: - Q14. Two Closures, One State
//==============================================================

func makeAccount() -> (deposit: (Int) -> Void, balance: () -> Int) {

    var money = 0

    return ({ money += $0 }, { money })
}

let account = makeAccount()

account.deposit(50)
account.deposit(25)

print(account.balance())


//==============================================================
// MARK: - Q15. Does It Compile?
//==============================================================

var total = 0

// let increment = { [total] in
//     total += 1
// }
