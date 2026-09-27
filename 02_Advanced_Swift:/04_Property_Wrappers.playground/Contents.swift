import Foundation

//==============================================================
// MARK: - Property Wrappers
//==============================================================
// Reusable get/set logic attached to a property with @Name.
//
// Compiler generates for: @Clamped var score = 50
// private var _score = Clamped(wrappedValue: 50, ...)   // storage
// var score  { _score.wrappedValue }                     // value
// var $score { _score.projectedValue }                   // extra API
//
// Limitations: var only (not let), not in protocols, not lazy, not computed.

//==============================================================
// MARK: - 01. Generic Wrapper with Arguments
//==============================================================

@propertyWrapper
struct Clamped<Value: Comparable> {
    private var value: Value
    let range: ClosedRange<Value>

    init(wrappedValue: Value, range: ClosedRange<Value>) {
        self.range = range
        self.value = min(max(wrappedValue, range.lowerBound), range.upperBound)
    }

    var wrappedValue: Value {
        get { value }
        set { value = min(max(newValue, range.lowerBound), range.upperBound) }
    }
}

struct Player {
    @Clamped(range: 0...100) var score = 50
    @Clamped(range: 0.0...1.0) var volume = 0.5
}

print("\n========== 01 - Generic Wrapper with Arguments ==========")
var player = Player()
player.score = 120
print(player.score)  // 100
player.volume = -3
print(player.volume) // 0.0

//==============================================================
// MARK: - 02. projectedValue
//==============================================================
// $property exposes extra information from the wrapper.

@propertyWrapper
struct Validated {
    private var value: String

    init(wrappedValue: String) {
        value = wrappedValue
    }

    var wrappedValue: String {
        get { value }
        set { value = newValue }
    }

    var projectedValue: Bool {
        !value.isEmpty
    }
}

struct Login {
    @Validated var username = ""
}

print("\n========== 02 - projectedValue ==========")
var login = Login()
print(login.$username) // false
login.username = "Anil"
print(login.$username) // true

//==============================================================
// MARK: - 03. UserDefaults Wrapper
//==============================================================
// Real iOS use: one place for key, default, and storage.
// Note: UserDefaults persists between playground runs.

@propertyWrapper
struct UserDefault<Value> {
    let key: String
    let defaultValue: Value

    var wrappedValue: Value {
        get {
            if let stored = UserDefaults.standard.object(forKey: key) as? Value {
                return stored
            }
            return defaultValue
        }
        set {
            UserDefaults.standard.set(newValue, forKey: key)
        }
    }
}

struct AppSettings {
    @UserDefault(key: "isLoggedIn", defaultValue: false)
    var isLoggedIn: Bool
}

print("\n========== 03 - UserDefaults Wrapper ==========")
var appSettings = AppSettings()
print(appSettings.isLoggedIn) // false on first run
appSettings.isLoggedIn = true
print(appSettings.isLoggedIn) // true

//==============================================================
// MARK: - 04. SwiftUI Connection
//==============================================================
//
// @State var count = 0
// count  → wrappedValue   (the Int)
// $count → projectedValue (Binding<Int>, passed to child views)
//
// @Published var name = ""
// name   → wrappedValue   (the String)
// $name  → projectedValue (Publisher, used with Combine)
//
//==============================================================

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a property wrapper?
// 2. wrappedValue vs projectedValue?
// 3. What does the compiler generate for @Wrapper var x?
// 4. How do you pass extra arguments like a range?
// 5. How do @State and @Published use wrappers?
// 6. Limitations — let, protocols, lazy, computed?
//
//==============================================================
