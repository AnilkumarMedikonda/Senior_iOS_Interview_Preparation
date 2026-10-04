import Foundation


// MARK: - Q01. map

print("\n========== Q01 - map ==========")

let q1Numbers = [1, 2, 3, 4, 5]

let q1Doubled = q1Numbers.map { $0 * 2 }

// ▶️ Run
print(q1Doubled)


// MARK: - Q02. filter

print("\n========== Q02 - filter ==========")

let q2Numbers = [1, 2, 3, 4, 5]

let q2Evens = q2Numbers.filter { $0 % 2 == 0 }

// ▶️ Run
print(q2Evens)


// MARK: - Q03. reduce (Sum + Product)

print("\n========== Q03 - reduce (Sum + Product) ==========")

let q3Numbers = [1, 2, 3, 4, 5]

let q3Sum = q3Numbers.reduce(0, +)

let q3Product = q3Numbers.reduce(1) { $0 * $1 }

// ▶️ Run
print(q3Sum, q3Product)


// MARK: - Q04. compactMap

print("\n========== Q04 - compactMap ==========")

let q4Strings = ["1", "two", "3", "four", "5"]

let q4Ints = q4Strings.compactMap { Int($0) }

// ▶️ Run
print(q4Ints)


// MARK: - Q05. map vs compactMap

print("\n========== Q05 - map vs compactMap ==========")

let q5Strings = ["1", "two", "3", "four", "5"]

let q5Mapped = q5Strings.map { Int($0) }

// ▶️ Run
print(q5Mapped)


// MARK: - Q06. flatMap

print("\n========== Q06 - flatMap ==========")

let q6Nested = [[1, 2], [3], [4, 5]]

let q6Flat = q6Nested.flatMap { $0 }

// ▶️ Run
print(q6Flat)


// MARK: - Q07. Chaining

print("\n========== Q07 - Chaining ==========")

let q7Numbers = [1, 2, 3, 4, 5]

let q7Result = q7Numbers
    .filter { $0 > 2 }
    .map { $0 * 10 }
    .reduce(0, +)

// ▶️ Run
print(q7Result)


// MARK: - Q08. sorted() vs Original

print("\n========== Q08 - sorted() vs Original ==========")

let q8Names = ["Ravi", "Anil", "Kiran"]

// ▶️ Run
q8Names.sorted().forEach { print($0) }

print(q8Names)


// MARK: - Q09. sort() Mutates

print("\n========== Q09 - sort() Mutates ==========")

var q9Names = ["Ravi", "Anil", "Kiran"]

q9Names.sort()

// ▶️ Run
print(q9Names)


// MARK: - Q10. sorted(by:)

print("\n========== Q10 - sorted(by:) ==========")

let q10Numbers = [5, 2, 8, 1]

let q10Descending = q10Numbers.sorted(by: >)

// ▶️ Run
print(q10Descending)


// MARK: - Q11. first(where:) + contains(where:)

print("\n========== Q11 - first(where:) + contains(where:) ==========")

let q11Numbers = [5, 2, 8, 1]

let q11First = q11Numbers.first(where: { $0 > 4 })

let q11HasBig = q11Numbers.contains(where: { $0 > 7 })

// ▶️ Run
print(q11First as Any)

print(q11HasBig)


// MARK: - Q12. reduce(into:) — Count Dictionary

print("\n========== Q12 - reduce(into:) — Count Dictionary ==========")

let q12Letters = ["a", "b", "a", "c", "a", "b"]

let q12Counts = q12Letters.reduce(into: [String: Int]()) { result, letter in
    if let current = result[letter] {
        result[letter] = current + 1
    } else {
        result[letter] = 1
    }
}

// ▶️ Run
print(q12Counts["a"] as Any, q12Counts["b"] as Any, q12Counts["c"] as Any)


// MARK: - Q13. return Inside forEach

print("\n========== Q13 - return Inside forEach ==========")

let q13Numbers = [1, 2, 3, 4]

// ▶️ Run
q13Numbers.forEach { number in
    if number == 2 { return }
    print(number)
}


// MARK: - Q14. lazy

print("\n========== Q14 - lazy ==========")

let q14Numbers = [1, 2, 3, 4, 5]

let q14Lazy = q14Numbers.lazy.map { number -> Int in
    print("Mapping", number)
    return number * 10
}

// ▶️ Run
print(q14Lazy.first as Any)
