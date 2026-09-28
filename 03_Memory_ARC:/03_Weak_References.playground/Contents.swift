import Foundation

//==============================================================
// MARK: - Weak References
//==============================================================
//
// weak = does NOT increase the strong count.
// When the object is freed, ARC sets the weak reference to nil.
// So weak must be var + Optional.
// Main use: delegates, parent back-references → break retain cycles.
//

final class User {

    let name: String

    init(name: String) {
        self.name = name
    }

    deinit {
        print("\(name) deinit")
    }
}


//==============================================================
// MARK: - 01. weak Does Not Keep Alive
//==============================================================

print("\n========== 01 - weak Does Not Keep Alive ==========")

var strongUser: User? = User(name: "Anil")   // count 1

weak var weakUser = strongUser               // count still 1

print(weakUser?.name as Any)                 // Optional("Anil")

strongUser = nil                             // Anil deinit

print(weakUser as Any)                       // nil — ARC set it


//==============================================================
// MARK: - 02. Must Be var + Optional
//==============================================================

final class Holder {

    weak var user: User?                 // ✅

    // weak let user: User?              ❌ weak must be var
    // weak var user: User               ❌ weak must be Optional
}


//==============================================================
// MARK: - 03. Breaking a Cycle
//==============================================================
//
// Person owns Apartment (strong).
// Apartment points back to Person (weak) → no cycle.
//

final class Person {

    var apartment: Apartment?

    deinit {
        print("Person deinit")
    }
}

final class Apartment {

    weak var tenant: Person?

    deinit {
        print("Apartment deinit")
    }
}

print("\n========== 03 - Breaking a Cycle ==========")

var person: Person? = Person()

var apartment: Apartment? = Apartment()

person?.apartment = apartment

apartment?.tenant = person

person = nil                             // Person deinit

apartment = nil                          // Apartment deinit


//==============================================================
// MARK: - 04. Delegate Pattern
//==============================================================
//
// The child holds its delegate weakly.
// Protocol must be AnyObject — weak works only with classes.
//

protocol DownloaderDelegate: AnyObject {

    func didFinish()
}

final class Downloader {

    weak var delegate: DownloaderDelegate?

    func start() {
        delegate?.didFinish()
    }
}

final class Screen: DownloaderDelegate {

    let downloader = Downloader()

    init() {
        downloader.delegate = self
    }

    func didFinish() {
        print("Download finished")
    }

    deinit {
        print("Screen deinit")
    }
}

print("\n========== 04 - Delegate Pattern ==========")

var screen: Screen? = Screen()

screen?.downloader.start()               // Download finished

screen = nil                             // Screen deinit


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a weak reference?
//    → A non-owning reference — no +1, auto-set to nil when the object is freed.
//
// 2. Why must weak be var and Optional?
//    → ARC changes it to nil at runtime, so it must be mutable and able to hold nil.
//
// 3. Why are delegates declared weak?
//    → The owner holds the child strongly; a strong delegate back would create a cycle.
//
// 4. Why must a delegate protocol be AnyObject?
//    → weak works only with class instances — AnyObject restricts conformers to classes.
//
// 5. What happens to a weak reference when the object is freed?
//    → It becomes nil automatically — safe to access with ?.
//
//==============================================================
