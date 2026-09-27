import UIKit

//==============================================================
// MARK: - Notes
//==============================================================
//
// Higher-Order Function (HOF)
// → A function that takes a function/closure as input,
//   or returns one as output.
//
// Why Swift uses them
// → Declarative: say WHAT you want, not HOW to loop.
// → No mutable temp arrays — fewer bugs.
// → Closures + generics make them work on any type.
//
// Core five
// map        → 1 input  → 1 output          (same count)
// filter     → keep elements that pass       (≤ count)
// reduce     → many     → 1 value            (sum, dictionary)
// compactMap → map + drop nil                (≤ count)
// flatMap    → map + flatten one level       ([[T]] → [T])
//
// Performance
// → Each HOF in a chain creates a new array.
// → filter → map = 2 passes, 2 arrays.
// → lazy defers work until a value is requested — no intermediate arrays.
// → reduce(into:) mutates one accumulator — no copy per step.
// → first(where:) / contains(where:) exit early; filter always scans all.
//
// Closures in HOFs are non-escaping
// → Run immediately, can't leak, self can be implicit.
//
// HOF vs for loop
// → HOF: readable, chainable, no mutable state.
// → Loop: early break, multiple results in one pass, hot-path performance.
// → Senior answer: readability by default, loop when profiling says so.
//
// One-liner
// "Higher-order functions take or return closures. They make collection
// code declarative and safe, but chains create intermediate arrays —
// so I reach for lazy or a single loop on large or hot-path data."
//
//==============================================================

//==============================================================
// MARK: - 07. Higher-Order Functions
//==============================================================
// A function that takes or returns another function/closure.

let numbers = [1, 2, 3, 4]
let values = ["10", "20", "Swift", "30"]
let nested = [[1, 2], [3, 4], [5, 6]]

//==============================================================
// MARK: - 1. map
//==============================================================

print("\n========== 01 - map ==========")
let multiplied = numbers.map { $0 * 10 }
print(multiplied) // [10, 20, 30, 40]

//==============================================================
// MARK: - 2. filter
//==============================================================

print("\n========== 02 - filter ==========")
let evenNumbers = numbers.filter { $0 % 2 == 0 }
print(evenNumbers) // [2, 4]

//==============================================================
// MARK: - 3. reduce
//==============================================================

print("\n========== 03 - reduce ==========")
let sum = numbers.reduce(0) { $0 + $1 }
print(sum) // 10

//==============================================================
// MARK: - 4. compactMap
//==============================================================

print("\n========== 04 - compactMap ==========")
let integers = values.compactMap { Int($0) }
print(integers) // [10, 20, 30]
// Swift 4.1: flatMap for dropping nils was renamed to compactMap.

//==============================================================
// MARK: - 5. flatMap
//==============================================================

print("\n========== 05 - flatMap ==========")
let flattened = nested.flatMap { $0 }
print(flattened) // [1, 2, 3, 4, 5, 6]

//==============================================================
// MARK: - 6. Chaining
//==============================================================

print("\n========== 06 - Chaining ==========")
let finalResult = numbers
    .filter { $0 > 1 }
    .map { $0 * 2 }
print(finalResult) // [4, 6, 8]
// filter → map creates 2 arrays. lazy or a single loop creates none.

//==============================================================
// MARK: - 7. Custom map
//==============================================================

extension Array {
    func myMap<T>(_ transform: (Element) -> T) -> [T] {
        var result = [T]()
        for element in self { result.append(transform(element)) }
        return result
    }
}

print("\n========== 07 - Custom map ==========")
print(numbers.myMap { $0 * 2 }) // [2, 4, 6, 8]

//==============================================================
// MARK: - 8. Custom filter
//==============================================================

extension Array {
    func myFilter(_ condition: (Element) -> Bool) -> [Element] {
        var result = [Element]()
        for element in self { if condition(element) { result.append(element) } }
        return result
    }
}

print("\n========== 08 - Custom filter ==========")
print(numbers.myFilter { $0 > 2 }) // [3, 4]

//==============================================================
// MARK: - 9. Custom reduce
//==============================================================

extension Array {
    func myReduce<Result>(_ initialValue: Result, _ combine: (Result, Element) -> Result) -> Result {
        var result = initialValue
        for element in self { result = combine(result, element) }
        return result
    }
}

print("\n========== 09 - Custom reduce ==========")
print(numbers.myReduce(0) { $0 + $1 }) // 10

//==============================================================
// MARK: - 10. Custom compactMap
//==============================================================

extension Array {
    func myCompactMap<T>(_ transform: (Element) -> T?) -> [T] {
        var result = [T]()
        for element in self { if let value = transform(element) { result.append(value) } }
        return result
    }
}

print("\n========== 10 - Custom compactMap ==========")
print(values.myCompactMap { Int($0) }) // [10, 20, 30]

//==============================================================
// MARK: - 11. Custom flatMap
//==============================================================

extension Array {
    func myFlatMap<T>(_ transform: (Element) -> [T]) -> [T] {
        var result = [T]()
        for element in self { result.append(contentsOf: transform(element)) }
        return result
    }
}

print("\n========== 11 - Custom flatMap ==========")
print(nested.myFlatMap { $0 }) // [1, 2, 3, 4, 5, 6]

//==============================================================
// MARK: - 12. reduce(into:)
//==============================================================
// Mutates one accumulator — no copy per step. Best for building collections.

print("\n========== 12 - reduce(into:) ==========")
let frequency = "hello".reduce(into: [Character: Int]()) { $0[$1, default: 0] += 1 }
print(frequency["l"] as Any) // Optional(2)

//==============================================================
// MARK: - 13. forEach
//==============================================================
// return skips only the current element. break / continue ❌

print("\n========== 13 - forEach ==========")
numbers.forEach { number in
    if number == 2 { return }
    print(number) // 1 3 4
}

//==============================================================
// MARK: - 14. lazy
//==============================================================
// Work happens only when a value is needed.

print("\n========== 14 - lazy ==========")
let firstLarge = numbers.lazy
    .map { number -> Int in
        print("mapping", number)
        return number * 10
    }
    .first { $0 > 15 }
print(firstLarge as Any) // mapping 1, mapping 2 → Optional(20)

//==============================================================
// MARK: - 15. sorted(by:)
//==============================================================

struct Product {
    let name: String
    let price: Int
}

let products = [Product(name: "Shoes", price: 50), Product(name: "Cap", price: 20), Product(name: "Bag", price: 50)]

print("\n========== 15 - sorted(by:) ==========")
let byPrice = products.sorted { $0.price < $1.price }
print(byPrice.map { $0.name }) // Cap first — tie order not guaranteed
let byPriceThenName = products.sorted { $0.price == $1.price ? $0.name < $1.name : $0.price < $1.price }
print(byPriceThenName.map { $0.name }) // ["Cap", "Bag", "Shoes"]

//==============================================================
// MARK: - 16. first(where:), contains(where:), allSatisfy
//==============================================================
// Stop at the first match. filter { }.first scans everything.

print("\n========== 16 - first(where:), contains(where:), allSatisfy ==========")
print(numbers.first { $0 > 2 } as Any)  // Optional(3)
print(numbers.contains { $0 > 3 })      // true
print(numbers.allSatisfy { $0 > 0 })    // true

//==============================================================
// MARK: - 17. mapValues, compactMapValues
//==============================================================

print("\n========== 17 - mapValues, compactMapValues ==========")
let prices = ["Shoes": "49", "Cap": "free"]
print(prices.compactMapValues { Int($0) }) // ["Shoes": 49]
let stock = ["Shoes": 2]
print(stock.mapValues { $0 > 0 })          // ["Shoes": true]

//==============================================================
// MARK: - Quick Revision
//==============================================================
//
// map        → Transform
// filter     → Select
// reduce     → Combine
// compactMap → Transform + Remove nil
// flatMap    → Transform + Flatten
// reduce(into:) → Combine without copying
// lazy       → Deferred work
// first(where:) / contains(where:) → Early exit
//

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a higher-order function?
// 2. map vs compactMap vs flatMap?
// 3. reduce vs reduce(into:) — which is faster, and why?
// 4. Can you break out of forEach? What does return do inside it?
// 5. What does lazy do, and when would you use it?
// 6. How many arrays does filter → map create?
// 7. HOF vs manual loop — readability vs performance?
// 8. Implement map / filter / reduce yourself.
//
//==============================================================
