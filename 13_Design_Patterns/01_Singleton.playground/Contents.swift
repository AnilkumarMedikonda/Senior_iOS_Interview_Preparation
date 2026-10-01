import Foundation

// ============================================================
// MARK: - SINGLETON
// ============================================================

/*
 Singleton Pattern

 Definition:
 A Singleton guarantees that a type has one shared instance
 and provides a global access point to that instance.

 Basic Swift syntax:

 final class SomeManager {

     static let shared = SomeManager()

     private init() {}
 }

 Why private init?

 It prevents other code from creating another instance.

 Example:

 let first = SomeManager.shared
 let second = SomeManager.shared

 first and second refer to the same instance.
*/


// ============================================================
// MARK: - 1. Basic Singleton
// ============================================================

// Sendable: no mutable state → safe to share across threads (Swift 6)
final class AnalyticsManager: Sendable {

    static let shared = AnalyticsManager()

    private init() {}

    func track(event: String) {
        print("Analytics: \(event)")
    }
}


// ============================================================
// MARK: - 2. Using Singleton
// ============================================================

AnalyticsManager.shared.track(
    event: "Product Viewed"
)

AnalyticsManager.shared.track(
    event: "Add To Cart"
)


// ============================================================
// MARK: - 3. Same Instance
// ============================================================

let manager1 = AnalyticsManager.shared
let manager2 = AnalyticsManager.shared

print(
    "DEBUG Q01 - Same instance:",
    manager1 === manager2
)


// ============================================================
// MARK: - 4. Why private init?
// ============================================================

/*
 Without private init:

 let manager = AnalyticsManager()

 Multiple objects could be created.

 Singleton prevents this by:

 private init() {}

 Only the class itself can create the instance.
*/

// let another = AnalyticsManager()   ❌ 'init' is inaccessible due to 'private' protection level


// ============================================================
// MARK: - 5. Real iOS Examples
// ============================================================

/*
 Common iOS shared instances:

 URLSession.shared
 FileManager.default
 UserDefaults.standard
 NotificationCenter.default

 Example:
*/

let session = URLSession.shared
let fileManager = FileManager.default
let defaults = UserDefaults.standard

print("DEBUG Q02 - Shared objects created")


// ============================================================
// MARK: - 6. Singleton with State
// ============================================================

// Mutable shared state is NOT thread-safe by default.
// @MainActor → all reads/writes happen on the main thread (Swift 6 safe).
@MainActor
final class AppConfiguration {

    static let shared = AppConfiguration()

    private init() {}

    var environment = "Production"
    var appVersion = "1.0"
}

AppConfiguration.shared.environment = "Development"

print(
    "DEBUG Q03 - Environment:",
    AppConfiguration.shared.environment
)


// ============================================================
// MARK: - 7. Struct Singleton vs Class Singleton
// ============================================================

/*
 Singleton = ONE shared instance.

 class  → reference type → everyone gets the SAME object
 struct → value type     → every assignment makes a COPY

 So a "struct singleton" quietly stops being single.
*/

// ❌ Struct "singleton" — copies break it
struct SettingsStruct {

    @MainActor static var shared = SettingsStruct()   // must be var to mutate

    var theme = "Light"
}

SettingsStruct.shared.theme = "Dark"

var structCopy = SettingsStruct.shared                // ← a COPY, not the same instance

structCopy.theme = "Blue"

print("DEBUG Q04 - Struct shared theme:", SettingsStruct.shared.theme)   // Dark — copy changed, shared didn't


// ✅ Class singleton — one real instance
@MainActor
final class SettingsClass {

    static let shared = SettingsClass()               // let is enough: the reference never changes

    private init() {}

    var theme = "Light"
}

let classRef = SettingsClass.shared                   // same object, not a copy

classRef.theme = "Blue"

print("DEBUG Q05 - Class shared theme:", SettingsClass.shared.theme)     // Blue — same instance

print("DEBUG Q06 - Same object:", classRef === SettingsClass.shared)     // true (=== only works on classes)


// ✅ Only constants? Use a caseless enum — no instance at all
enum AppConstants {

    static let baseURL = "https://api.shop.com"

    static let timeout = 30.0
}

print("DEBUG Q07 - Base URL:", AppConstants.baseURL)


/*
 ┌────────────────────┬──────────────────────────┬────────────────────────────┐
 │                    │ class singleton ✅        │ struct "singleton" ❌       │
 ├────────────────────┼──────────────────────────┼────────────────────────────┤
 │ Semantics          │ Reference — one object   │ Value — copied on assign   │
 │ Shared state       │ Seen everywhere          │ Copies drift apart         │
 │ private init()     │ Stops other instances    │ Doesn't stop copies        │
 │ Identity (===)     │ Yes                      │ No                         │
 │ static property    │ let shared               │ var shared (to mutate)     │
 │ Inheritance / @objc│ Yes                      │ No                         │
 └────────────────────┴──────────────────────────┴────────────────────────────┘

 Which one is better?

 → Shared state or behaviour        → final class + static let shared + private init()
 → Only constants, no state         → caseless enum (namespace)
 → struct singleton                 → avoid — value semantics defeat the "one instance" idea
*/


// ============================================================
// MARK: - 8. Singleton Problem
// ============================================================

/*
 Singleton creates global state.

 Example:

 Screen A changes:

 AppConfiguration.shared.environment = "Test"

 Screen B can now see that changed value.

 This can make code harder to understand because
 dependencies are not explicit.
*/


// ============================================================
// MARK: - 9. Singleton vs Dependency Injection
// ============================================================

/*
 Singleton:

 ViewModel
     ↓
 APIManager.shared

 Dependency Injection:

 ViewModel
     ↓
 APIManager (injected)

 DI is generally easier to test because we can provide
 a mock implementation.

 ViewModel depends on the protocol instead of a global
 Singleton.
*/

protocol AnalyticsTracking {
    func track(event: String)
}

extension AnalyticsManager: AnalyticsTracking {}            // real singleton fits the protocol

final class MockAnalytics: AnalyticsTracking {

    private(set) var events: [String] = []

    func track(event: String) {
        events.append(event)                                 // record instead of sending
    }
}

final class ProductViewModel {

    private let analytics: AnalyticsTracking

    // Default = the singleton → app code stays simple.
    // Tests pass a mock → no global dependency.
    init(analytics: AnalyticsTracking = AnalyticsManager.shared) {
        self.analytics = analytics
    }

    func addToCart() {
        analytics.track(event: "Add To Cart")
    }
}

let appViewModel = ProductViewModel()                        // uses AnalyticsManager.shared

appViewModel.addToCart()                                     // Analytics: Add To Cart

let mock = MockAnalytics()

let testViewModel = ProductViewModel(analytics: mock)        // test version

testViewModel.addToCart()

print("DEBUG Q08 - Mock recorded:", mock.events)            // ["Add To Cart"]


// ============================================================
// MARK: - 10. When to Use
// ============================================================

/*
 Good use cases:

 ✅ Truly shared application resource
 ✅ System-level shared object
 ✅ Stateless/shared service where global access is acceptable

 Examples:

 - Analytics
 - Configuration
 - Certain system services


 Avoid Singleton when:

 ❌ Object has user-specific state
 ❌ Multiple configurations may be needed
 ❌ You need easy mocking/testing
 ❌ It creates hidden dependencies
 ❌ A normal injected object is sufficient
*/


// ============================================================
// MARK: - 11. Advantages
// ============================================================

/*
 Advantages:

 ✅ Only one instance
 ✅ Easy global access
 ✅ Simple implementation
 ✅ Useful for truly shared resources
*/


// ============================================================
// MARK: - 12. Disadvantages
// ============================================================

/*
 Disadvantages:

 ❌ Global state
 ❌ Hidden dependencies
 ❌ Harder unit testing
 ❌ Tight coupling
 ❌ Can become a "God Object"
*/


// ============================================================
// MARK: - 13. Senior Interview Questions
// ============================================================

/*
 Q1. What is Singleton?

 Answer:
 A design pattern that ensures only one instance of a
 class exists and provides a shared access point.


 Q2. How do you implement Singleton in Swift?

 Answer:

 final class Manager {

     static let shared = Manager()

     private init() {}
 }


 Q3. Why is init private?

 Answer:
 To prevent external code from creating additional instances.


 Q4. Is Singleton thread-safe in Swift?

 Answer:
 `static let` initialization is safely initialized by Swift,
 so the creation of the shared instance is thread-safe.

 However, mutable state inside the Singleton may still require
 synchronization (actor, @MainActor, serial queue, or a lock).

 Swift 6 checks this at compile time: a `static let shared`
 of a non-Sendable type with mutable state is an error.


 Q5. What is the biggest problem with Singleton?

 Answer:
 Global mutable state and hidden dependencies.


 Q6. Singleton vs Dependency Injection?

 Singleton:
 Global access.

 Dependency Injection:
 Dependencies are explicitly provided.

 DI is generally easier to test and replace.


 Q7. Give iOS examples.

 Answer:

 URLSession.shared
 FileManager.default
 UserDefaults.standard
 NotificationCenter.default


 Q8. Should every Manager be Singleton?

 Answer:
 No.

 Use Singleton only when the shared-instance requirement
 is actually justified.


 Q9. How do you test code that uses a Singleton?

 Answer:
 Hide it behind a protocol and inject it, with the
 singleton as the default value (see section 9).


 Q10. Struct singleton or class singleton — which is better?

 Answer:
 Class. A singleton needs ONE shared instance; a struct is
 copied on every assignment, so copies drift apart.
 For constants only, use a caseless enum instead.
*/


// ============================================================
// MARK: - 14. Final Mental Model
// ============================================================

/*

             SINGLETON

        ┌──────────────────┐
        │   Manager        │
        │                  │
        │ static let       │
        │ shared           │
        │                  │
        │ private init()   │
        └────────┬─────────┘
                 │
       ┌─────────┼─────────┐
       ↓         ↓         ↓
   Screen A   Screen B   Screen C
       │         │         │
       └─────────┼─────────┘
                 ↓
          SAME INSTANCE


 Remember:

 static let shared
        +
 private init()
        =
    Singleton
*/
