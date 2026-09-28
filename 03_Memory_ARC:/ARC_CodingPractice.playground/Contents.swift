import UIKit

//==============================================================
// MARK: - ARC Coding Practice
//==============================================================


//==============================================================
// MARK: - Q01. Two Strong References
//==============================================================

final class User1 {

    deinit {
        print("User1 deinit")
    }
}

var first1: User1? = User1()

var second1 = first1

first1 = nil

print("After first nil")

second1 = nil

print("After second nil")


//==============================================================
// MARK: - Q02. weak After Release
//==============================================================

final class User2 {

    let name = "Anil"

    deinit {
        print("User2 deinit")
    }
}

var strong2: User2? = User2()

weak var weak2 = strong2

print(weak2?.name as Any)

strong2 = nil

print(weak2?.name as Any)


//==============================================================
// MARK: - Q03. Scope
//==============================================================

final class User3 {

    deinit {
        print("User3 deinit")
    }
}

func run3() {

    print("Start")

    let user = User3()

    print("End", user)
}

run3()

print("After function")


//==============================================================
// MARK: - Q04. deinit Order
//==============================================================

final class Engine4 {

    deinit {
        print("Engine4 deinit")
    }
}

class Vehicle4 {

    let engine = Engine4()

    deinit {
        print("Vehicle4 deinit")
    }
}

final class Car4: Vehicle4 {

    deinit {
        print("Car4 deinit")
    }
}

var car4: Car4? = Car4()

car4 = nil


//==============================================================
// MARK: - Q05. Strong Parent ↔ Child
//==============================================================

final class Parent5 {

    var child: Child5?

    deinit {
        print("Parent5 deinit")
    }
}

final class Child5 {

    var parent: Parent5?

    deinit {
        print("Child5 deinit")
    }
}

var parent5: Parent5? = Parent5()

var child5: Child5? = Child5()

parent5?.child = child5

child5?.parent = parent5

parent5 = nil

child5 = nil


//==============================================================
// MARK: - Q06. weak Back-Reference
//==============================================================

final class Parent6 {

    var child: Child6?

    deinit {
        print("Parent6 deinit")
    }
}

final class Child6 {

    weak var parent: Parent6?

    deinit {
        print("Child6 deinit")
    }
}

var parent6: Parent6? = Parent6()

var child6: Child6? = Child6()

parent6?.child = child6

child6?.parent = parent6

child6 = nil

print("Child reference cleared")

parent6 = nil


//==============================================================
// MARK: - Q07. Array Holds Objects
//==============================================================

final class Item7 {

    let id: Int

    init(id: Int) {
        self.id = id
    }

    deinit {
        print("Item7 \(id) deinit")
    }
}

var items7 = [Item7(id: 1), Item7(id: 2)]

let saved7 = items7[0]

items7.removeAll()

print("Array cleared", saved7.id)


//==============================================================
// MARK: - Q08. Struct Holding a Class
//==============================================================

final class Owner8 {

    deinit {
        print("Owner8 deinit")
    }
}

struct Profile8 {

    let owner: Owner8
}

var profile8: Profile8? = Profile8(owner: Owner8())

var copy8 = profile8

profile8 = nil

print("Original struct nil")

copy8 = nil


//==============================================================
// MARK: - Q09. weak Delegate Freed
//==============================================================

protocol Delegate9: AnyObject {

    func didFinish()
}

final class Worker9 {

    weak var delegate: Delegate9?

    func finish() {
        delegate?.didFinish()
        print("Worker finished")
    }
}

final class Screen9: Delegate9 {

    func didFinish() {
        print("Screen notified")
    }

    deinit {
        print("Screen9 deinit")
    }
}

let worker9 = Worker9()

var screen9: Screen9? = Screen9()

worker9.delegate = screen9

worker9.finish()

screen9 = nil

worker9.finish()


//==============================================================
// MARK: - Q10. unowned Order
//==============================================================

final class Customer10 {

    var card: Card10?

    deinit {
        print("Customer10 deinit")
    }
}

final class Card10 {

    unowned let customer: Customer10

    init(customer: Customer10) {
        self.customer = customer
    }

    deinit {
        print("Card10 deinit")
    }
}

var customer10: Customer10? = Customer10()

customer10?.card = Card10(customer: customer10!)

customer10 = nil


//==============================================================
// MARK: - Q11. Three-Object Chain with One weak Link
//==============================================================

final class NodeA11 {

    var next: NodeB11?

    deinit {
        print("NodeA11 deinit")
    }
}

final class NodeB11 {

    var next: NodeC11?

    deinit {
        print("NodeB11 deinit")
    }
}

final class NodeC11 {

    weak var next: NodeA11?

    deinit {
        print("NodeC11 deinit")
    }
}

var nodeA11: NodeA11? = NodeA11()

nodeA11?.next = NodeB11()

nodeA11?.next?.next = NodeC11()

nodeA11?.next?.next?.next = nodeA11

print("Chain built")

nodeA11 = nil


//==============================================================
// MARK: - Q12. weak to a New Instance
//==============================================================

final class User12 {

    deinit {
        print("User12 deinit")
    }
}

weak var weak12 = User12()

print(weak12 as Any)


//==============================================================
// MARK: - Q13. Dictionary Holds Objects
//==============================================================

final class Item13 {

    deinit {
        print("Item13 deinit")
    }
}

var cache13: [String: Item13] = ["a": Item13()]

print("Before remove")

cache13["a"] = nil

print("After remove")


//==============================================================
// MARK: - Q14. Reassigning a Variable
//==============================================================

final class User14 {

    let name: String

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) deinit")
    }
}

var user14 = User14(name: "First")

user14 = User14(name: "Second")

print("Current:", user14.name)


//==============================================================
// MARK: - Q15. Child Outlives Parent
//==============================================================

final class Engine15 {

    deinit {
        print("Engine15 deinit")
    }
}

final class Car15 {

    let engine = Engine15()

    deinit {
        print("Car15 deinit")
    }
}

var car15: Car15? = Car15()

var engine15 = car15?.engine

car15 = nil

print("Car released")

engine15 = nil


//==============================================================
// MARK: - Q16. Two weak References
//==============================================================

final class User16 {

    deinit {
        print("User16 deinit")
    }
}

var strong16: User16? = User16()

weak var weakA16 = strong16

weak var weakB16 = strong16

strong16 = nil

print(weakA16 as Any, weakB16 as Any)


//==============================================================
// MARK: - Q17. Array of weak Boxes
//==============================================================

final class Listener17 {

    let id: Int

    init(id: Int) {
        self.id = id
    }

    deinit {
        print("Listener17 \(id) deinit")
    }
}

struct WeakBox17 {

    weak var value: Listener17?
}

var listener17: Listener17? = Listener17(id: 1)

let boxes17 = [WeakBox17(value: listener17)]

listener17 = nil

print("Box value:", boxes17[0].value as Any)


//==============================================================
// MARK: - Q18. Singleton
//==============================================================

final class Manager18 {

    static let shared = Manager18()

    private init() {
        print("Manager18 init")
    }

    deinit {
        print("Manager18 deinit")
    }
}

var manager18: Manager18? = Manager18.shared

manager18 = nil

print("Local reference cleared")


//==============================================================
// MARK: - Q19. do Block Scope
//==============================================================

final class User19 {

    deinit {
        print("User19 deinit")
    }
}

print("Before block")

do {
    let user = User19()
    print("Inside block", user)
}

print("After block")


//==============================================================
// MARK: - Q20. Swapping References
//==============================================================

final class User20 {

    let name: String

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) deinit")
    }
}

var left20 = User20(name: "Left")

var right20 = User20(name: "Right")

(left20, right20) = (right20, left20)

print(left20.name, right20.name)


//==============================================================
// MARK: - Q21. unowned After Owner Is Freed
//==============================================================

final class Customer21 {

    let name = "Anil"

    deinit {
        print("Customer21 deinit")
    }
}

final class Card21 {

    unowned let customer: Customer21

    init(customer: Customer21) {
        self.customer = customer
    }
}

var customer21: Customer21? = Customer21()

let card21 = Card21(customer: customer21!)

print(card21.customer.name)

customer21 = nil

// print(card21.customer.name)   What happens if you uncomment this?
