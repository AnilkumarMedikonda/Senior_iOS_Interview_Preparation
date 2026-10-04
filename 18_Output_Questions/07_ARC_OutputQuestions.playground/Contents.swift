import Foundation


// MARK: - Q01. Basic deinit

print("\n========== Q01 - Basic deinit ==========")

final class Q1A {
    deinit { print("Q1A deinit") }
}

var q1A: Q1A? = Q1A()

// ▶️ Run
q1A = nil

print("End Q01")


// MARK: - Q02. Two References

print("\n========== Q02 - Two References ==========")

final class Q2B {
    deinit { print("Q2B deinit") }
}

var q2First: Q2B? = Q2B()

var q2Second = q2First

// ▶️ Run
q2First = nil

print("After first = nil")

q2Second = nil

print("End Q02")


// MARK: - Q03. Scope Ends

print("\n========== Q03 - Scope Ends ==========")

final class Q3User {
    let name: String
    init(name: String) {
        self.name = name
        print("\(name) init")
    }
    deinit { print("\(name) deinit") }
}

// ▶️ Run
do {
    let user = Q3User(name: "Local")
    print("Using", user.name)
}

print("End Q03")


// MARK: - Q04. Retain Cycle (Objects)

print("\n========== Q04 - Retain Cycle (Objects) ==========")

final class Q4Person {
    var pet: Q4Pet?
    deinit { print("Q4Person deinit") }
}

final class Q4Pet {
    var owner: Q4Person?
    deinit { print("Q4Pet deinit") }
}

var q4Person: Q4Person? = Q4Person()

var q4Pet: Q4Pet? = Q4Pet()

q4Person?.pet = q4Pet

q4Pet?.owner = q4Person

// ▶️ Run
q4Person = nil

q4Pet = nil

print("End Q04")


// MARK: - Q05. weak Fix + Order

print("\n========== Q05 - weak Fix + Order ==========")

final class Q5Person {
    var pet: Q5Pet?
    deinit { print("Q5Person deinit") }
}

final class Q5Pet {
    weak var owner: Q5Person?
    deinit { print("Q5Pet deinit") }
}

var q5Person: Q5Person? = Q5Person()

var q5Pet: Q5Pet? = Q5Pet()

q5Person?.pet = q5Pet

q5Pet?.owner = q5Person

// ▶️ Run
q5Person = nil

print("After person = nil")

q5Pet = nil

print("End Q05")


// MARK: - Q06. weak Becomes nil

print("\n========== Q06 - weak Becomes nil ==========")

final class Q6Owner {
    deinit { print("Q6Owner deinit") }
}

final class Q6Holder {
    weak var owner: Q6Owner?
}

let q6Holder = Q6Holder()

var q6Owner: Q6Owner? = Q6Owner()

q6Holder.owner = q6Owner

// ▶️ Run
print("Before:", q6Holder.owner == nil)

q6Owner = nil

print("After:", q6Holder.owner == nil)


// MARK: - Q07. Closure Retain Cycle

print("\n========== Q07 - Closure Retain Cycle ==========")

final class Q7ViewModel {
    var onUpdate: (() -> Void)?
    func setup() {
        onUpdate = {
            print(self)
        }
    }
    deinit { print("Q7ViewModel deinit") }
}

var q7VM: Q7ViewModel? = Q7ViewModel()

q7VM?.setup()

// ▶️ Run
q7VM = nil

print("End Q07")


// MARK: - Q08. [weak self] Fix

print("\n========== Q08 - [weak self] Fix ==========")

final class Q8ViewModel {
    var onUpdate: (() -> Void)?
    func setup() {
        onUpdate = { [weak self] in
            print(self as Any)
        }
    }
    deinit { print("Q8ViewModel deinit") }
}

var q8VM: Q8ViewModel? = Q8ViewModel()

q8VM?.setup()

// ▶️ Run
q8VM = nil

print("End Q08")


// MARK: - Q09. Local Closure (Not Stored)

print("\n========== Q09 - Local Closure (Not Stored) ==========")

final class Q9Worker {
    func run() {
        let task = {
            print("Running")
        }
        task()
        _ = self
    }
    deinit { print("Q9Worker deinit") }
}

var q9Worker: Q9Worker? = Q9Worker()

// ▶️ Run
q9Worker?.run()

q9Worker = nil

print("End Q09")


// MARK: - Q10. unowned (Child Dies with Owner)

print("\n========== Q10 - unowned (Child Dies with Owner) ==========")

final class Q10Customer {
    var card: Q10Card?
    deinit { print("Q10Customer deinit") }
}

final class Q10Card {
    unowned let owner: Q10Customer
    init(owner: Q10Customer) { self.owner = owner }
    deinit { print("Q10Card deinit") }
}

var q10Customer: Q10Customer? = Q10Customer()

if let customer = q10Customer {
    customer.card = Q10Card(owner: customer)
}

// ▶️ Run
q10Customer = nil

print("End Q10")


// MARK: - Q11. Struct Holding Closure (Class Cycle)

print("\n========== Q11 - Struct Holding Closure (Class Cycle) ==========")

struct Q11Handler {
    var onTap: (() -> Void)?
}

final class Q11Screen {
    var handler = Q11Handler()
    func setup() {
        handler.onTap = {
            print(self)
        }
    }
    deinit { print("Q11Screen deinit") }
}

var q11Screen: Q11Screen? = Q11Screen()

q11Screen?.setup()

// ▶️ Run
q11Screen = nil

print("End Q11")
