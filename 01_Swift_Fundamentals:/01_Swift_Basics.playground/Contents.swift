import Foundation

//==============================================================
// MARK: - 01. Swift Basics
//==============================================================

//==============================================================
// MARK: - 1. let vs var
//==============================================================

print("\n========== 01 - let vs var ==========")
let appName = "Skechers"
var retryCount = 0
retryCount += 1
print(appName, retryCount)   // Skechers 1
// appName = "Other"         ❌ let cannot be reassigned

//==============================================================
// MARK: - 2. Type Safety and Inference
//==============================================================
// Type inferred at compile time. No implicit numeric conversion.

print("\n========== 02 - Type Safety and Inference ==========")
let count = 10               // Int
let price = 10.5             // Double, not Float
print(type(of: count), type(of: price))
// let total = count + price       ❌ Int + Double
let total = Double(count) + price
print(total)                 // 20.5
print(10 / 3, 10 % 3)        // 3 1 — integer division truncates
let converted = Int("10")    // Int? — conversion can fail
print(converted as Any)      // Optional(10)

//==============================================================
// MARK: - 3. guard vs if let
//==============================================================
// guard → early exit, value stays in scope | if let → value scoped to braces

func formatPrice(_ price: Double?) -> String {
    guard let price else { return "Price unavailable" }
    return "$\(price)"
}

print("\n========== 03 - guard vs if let ==========")
print(formatPrice(49.99))   // $49.99
print(formatPrice(nil))     // Price unavailable

//==============================================================
// MARK: - 4. switch
//==============================================================
// Exhaustive, no implicit fallthrough, matches ranges / tuples / where.

print("\n========== 04 - switch ==========")
let statusCode = 503
switch statusCode {
case 200..<300: print("Success")
case 400..<500: print("Client Error")
case 500..<600: print("Server Error")   // ✅
default: print("Unknown")
}

let point = (x: 3, y: 3)
switch point {
case (0, 0): print("Origin")
case (0, _): print("On Y-axis")
case let (x, y) where x == y: print("Diagonal", x, y)   // ✅
default: print("Elsewhere")
}

//==============================================================
// MARK: - 5. Functions
//==============================================================

func send(message text: String, to recipient: String) {   // external vs internal label
    print("'\(text)' → \(recipient)")
}

func applyDiscount(to price: Double, percent: Double = 10) -> Double {   // default
    return price - (price * percent / 100)
}

func sumAll(_ values: Int...) -> Int {   // variadic → [Int]
    var runningTotal = 0
    for value in values {
        runningTotal += value
    }
    return runningTotal
}

func incrementRetry(_ value: inout Int) {   // copy-in, copy-out
    value += 1
}

print("\n========== 05 - Functions ==========")
send(message: "Order shipped", to: "Anil")
print(applyDiscount(to: 200))   // 180.0
print(sumAll(1, 2, 3))          // 6
var attempts = 0
incrementRetry(&attempts)
print(attempts)                 // 1

//==============================================================
// MARK: - 6. Strings
//==============================================================
// No Int subscripts — a Character is a grapheme cluster of variable size.

print("\n========== 06 - Strings ==========")
let technology = "Swift"
// technology[0]   ❌
let thirdIndex = technology.index(technology.startIndex, offsetBy: 2)
print(technology[thirdIndex])        // i
let flag = "🇮🇳"
print(flag.count)                    // 1 Character
print(flag.unicodeScalars.count)     // 2 scalars

//==============================================================
// MARK: - 7. Collections
//==============================================================
// Array → ordered, contains O(n)
// Set → unordered, unique, contains O(1)
// Dictionary → unordered, lookup O(1), returns Optional
// All are value types with copy-on-write.

print("\n========== 07 - Collections ==========")
var languages = ["Swift", "Dart"]
languages.append("Kotlin")
print(languages)                     // ["Swift", "Dart", "Kotlin"]
let skills: Set = ["Swift", "UIKit", "Swift"]
print(skills.count)                  // 2 — duplicates removed
var developer = ["name": "Anil"]
if let name = developer["name"] {
    print(name)                      // Anil
}
developer["name"] = nil              // Removes the key
print(developer.isEmpty)             // true

//==============================================================
// MARK: - 8. Ranges and ArraySlice
//==============================================================

print("\n========== 08 - Ranges and ArraySlice ==========")
let numbers = [10, 20, 30, 40, 50]
let slice = numbers[2...]            // ArraySlice — shares storage and indices
print(slice.startIndex)              // 2, not 0
print(Array(slice))                  // [30, 40, 50] — copy before storing

//==============================================================
// MARK: - 9. Type Casting
//==============================================================
// is → check | as → upcast | as? → safe downcast | as! → force downcast

class Employee {}
final class IOSDeveloper: Employee {
    let language = "Swift"
}

print("\n========== 09 - Type Casting ==========")
let employee: Employee = IOSDeveloper()
print(employee is IOSDeveloper)                       // true
if let developer = employee as? IOSDeveloper {
    print(developer.language)                         // Swift
}
let forced = employee as! IOSDeveloper                // Crashes if wrong
let base = forced as Employee                         // Upcast, compile-time safe
print(type(of: base))                                 // IOSDeveloper

//==============================================================
// MARK: - Interview Questions
//==============================================================
// 1. let on a struct vs let on a class?
// 2. Why doesn't Int + Double compile?
// 3. guard vs if let?
// 4. Why must switch be exhaustive? Does it fall through?
// 5. How does inout work?
// 6. Why can't you subscript a String with an Int?
// 7. Array vs Set vs Dictionary — ordering and complexity?
// 8. Why does ArraySlice not start at index 0?
// 9. is vs as vs as? vs as!? When is as! acceptable?
//==============================================================
