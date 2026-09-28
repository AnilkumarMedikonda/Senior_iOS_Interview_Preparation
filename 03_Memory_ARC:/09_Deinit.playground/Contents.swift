import Foundation

//==============================================================
// MARK: - Deinit
//==============================================================
//
// deinit runs automatically right before a class instance is freed
// (strong count reaches 0).
// Classes only. No parameters, can't be called manually.
// Use it for cleanup and to verify objects are actually released.
//


//==============================================================
// MARK: - 01. When deinit Runs
//==============================================================

final class Session {

    init() {
        print("Session init")
    }

    deinit {
        print("Session deinit")
    }
}

print("\n========== 01 - When deinit Runs ==========")

var session: Session? = Session()        // Session init

session = nil                            // Session deinit

// session.deinit()                      ❌ can't be called manually

// struct Point { deinit {} }            ❌ deinit only in classes


//==============================================================
// MARK: - 02. deinit Order
//==============================================================
//
// Subclass deinit runs first, then superclass deinit.
// Owned properties are released after the owner's deinit.
//

final class Engine {

    deinit {
        print("Engine deinit")
    }
}

class Vehicle {

    let engine = Engine()

    deinit {
        print("Vehicle deinit")
    }
}

final class Car: Vehicle {

    deinit {
        print("Car deinit")
    }
}

print("\n========== 02 - deinit Order ==========")

var car: Car? = Car()

car = nil

// Car deinit → Vehicle deinit → Engine deinit


//==============================================================
// MARK: - 03. Cleanup in deinit
//==============================================================
//
// Release what the object started:
// NotificationCenter observers, timers, tasks, file handles.
//

final class ProfileScreen {

    private var observer: NSObjectProtocol?

    init() {
        observer = NotificationCenter.default.addObserver(forName: .init("ProfileUpdated"),
            object: nil, queue: nil) { _ in
            print("Profile updated")
        }
    }

    deinit {
        if let observer {
            NotificationCenter.default.removeObserver(observer)
        }
        print("ProfileScreen deinit — observer removed")
    }
}

print("\n========== 03 - Cleanup in deinit ==========")

var profileScreen: ProfileScreen? = ProfileScreen()

NotificationCenter.default.post(name: .init("ProfileUpdated"), object: nil)   // Profile updated

profileScreen = nil                      // ProfileScreen deinit — observer removed

NotificationCenter.default.post(name: .init("ProfileUpdated"), object: nil)   // nothing


//==============================================================
// MARK: - 04. When deinit Never Runs
//==============================================================
//
// Retain cycle → count never reaches 0 → no deinit → leak.
// Missing deinit print after leaving a screen = first sign of a leak.
//

final class ChatScreen {

    var onSend: (() -> Void)?

    func setup() {
        onSend = { print(self) }         // ❌ self → closure → self
    }

    deinit {
        print("ChatScreen deinit")
    }
}

print("\n========== 04 - When deinit Never Runs ==========")

var chatScreen: ChatScreen? = ChatScreen()

chatScreen?.setup()

chatScreen = nil

// No deinit printed — leaked


//==============================================================
// MARK: - 05. Leak Verification
//==============================================================
//
// 1. Add deinit prints to ViewControllers / ViewModels.
// 2. Push and pop the screen — deinit must print.
// 3. If not, open Xcode Memory Graph Debugger → find the strong path.
// 4. Instruments → Leaks for anything missed.
//
// Don't start async work that captures self inside deinit —
// self is being destroyed and can't be kept alive.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. When is deinit called?
//    → Right before a class instance is freed, when its strong count hits 0.
//
// 2. Can structs have deinit?
//    → No (except ~Copyable types). Only classes are reference counted.
//
// 3. What is the deinit order in a class hierarchy?
//    → Subclass first, then superclass. Owned properties are released after.
//
// 4. What should you clean up in deinit?
//    → Observers, timers, tasks, file handles — anything the object started.
//
// 5. How do you use deinit to find memory leaks?
//    → Print in deinit, dismiss the screen; no print = leak → Memory Graph.
//
// 6. Why might deinit never be called?
//    → A retain cycle keeps the count above 0.
//
//==============================================================
