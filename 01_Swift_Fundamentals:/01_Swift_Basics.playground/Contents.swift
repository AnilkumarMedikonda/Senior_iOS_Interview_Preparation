import Foundation

//==============================================================
// MARK: - 01. Swift Basics
//==============================================================
//
// Covers:
// 1. Variables and Constants
// 2. Data Types
// 3. Type Inference
// 4. Type Annotation
// 5. Operators
// 6. Control Flow (if, guard, loops, switch patterns)
// 7. Functions (labels, defaults, variadic, inout)
// 8. Tuples
// 9. Strings (String.Index, Unicode)
// 10. Arrays
// 11. Sets
// 12. Dictionaries
// 13. Ranges
// 14. Type Casting
// 15. Value vs Reference Semantics
//
// Interview Focus:
// - Type safety and type inference
// - Value semantics and copy-on-write
// - guard vs if let
// - Exhaustive switch and pattern matching
// - String indexing
// - Type casting (is, as, as?, as!)
//
// Note: top-level code runs only in a playground or main.swift.
//
//==============================================================

//==============================================================
// MARK: - 1. Variables and Constants
//==============================================================

let appName = "Skechers"
var retryCount = 0
retryCount += 1
print("App:", appName)
print("Retry Count:", retryCount)

// appName = "Other"   // Does not compile: `let` cannot be reassigned

//==============================================================
// MARK: - 2. Data Types
//==============================================================

let integerValue: Int = 10
let doubleValue: Double = 10.5
let floatValue: Float = 10.5
let booleanValue: Bool = true
let characterValue: Character = "A"
let stringValue: String = "Swift"
print(integerValue, doubleValue, floatValue, booleanValue, characterValue, stringValue)

//==============================================================
// MARK: - 3. Type Inference
//==============================================================

let inferredInteger = 100
let inferredDouble = 10.5
let inferredString = "Swift"
let inferredBoolean = true
print(type(of: inferredInteger))   // Int
print(type(of: inferredDouble))    // Double (not Float)
print(type(of: inferredString))    // String
print(type(of: inferredBoolean))   // Bool

//==============================================================
// MARK: - 4. Type Annotation
//==============================================================

let userName: String = "Anil"
let age: Int = 30
let experience: Double = 8.0
let isEmployed: Bool = true
print(userName, age, experience, isEmployed)

// No implicit conversion: Int and Double must be converted explicitly
let totalYears = Double(age) + experience
print(totalYears)

//==============================================================
// MARK: - 5. Operators
//==============================================================

// Arithmetic
let sum = 10 + 5
let difference = 10 - 5
let product = 10 * 5
let quotient = 10 / 3       // 3 — integer division truncates
let remainder = 10 % 3      // 1
let preciseQuotient = 10.0 / 3.0
print(sum, difference, product, quotient, remainder, preciseQuotient)

// Comparison
print(10 == 10, 10 != 5, 10 > 5, 10 < 20, 10 >= 10, 10 <= 20)

// Logical
let hasNetwork = true
let isAuthenticated = true
print(hasNetwork && isAuthenticated)
print(hasNetwork || isAuthenticated)
print(!hasNetwork)

// Ternary
let accessLabel = isAuthenticated ? "Logged In" : "Guest"
print(accessLabel)

//==============================================================
// MARK: - 6. Control Flow
//==============================================================

// if / else
let score = 85
if score >= 90 {
    print("Excellent")
} else if score >= 70 {
    print("Good")
} else {
    print("Needs Improvement")
}

// guard — early exit, unwrapped value stays in scope after the guard
func formatPrice(_ price: Double?) -> String {
    guard let price else {
        return "Price unavailable"
    }
    return "$\(price)"
}

// Same logic with if let — unwrapped value lives only inside the braces
func formatPriceWithIfLet(_ price: Double?) -> String {
    if let price {
        return "$\(price)"
    } else {
        return "Price unavailable"
    }
}

print(formatPrice(49.99))
print(formatPrice(nil))
print(formatPriceWithIfLet(49.99))

// for-in
for number in 1...5 {
    print("Number:", number)
}

// while
var counter = 0
while counter < 3 {
    print("Counter:", counter)
    counter += 1
}

// repeat-while — body runs at least once
var value = 0
repeat {
    print("Value:", value)
    value += 1
} while value < 3

// switch — must be exhaustive, no implicit fallthrough
let statusCode = 200
switch statusCode {
case 200:
    print("Success")
case 401:
    print("Unauthorized")
case 404:
    print("Not Found")
default:
    print("Other Status")
}

// switch — range matching
let responseCode = 503
switch responseCode {
case 200..<300:
    print("Success")
case 400..<500:
    print("Client Error")
case 500..<600:
    print("Server Error")
default:
    print("Unknown")
}

// switch — tuple matching, value binding, where clause
let point = (x: 3, y: 3)
switch point {
case (0, 0):
    print("Origin")
case (0, _):
    print("On Y-axis")
case (_, 0):
    print("On X-axis")
case let (x, y) where x == y:
    print("On diagonal at", x, y)
default:
    print("Somewhere else")
}

//==============================================================
// MARK: - 7. Functions
//==============================================================

func greet(name: String) -> String {
    return "Hello, \(name)"
}

let message = greet(name: "Anil")
print(message)

// Multiple parameters
func calculateTotal(price: Double, quantity: Int) -> Double {
    return price * Double(quantity)
}

let total = calculateTotal(price: 100, quantity: 3)
print("Total:", total)

// No return value
func printWelcomeMessage() {
    print("Welcome to Swift")
}

printWelcomeMessage()

// Argument labels — external name vs internal name, `_` omits the label
func send(message text: String, to recipient: String) {
    print("Sending '\(text)' to \(recipient)")
}

func add(_ first: Int, _ second: Int) -> Int {
    return first + second
}

send(message: "Order shipped", to: "Anil")
print(add(10, 20))

// Default parameter
func applyDiscount(to price: Double, percent: Double = 10) -> Double {
    return price - (price * percent / 100)
}

print(applyDiscount(to: 200))               // 180.0
print(applyDiscount(to: 200, percent: 25))  // 150.0

// Variadic parameter — arrives as [Int]
func sumAll(_ values: Int...) -> Int {
    var runningTotal = 0
    for item in values {
        runningTotal += item
    }
    return runningTotal
}

print(sumAll(1, 2, 3, 4))   // 10

// inout — copy-in, copy-out; caller passes with &
func incrementRetry(_ count: inout Int) {
    count += 1
}

var attempts = 0
incrementRetry(&attempts)
incrementRetry(&attempts)
print("Attempts:", attempts)   // 2

//==============================================================
// MARK: - 8. Tuples
//==============================================================

let user = (
    name: "Anil",
    age: 30,
    role: "iOS Developer"
)
print(user.name, user.age, user.role)

// Destructuring
let (name, userAge, role) = user
print(name, userAge, role)

// Returning multiple values
func minMax(of first: Int, _ second: Int) -> (min: Int, max: Int) {
    return first < second ? (first, second) : (second, first)
}

let bounds = minMax(of: 8, 3)
print(bounds.min, bounds.max)

//==============================================================
// MARK: - 9. Strings
//==============================================================

let firstName = "Anil"
let lastName = "Kumar"
let fullName = firstName + " " + lastName
print(fullName)

// Interpolation
let yearsOfExperience = 8
print("I have \(yearsOfExperience) years of experience.")

// Properties
let technology = "Swift"
print(technology.count, technology.isEmpty)

// Indexing — no Int subscripts
// technology[0]   // Does not compile: String is not Int-indexed
let firstCharacter = technology[technology.startIndex]
let thirdIndex = technology.index(technology.startIndex, offsetBy: 2)
let thirdCharacter = technology[thirdIndex]
print(firstCharacter, thirdCharacter)   // S i

// Why: a Character is a grapheme cluster and can be several scalars
let flag = "🇮🇳"
print(flag.count)                  // 1
print(flag.unicodeScalars.count)   // 2

//==============================================================
// MARK: - 10. Arrays
//==============================================================

var languages = ["Swift", "Objective-C", "Dart"]
languages.append("Kotlin")
print(languages)
print(languages[0])
print("Count:", languages.count)

for language in languages {
    print(language)
}

//==============================================================
// MARK: - 11. Sets
//==============================================================

var skills: Set<String> = ["Swift", "SwiftUI", "UIKit"]
skills.insert("Combine")
print(skills)                    // Order not guaranteed
print(skills.contains("Swift"))  // O(1) average lookup

// Duplicates removed automatically
let numbers: Set = [1, 2, 3, 3, 4, 4]
print(numbers)

//==============================================================
// MARK: - 12. Dictionaries
//==============================================================

var developer: [String: String] = [
    "name": "Anil",
    "role": "iOS Developer",
    "language": "Swift"
]

// Lookup returns an Optional
if let developerName = developer["name"] {
    print(developerName)
} else {
    print("Unknown")
}

developer["experience"] = "8 Years"
developer["language"] = nil   // Setting nil removes the key
print(developer)              // Order not guaranteed

for (key, entry) in developer {
    print("\(key): \(entry)")
}

//==============================================================
// MARK: - 13. Ranges
//==============================================================

// Closed range
for number in 1...5 {
    print(number)
}

// Half-open range
for number in 1..<5 {
    print(number)
}

// Partial range — returns an ArraySlice
let numbersArray = [10, 20, 30, 40, 50]
for number in numbersArray[2...] {
    print(number)
}

//==============================================================
// MARK: - 14. Type Casting
//==============================================================

class Employee {
    let name: String

    init(name: String) {
        self.name = name
    }
}

final class IOSDeveloper: Employee {
    let language = "Swift"
}

final class AndroidDeveloper: Employee {
    let language = "Kotlin"
}

let employee: Employee = IOSDeveloper(name: "Anil")

// is — type check
if employee is IOSDeveloper {
    print("Employee is an iOS Developer")
}

// as? — conditional downcast, returns Optional
if let iosEmployee = employee as? IOSDeveloper {
    print("Language:", iosEmployee.language)
}

if employee as? AndroidDeveloper == nil {
    print("Not an Android Developer")
}

// as! — forced downcast, crashes if wrong
let iosDeveloper = employee as! IOSDeveloper
print(iosDeveloper.language)

// as — upcast, guaranteed at compile time
let baseEmployee = iosDeveloper as Employee
print(baseEmployee.name)

// Casting from Any
let anyValue: Any = 42
if let intValue = anyValue as? Int {
    print("Int:", intValue)
}

//==============================================================
// MARK: - 15. Value vs Reference Semantics
//==============================================================

// Value type — copy is independent (copy-on-write for collections)
var originalScores = [1, 2, 3]
var copiedScores = originalScores
copiedScores.append(4)
print(originalScores)   // [1, 2, 3]
print(copiedScores)     // [1, 2, 3, 4]

// Reference type — both constants point to the same instance
final class Cart {
    var itemCount = 0
}

let firstCart = Cart()
let secondCart = firstCart
secondCart.itemCount = 5
print(firstCart.itemCount)   // 5
print(firstCart === secondCart)   // true — same instance

// `let` on a class freezes the reference, not the properties
// firstCart = Cart()   // Does not compile
firstCart.itemCount = 10   // Compiles

//==============================================================
// MARK: - Type Safety Example
//==============================================================

// let invalid: Int = "10"   // Does not compile: Swift is type-safe
let converted = Int("10")    // Int? — conversion can fail
if let converted {
    print("Converted:", converted)
}

//==============================================================
// MARK: - Final Notes
//==============================================================
//
// 1. Prefer `let` unless mutation is required.
// 2. Swift is type-safe: no implicit numeric conversion.
// 3. Integer division truncates.
// 4. `guard` exits early and keeps the unwrapped value in scope.
// 5. `switch` is exhaustive and supports ranges, tuples, and `where`.
// 6. `inout` is copy-in, copy-out, passed with `&`.
// 7. Strings use String.Index because Characters vary in size.
// 8. Arrays are ordered; Sets and Dictionaries are unordered.
// 9. Set lookup is O(1) average; Array search is O(n).
// 10. Collections are value types with copy-on-write.
// 11. `let` on a class instance freezes the reference, not its properties.
// 12. `is` checks, `as?` safely downcasts, `as!` force-downcasts, `as` upcasts.
//
//==============================================================
