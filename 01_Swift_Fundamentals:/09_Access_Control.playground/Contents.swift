import UIKit

//==============================================================
// MARK: - 09. Access Control
//==============================================================
//
// Most open → most restricted:
// open → public → internal (default) → fileprivate → private
//==============================================================

//==============================================================
// MARK: - 01. private
//==============================================================
// Enclosing declaration + its extensions in the same file.

final class User {
    private var password = "12345"

    func showPassword() {
        print(password)
    }
}

print("\n========== 01 - private ==========")
let user = User()
user.showPassword() // 12345
// user.password    ❌ private

//==============================================================
// MARK: - 02. fileprivate
//==============================================================
// Anything in the same file — including other types.

final class Account {
    fileprivate var balance = 1000
    private var pin = 1234
}

final class Auditor {
    func audit(_ account: Account) {
        print(account.balance)   // ✅ fileprivate — same file
        // print(account.pin)    ❌ private — different type
    }
}

print("\n========== 02 - fileprivate ==========")
Auditor().audit(Account()) // 1000

//==============================================================
// MARK: - 03. internal
//==============================================================
// Default. Anywhere in the same module.
// Unit tests reach it with @testable import.

final class Product {
    var name = "iPhone"
}

print("\n========== 03 - internal ==========")
print(Product().name) // iPhone

//==============================================================
// MARK: - 04. public vs open
//==============================================================
// public → usable outside the module, NOT subclassable/overridable there.
// open   → usable, subclassable, and overridable outside the module.
// open is for classes and class members only (structs can't be subclassed).
// A playground is one module, so the difference can't be shown here.

public struct APIClient {
    public init() {}

    public func request() {
        print("Request")
    }
}

open class BaseViewController: UIViewController {
    open func setupUI() {
        print("Setup UI")
    }
}

print("\n========== 04 - public vs open ==========")
APIClient().request() // Request

//==============================================================
// MARK: - 05. private(set)
//==============================================================
// Public read, private write.

final class UserSession {
    private(set) var isLoggedIn = false

    func login() {
        isLoggedIn = true
    }
}

print("\n========== 05 - private(set) ==========")
let session = UserSession()
print(session.isLoggedIn) // false
session.login()
print(session.isLoggedIn) // true
// session.isLoggedIn = false   ❌ setter is private

//==============================================================
// MARK: - 06. Extensions
//==============================================================
// A same-file extension can access private members.

final class ViewModel {
    private var value = 10

    func update() {
        value += 1
    }
}

extension ViewModel {
    func printValue() {
        print(value) // ✅ private, same file
    }
}

print("\n========== 06 - Extensions ==========")
let viewModel = ViewModel()
viewModel.update()
viewModel.printValue() // 11

//==============================================================
// MARK: - 07. Visibility Rule
//==============================================================
// A member can't be more visible than the types it uses.

struct InternalModel {}

// public func loadModel() -> InternalModel { InternalModel() }
// ❌ public function uses an internal type

func loadModel() -> InternalModel { InternalModel() } // ✅ internal

//==============================================================
// MARK: - Quick Revision
//==============================================================
//
// private      → Declaration + same-file extensions
// fileprivate  → Same file
// internal     → Same module (default)
// public       → Other modules, no subclass/override
// open         → Other modules, subclass/override allowed
// private(set) → Read wider, write restricted
//
//==============================================================

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What are Swift's access levels?
// 2. What is the default access level?
// 3. private vs fileprivate?
// 4. public vs open? Why is open only for classes?
// 5. What is private(set)?
// 6. Can an extension access private members?
// 7. Why can't a public function return an internal type?
// 8. How do unit tests access internal code?
//
//==============================================================
