import Foundation

//==============================================================
// MARK: - Strong References
//==============================================================
//
// Every reference is strong by default.
// Strong = ownership → keeps the object alive (+1 count).
// Rule: strong for things you OWN, weak for things you only POINT to.
//

final class Engine {

    deinit {
        print("Engine deinit")
    }
}

final class Car {

    let engine = Engine()   // strong — Car owns Engine

    deinit {
        print("Car deinit")
    }
}


//==============================================================
// MARK: - 01. Strong by Default
//==============================================================

print("\n========== 01 - Strong by Default ==========")

var car: Car? = Car()       // Car count 1, Engine count 1

car = nil                   // Car deinit → Engine deinit


//==============================================================
// MARK: - 02. Strong Property Keeps Child Alive
//==============================================================
//
// Engine lives as long as ANY strong reference exists.
//

print("\n========== 02 - Strong Property Keeps Child Alive ==========")

var myCar: Car? = Car()

let spareEngine = myCar?.engine   // Engine count 2

myCar = nil                       // Car deinit — Engine still alive

print("Engine alive:", spareEngine != nil)   // true


//==============================================================
// MARK: - 03. Collections Hold Strong References
//==============================================================
//
// Arrays and dictionaries retain every element.
// Removing the element releases it.
//

print("\n========== 03 - Collections Hold Strong References ==========")

var garage: [Car] = [Car()]       // Car count 1 (held by array)

garage.removeAll()                // Car deinit → Engine deinit


//==============================================================
// MARK: - 04. Closures Capture Strongly
//==============================================================
//
// A closure keeps captured objects alive until the closure is released.
//

print("\n========== 04 - Closures Capture Strongly ==========")

var rental: Car? = Car()

var drive: (() -> Void)? = { [rental] in
    print("Driving", rental != nil)
}

rental = nil                      // no deinit — closure still holds Car

drive?()                          // Driving true

drive = nil                       // Car deinit → Engine deinit


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a strong reference?
//    → A reference that owns the object and adds +1 to its count.
//
// 2. Why are references strong by default?
//    → Safest default — an object you hold can't disappear under you.
//
// 3. When should a reference be strong vs weak?
//    → Strong for what you own (child, dependency). Weak for back-references and delegates.
//
// 4. Do arrays hold strong references to their elements?
//    → Yes. Removing the element or the array releases them.
//
// 5. How can a closure keep an object alive?
//    → It captures strongly — the object lives until the closure is released.
//
//==============================================================
