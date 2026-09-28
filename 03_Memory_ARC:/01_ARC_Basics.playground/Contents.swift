import Foundation

//==============================================================
// MARK: - ARC Basics
//==============================================================
//
// ARC = Automatic Reference Counting.
// The compiler inserts retain / release at compile time.
// A class instance is freed when its strong count reaches 0.
// Not garbage collection — no runtime scanning, no pauses.
//

final class User {

    let name: String

    init(name: String) {
        self.name = name
        print("\(name) init")
    }

    deinit {
        print("\(name) deinit")
    }
}


//==============================================================
// MARK: - 01. Deallocation at Count 0
//==============================================================

print("\n========== 01 - Deallocation at Count 0 ==========")

var user1: User? = User(name: "Anil")   // Anil init — count 1

user1 = nil                             // Anil deinit — count 0


//==============================================================
// MARK: - 02. Multiple Strong References
//==============================================================
//
// Each strong reference = +1.
// The object lives until the LAST reference is gone.
//

print("\n========== 02 - Multiple Strong References ==========")

var ref1: User? = User(name: "Ravi")    // Ravi init — count 1

var ref2 = ref1                         // count 2

ref1 = nil                              // count 1 — no deinit

print("Still alive:", ref2?.name as Any) // Optional("Ravi")

ref2 = nil                              // Ravi deinit — count 0


//==============================================================
// MARK: - 03. Scope
//==============================================================
//
// A local reference is released when the scope ends.
//

func createUser() {

    let local = User(name: "Local")     // Local init

    print("Using", local.name)

}                                       // Local deinit — function returned

print("\n========== 03 - Scope ==========")

createUser()


//==============================================================
// MARK: - 04. Value Types Are Not Reference Counted
//==============================================================
//
// Structs / enums are copied, not counted — no deinit.
// A struct holding a class → the class inside IS counted.
//

struct Profile {

    let owner: User
}

print("\n========== 04 - Value Types ==========")

var profile: Profile? = Profile(owner: User(name: "Owner"))   // Owner init

var profileCopy = profile               // struct copied → User count 2

profile = nil                           // count 1

profileCopy = nil                       // Owner deinit


//==============================================================
// MARK: - 05. ARC Can't Break Cycles
//==============================================================
//
// Two objects holding each other strongly never reach 0 → leak.
// Fix: weak / unowned → 03_Weak_References, 05_Retain_Cycles
//

final class Person {

    var apartment: Apartment?

    deinit {
        print("Person deinit")
    }
}

final class Apartment {

    var tenant: Person?

    deinit {
        print("Apartment deinit")
    }
}

print("\n========== 05 - ARC Can't Break Cycles ==========")

var person: Person? = Person()

var apartment: Apartment? = Apartment()

person?.apartment = apartment

apartment?.tenant = person

person = nil

apartment = nil

// No deinit printed — leaked


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is ARC? Compile time or runtime?
//    → Compiler inserts retain/release at compile time; counts change at runtime.
//
// 2. ARC vs garbage collection?
//    → ARC frees immediately at count 0, no pauses. GC scans later but can clean cycles.
//
// 3. When is a class instance deallocated?
//    → When its strong reference count reaches 0 — deinit runs right then.
//
// 4. Does ARC apply to structs? What about a struct holding a class?
//    → No — structs are copied. A class inside a struct is still counted.
//
// 5. Why can't ARC break retain cycles by itself?
//    → Each object keeps the other's count above 0. Break it with weak / unowned.
//
//==============================================================
