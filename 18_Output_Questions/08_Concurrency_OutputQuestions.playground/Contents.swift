import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true


// MARK: - Q01. main.async Order

print("\n========== Q01 - main.async Order ==========")

// ▶️ Run
print("1")

DispatchQueue.main.async {
    print("2")
}

print("3")


// MARK: - Q02. sync on Another Serial Queue

print("\n========== Q02 - sync on Another Serial Queue ==========")

let q2Queue = DispatchQueue(label: "q2.serial")

// ▶️ Run
print("1")

q2Queue.sync {
    print("2")
}

print("3")


// MARK: - Q03. main.sync on Main (Deadlock)

print("\n========== Q03 - main.sync on Main (Deadlock) ==========")

// ❓ What happens? (kept commented — it crashes the playground)
// print("1")
// DispatchQueue.main.sync {
//     print("2")
// }
// print("3")


// MARK: - Q04. global + main

print("\n========== Q04 - global + main ==========")

// ▶️ Run
print("1")

DispatchQueue.global().async {
    print("2")
    DispatchQueue.main.async {
        print("3")
    }
}

print("4")


// MARK: - Q05. Serial Queue async + Main

print("\n========== Q05 - Serial Queue async + Main ==========")

let q5Serial = DispatchQueue(label: "q5.serial")

// ▶️ Run
q5Serial.async { print("A") }

q5Serial.async { print("B") }

q5Serial.async { print("C") }

print("D")


// MARK: - Q06. Concurrent Queue Order

print("\n========== Q06 - Concurrent Queue Order ==========")

let q6Concurrent = DispatchQueue(label: "q6.concurrent", attributes: .concurrent)

// ▶️ Run
q6Concurrent.async { print("A") }

q6Concurrent.async { print("B") }

q6Concurrent.async { print("C") }


// MARK: - Q07. Race Condition

print("\n========== Q07 - Race Condition ==========")

final class Q7Box: @unchecked Sendable {
    var count = 0
}

let q7Box = Q7Box()

let q7Group = DispatchGroup()

// ▶️ Run
for _ in 1...1000 {
    DispatchQueue.global().async(group: q7Group) {
        q7Box.count += 1
    }
}

q7Group.wait()

print("Count:", q7Box.count)


// MARK: - Q08. Task Order on Main Actor

print("\n========== Q08 - Task Order on Main Actor ==========")

func q8Fetch() async -> String {
    print("2")
    return "Data"
}

// ▶️ Run
Task {
    print("1")
    let result = await q8Fetch()
    print("3", result)
}

print("4")


// MARK: - Q09. async let (Parallel)

print("\n========== Q09 - async let (Parallel) ==========")

func q9Load(_ name: String, seconds: UInt64) async -> String {
    try? await Task.sleep(nanoseconds: seconds * 1_000_000_000)
    print("Loaded", name)
    return name
}

// ▶️ Run
Task {
    async let a = q9Load("A", seconds: 2)
    async let b = q9Load("B", seconds: 1)
    let results = await [a, b]
    print(results)
}


// MARK: - Q10. Actor + TaskGroup

print("\n========== Q10 - Actor + TaskGroup ==========")

actor Q10Counter {
    var value = 0
    func increment() { value += 1 }
}

let q10Counter = Q10Counter()

// ▶️ Run
Task {
    await withTaskGroup(of: Void.self) { group in
        for _ in 1...1000 {
            group.addTask { await q10Counter.increment() }
        }
    }
    print("Value:", await q10Counter.value)
}


// MARK: - Q11. Cancellation Without Check

print("\n========== Q11 - Cancellation Without Check ==========")

// ▶️ Run
let q11Task = Task {
    for i in 1...3 {
        print("Step", i)
    }
}

q11Task.cancel()


// MARK: - Q12. Cancellation With Check

print("\n========== Q12 - Cancellation With Check ==========")

// ▶️ Run
let q12Task = Task {
    for i in 1...3 {
        if Task.isCancelled { break }
        print("Step", i)
    }
    print("Task finished")
}

q12Task.cancel()


// MARK: - Q13. Actor Reentrancy

print("\n========== Q13 - Actor Reentrancy ==========")

actor Q13Counter {
    var value = 0

    func incrementTwice() async {
        let current = value
        await Task.yield()
        value = current + 2
    }
}

let q13Counter = Q13Counter()

// ▶️ Run
Task {
    async let first: Void = q13Counter.incrementTwice()
    async let second: Void = q13Counter.incrementTwice()
    _ = await (first, second)
    print("Value:", await q13Counter.value)
}
