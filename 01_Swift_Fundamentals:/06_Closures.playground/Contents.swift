import UIKit

//==============================================================
// MARK: - 01. Basic Closure
//==============================================================
//
// A closure is a self-contained block of executable code without
// a function name. It can be stored in a variable and executed later.
//

let greet = {
    print("Hello from Closure")
}

greet()

// Output:
// Hello from Closure


//==============================================================
// MARK: - 02. Closure with Parameters
//==============================================================
//
// Closures can accept parameters just like functions.
//

let greetUser = { (name: String) in
    print("Hello \(name)")
}

greetUser("Anil")

// Output:
// Hello Anil


//==============================================================
// MARK: - 03. Closure with Return Value
//==============================================================
//
// A closure can return a value.
//

let addNumbers = { (a: Int, b: Int) -> Int in
    return a + b
}

let result = addNumbers(10, 20)

print("Result:", result)

// Output:
// Result: 30


//==============================================================
// MARK: - 04. Closure Type
//==============================================================
//
// A closure type describes its input parameters and return value.
//

let operation: (Int, Int) -> Int = { a, b in
    return a * b
}

print("Operation:", operation(5, 4))

// Output:
// Operation: 20


//==============================================================
// MARK: - 05. Passing Closure as Parameter
//==============================================================
//
// Closures can be passed into functions as parameters.
//

func performOperation(
    _ a: Int,
    _ b: Int,
    operation: (Int, Int) -> Int
) {
    let result = operation(a, b)
    print("Result:", result)
}

performOperation(10, 20) { a, b in
    a + b
}

// Output:
// Result: 30


//==============================================================
// MARK: - 06. Non-Escaping Closure
//==============================================================
//
// Closure parameters are non-escaping by default.
// A non-escaping closure cannot outlive the function call.
//

func performTask(completion: () -> Void) {

    print("Start")

    completion()

    print("End")
}

performTask {
    print("Completion")
}

// Output:
// Start
// Completion
// End


//==============================================================
// MARK: - 07. Non-Escaping Closure Does Not Mean Immediate
//==============================================================
//
// Non-escaping means the closure cannot outlive the function call.
// It does NOT mean the closure must execute immediately.
//

func processTask(completion: () -> Void) {

    print("Before")

    for _ in 1...2 {
        print("Working")
    }

    completion()

    print("After")
}

processTask {
    print("Closure Executed")
}

// Output:
// Before
// Working
// Working
// Closure Executed
// After


//==============================================================
// MARK: - 08. Escaping Closure
//==============================================================
//
// @escaping means the closure may outlive the function call.
// It can be stored and executed later.
//

var storedClosure: (() -> Void)?

@MainActor func saveClosure(completion: @escaping () -> Void) {

    storedClosure = completion

    print("Closure Stored")
}

saveClosure {
    print("Closure Executed Later")
}

print("Function Finished")

storedClosure?()

// Output:
// Closure Stored
// Function Finished
// Closure Executed Later


//==============================================================
// MARK: - 09. Escaping Closure with DispatchQueue
//==============================================================
//
// DispatchQueue commonly uses escaping closures because the closure
// executes after the current function returns.
//

func performAsyncTask(completion: @escaping @Sendable () -> Void) {

    print("Start")

    DispatchQueue.main.async {

        print("Async Work")

        completion()
    }

    print("End")
}

performAsyncTask {
    print("Completion")
}

// Typical output:
// Start
// End
// Async Work
// Completion


//==============================================================
// MARK: - 10. Multiple Closure Parameters
//==============================================================
//
// A function can accept multiple closures.
//

func fetchData(
    success: () -> Void,
    failure: () -> Void
) {
    let isSuccess = true

    if isSuccess {
        success()
    } else {
        failure()
    }
}

fetchData(
    success: {
        print("Success")
    },
    failure: {
        print("Failure")
    }
)

// Output:
// Success


//==============================================================
// MARK: - 11. Trailing Closure
//==============================================================
//
// When the last parameter is a closure, Swift allows the closure
// to be written outside the function call parentheses.
//

func executeTask(completion: () -> Void) {
    completion()
}

executeTask {
    print("Task Completed")
}

// Output:
// Task Completed


//==============================================================
// MARK: - 12. Trailing Closure with Parameters
//==============================================================
//
// Trailing closure syntax also works when the closure has parameters.
//

func calculate(
    _ a: Int,
    _ b: Int,
    operation: (Int, Int) -> Int
) -> Int {
    return operation(a, b)
}

let sum = calculate(10, 20) { a, b in
    a + b
}

print("Sum:", sum)

// Output:
// Sum: 30


//==============================================================
// MARK: - 13. @autoclosure
//==============================================================
//
// @autoclosure automatically converts an expression into a closure.
// It delays evaluation until the closure is executed.
//

func printValue(_ value: @autoclosure () -> Int) {

    print("Value:", value())
}

printValue(10 + 20)

// Output:
// Value: 30


//==============================================================
// MARK: - 14. @autoclosure Delays Evaluation
//==============================================================
//
// The expression passed to @autoclosure is not evaluated immediately.
//

func checkValue(_ value: @autoclosure () -> Bool) {

    print("Before Evaluation")

    if value() {
        print("Value is true")
    }

    print("After Evaluation")
}

checkValue(10 > 5)

// Output:
// Before Evaluation
// Value is true
// After Evaluation


//==============================================================
// MARK: - 15. Capturing Values
//==============================================================
//
// Closures can capture variables from their surrounding scope.
//

var number = 100

let printNumber = {
    print("Number:", number)
}

number = 200

printNumber()

// Output:
// Number: 200


//==============================================================
// MARK: - 16. Capture List
//==============================================================
//
// A capture list controls how values are captured by a closure.
// [value] captures the current value when the closure is created.
//

var capturedNumber = 100

let capturedClosure = { [capturedNumber] in

    print("Captured Number:", capturedNumber)
}

capturedNumber = 200

capturedClosure()

// Output:
// Captured Number: 100


//==============================================================
// MARK: - 17. Normal Capture vs Capture List
//==============================================================

var normalNumber = 100

let normalClosure = {
    print("Normal:", normalNumber)
}

let snapshotClosure = { [normalNumber] in
    print("Snapshot:", normalNumber)
}

normalNumber = 500

normalClosure()
snapshotClosure()

// Output:
// Normal: 500
// Snapshot: 100


//==============================================================
// MARK: - 18. Capturing Mutable State
//==============================================================
//
// A closure can capture mutable variables and modify their state.
//

func makeCounter() -> () -> Int {

    var count = 0

    return {
        count += 1
        return count
    }
}

let counter = makeCounter()

print(counter())
print(counter())
print(counter())

// Output:
// 1
// 2
// 3


//==============================================================
// MARK: - 19. Separate Closure State
//==============================================================
//
// Each invocation of makeCounter() creates independent captured state.
//

let counterOne = makeCounter()
let counterTwo = makeCounter()

print("Counter One:", counterOne())
print("Counter One:", counterOne())

print("Counter Two:", counterTwo())

// Output:
// Counter One: 1
// Counter One: 2
// Counter Two: 1


//==============================================================
// MARK: - 20. Returning a Closure
//==============================================================
//
// A function can return a closure.
// The returned closure can preserve captured state.
//

func createGreeting() -> () -> Void {

    let message = "Hello from returned closure"

    return {
        print(message)
    }
}

let greetingClosure = createGreeting()

greetingClosure()

// Output:
// Hello from returned closure


//==============================================================
// MARK: - 21. Closure Capturing Class Reference
//==============================================================
//
// When a closure captures a class instance, it captures the reference.
// It does not create a deep copy of the object.
//

final class User {

    var name = "Anil"
}

let user = User()

let userClosure = {
    print("User:", user.name)
}

user.name = "Kumar"

userClosure()

// Output:
// User: Kumar


//==============================================================
// MARK: - 22. Capture List with Class Reference
//==============================================================
//
// [user] captures the current reference to the User object.
// It does NOT copy the User object.
//

let anotherUser = User()

let userSnapshotClosure = { [anotherUser] in
    print("User:", anotherUser.name)
}

anotherUser.name = "Kumar"

userSnapshotClosure()

// Output:
// User: Kumar


//==============================================================
// MARK: - 23. Stored Closure
//==============================================================
//
// An escaping closure can be stored in a property or variable
// and executed later.
//

final class TaskManager {

    var completion: (() -> Void)?

    func start(completion: @escaping () -> Void) {

        self.completion = completion

        print("Task Started")
    }

    func finish() {

        completion?()
    }
}

let manager = TaskManager()

manager.start {
    print("Task Completed")
}

manager.finish()

// Output:
// Task Started
// Task Completed


//==============================================================
// MARK: - 24. Closure as a Property
//==============================================================
//
// Closures can be stored as properties and used as callbacks.
//

final class NetworkManager {

    var onSuccess: (() -> Void)?

    func simulateRequest() {

        print("Request Started")

        onSuccess?()
    }
}

let networkManager = NetworkManager()

networkManager.onSuccess = {
    print("Request Successful")
}

networkManager.simulateRequest()

// Output:
// Request Started
// Request Successful


//==============================================================
// MARK: - 25. Weak Self Awareness
//==============================================================
//
// A closure can strongly capture self.
// [weak self] makes the captured reference weak.
// Deep retain-cycle analysis belongs in the ARC phase.
//

final class ViewModel {

    var onComplete: (() -> Void)?

    func start() {

        onComplete = { [weak self] in

            guard let self else { return }

            print("Completed:", self)
        }
    }
}

let viewModel = ViewModel()

viewModel.start()

viewModel.onComplete?()

// Output:
// Completed: <ViewModel instance>


//==============================================================
// MARK: - 26. @Sendable Closure
//==============================================================
//
// @Sendable marks a closure as safe to transfer across concurrency
// domains. Detailed Sendable rules belong in Swift Concurrency.
//

let sendableClosure: @Sendable () -> Void = {
    print("Sendable Closure")
}

sendableClosure()

// Output:
// Sendable Closure


//==============================================================
// MARK: - 27. Closure Shorthand Arguments
//==============================================================
//
// Swift provides shorthand argument names such as $0, $1, etc.
//

let numbers = [1, 2, 3, 4, 5]

let doubled = numbers.map {
    $0 * 2
}

print("Doubled:", doubled)

// Output:
// Doubled: [2, 4, 6, 8, 10]


//==============================================================
// MARK: - 28. Closure Type Alias
//==============================================================
//
// Typealiases can make complex closure types easier to read.
//

typealias CompletionHandler = () -> Void

func loadData(completion: @escaping CompletionHandler) {

    print("Loading Data")

    completion()
}

loadData {
    print("Data Loaded")
}

// Output:
// Loading Data
// Data Loaded


//==============================================================
// MARK: - 29. Closure with Optional
//==============================================================
//
// Closure properties can be optional when a callback is not required.
//

var completionHandler: (() -> Void)?

completionHandler = {
    print("Completed")
}

completionHandler?()

// Output:
// Completed


//==============================================================
// MARK: - 30. Closure as a Dependency
//==============================================================
//
// Injecting behavior through closures can reduce coupling and improve
// testability for small pieces of behavior.
//

func performCalculation(
    value: Int,
    calculator: (Int) -> Int
) -> Int {

    return calculator(value)
}

let calculatedValue = performCalculation(value: 10) {
    $0 * 5
}

print("Calculated:", calculatedValue)

// Output:
// Calculated: 50


//==============================================================
// MARK: - 31. Higher-Order Functions
//==============================================================
//
// Functions that accept or return functions/closures are called
// higher-order functions.
//

let values = [1, 2, 3, 4, 5]

let filtered = values.filter {
    $0 % 2 == 0
}

let mapped = values.map {
    $0 * 10
}

let total = values.reduce(0) {
    $0 + $1
}

print("Filtered:", filtered)
print("Mapped:", mapped)
print("Total:", total)

// Output:
// Filtered: [2, 4]
// Mapped: [10, 20, 30, 40, 50]
// Total: 15


//==============================================================
// MARK: - 32. Closure Concept Quick Revision
//==============================================================
//
// Closure:
// Self-contained executable code without a function name.
//
// Non-Escaping:
// Cannot outlive the function call.
//
// @escaping:
// Can outlive the function call.
//
// Capture:
// Closure can access values from its surrounding scope.
//
// Capture List:
// Controls how values are captured.
//
// [weak self]:
// Weakly captures self and avoids a strong reference from the closure.
//
// @autoclosure:
// Automatically converts an expression into a closure and delays evaluation.
//
// Trailing Closure:
// Syntax that allows the final closure argument to be written outside
// the function call parentheses.
//
// Higher-Order Function:
// A function that accepts or returns another function/closure.


//==============================================================
// MARK: - 33. Senior Interview One-Liners
//==============================================================
//
// 1. What is a closure?
// A self-contained block of executable code that can be stored,
// passed, returned, and capture surrounding values.
//
// 2. Are closures escaping by default?
// No. Closure parameters are non-escaping by default.
//
// 3. What does @escaping mean?
// It means the closure may outlive the function call.
//
// 4. Does @escaping automatically create a retain cycle?
// No. A retain cycle requires strong references forming a cycle.
//
// 5. What does a capture list do?
// It explicitly controls how values are captured by a closure.
//
// 6. What is [weak self]?
// It captures self weakly so the closure does not strongly retain self.
//
// 7. What is @autoclosure?
// It automatically wraps an expression in a closure and delays evaluation.
//
// 8. What is a trailing closure?
// It is syntax for writing the final closure argument outside the
// function call parentheses.
//
// 9. Can a closure capture mutable state?
// Yes. A closure can preserve and modify captured mutable state.
//
// 10. Does capturing a class instance copy the object?
// No. The closure captures the reference to the class instance.
