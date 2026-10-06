import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - MODULAR ARCHITECTURE
// ============================================================

/*
 Modular Architecture = split ONE big app target into many small,
 independent MODULES (usually Swift Packages), each with one job.

 ❌ Monolith                         ✅ Modular

 ┌────────────────┐        ┌──────────────── App ────────────────┐
 │                │        │   (composition root — wires all)    │
 │  Everything in │        └──────┬──────────────┬───────────────┘
 │  ONE target    │               ↓              ↓
 │                │        ┌────────────┐  ┌──────────────┐
 └────────────────┘        │HomeFeature │  │ProfileFeature│   Features
                           └──┬───┬─────┘  └───┬──────┬───┘
                              │   └──▶ ProfileInterface ◀┘     Interface
                              ↓                  ↓
                        ┌────────────┐  ┌──────────────┐
                        │ Networking │  │ DesignSystem │       Core
                        └────────────┘  └──────────────┘


 DEPENDENCY RULE

   App  →  Features  →  Interfaces  →  Core

 ✅ Features depend on Core + Interfaces
 ❌ Features NEVER import other Features
 ❌ Core NEVER imports Features


 NOTE:
 A playground is ONE module, so each "module" below is a MARK section.
 In a real project each one is its own Swift Package target, and only
 `public` symbols are visible to other modules.
*/


// ============================================================
// MARK: - 1. Real Setup — Package.swift (reference)
// ============================================================

/*
 // swift-tools-version: 5.9
 import PackageDescription

 let package = Package(
     name: "AppModules",
     platforms: [.iOS(.v16)],
     products: [
         .library(name: "Networking",       targets: ["Networking"]),
         .library(name: "DesignSystem",     targets: ["DesignSystem"]),
         .library(name: "ProfileInterface", targets: ["ProfileInterface"]),
         .library(name: "HomeFeature",      targets: ["HomeFeature"]),
         .library(name: "ProfileFeature",   targets: ["ProfileFeature"])
     ],
     targets: [
         .target(name: "Networking"),
         .target(name: "DesignSystem"),
         .target(name: "ProfileInterface"),
         .target(name: "HomeFeature",
                 dependencies: ["Networking", "DesignSystem", "ProfileInterface"]),
         .target(name: "ProfileFeature",
                 dependencies: ["Networking", "DesignSystem", "ProfileInterface"]),
         .testTarget(name: "HomeFeatureTests", dependencies: ["HomeFeature"])
     ]
 )

 Xcode: File → Add Package Dependencies → Add Local… → select the package.
 App target links the products it needs.
*/


// ============================================================
// MARK: - 2. CORE MODULE — Networking
// ============================================================

/*
 Shared service used by many features.
 Knows NOTHING about any feature.
*/

public protocol HTTPClient: Sendable {

    func get(_ path: String) async throws -> [String: String]
}

public final class URLSessionHTTPClient: HTTPClient {

    public init() {}

    public func get(_ path: String) async throws -> [String: String] {

        // Real: URLSession.shared.data(from:) + JSONDecoder

        try await Task.sleep(for: .milliseconds(50))

        switch path {
        case "/user": return ["name": "Anil", "city": "Hyderabad"]
        default:      return [:]
        }
    }
}


// ============================================================
// MARK: - 3. CORE MODULE — DesignSystem
// ==========================================================x==

/*
 Shared UI tokens: colors, fonts, spacing, reusable components.
 Every feature looks consistent.
*/

public enum DS {

    public static func title(_ text: String) -> String {
        "🟦 \(text.uppercased())"
    }

    public static func row(_ label: String, _ value: String) -> String {
        "   • \(label): \(value)"
    }
}


// ============================================================
// MARK: - 4. INTERFACE MODULE — ProfileInterface
// ============================================================

/*
 Problem:
   Home needs to open Profile.
   But Home must NOT import ProfileFeature (feature → feature ❌).

 Solution:
   A tiny INTERFACE module with only protocols.
   Home depends on the interface.
   ProfileFeature implements it.
   App wires them together.

   HomeFeature ──▶ ProfileInterface ◀── ProfileFeature
*/

public protocol ProfileScreen: AnyObject {

    func show()
}

public protocol ProfileBuilding {

    func makeProfile(userName: String) -> ProfileScreen
}


// ============================================================
// MARK: - 5. FEATURE MODULE — HomeFeature
// ============================================================

/*
 imports: Networking, DesignSystem, ProfileInterface
 does NOT import: ProfileFeature

 Only `public` types are visible to the App.
 Internals (formatting, private helpers) stay hidden.
*/

@MainActor
public final class HomeViewModel {

    private let client: HTTPClient
    private let profileBuilder: ProfileBuilding

    private(set) var userName = ""

    public init(client: HTTPClient, profileBuilder: ProfileBuilding) {
        self.client = client
        self.profileBuilder = profileBuilder
    }

    public func load() async {
        let json = (try? await client.get("/user")) ?? [:]
        userName = json["name"] ?? "Guest"
        print(DS.title("Home"))
        print(DS.row("Welcome", userName))
    }

    public func profileTapped() {
        // Home doesn't know ProfileViewController exists
        profileBuilder.makeProfile(userName: userName).show()
    }
}


// ============================================================
// MARK: - 6. FEATURE MODULE — ProfileFeature
// ============================================================

/*
 imports: Networking, DesignSystem, ProfileInterface
 Implements ProfileInterface's protocols.
*/

final class ProfileView: ProfileScreen {                  // internal → hidden

    private let userName: String
    private let client: HTTPClient

    init(userName: String, client: HTTPClient) {
        self.userName = userName
        self.client = client
    }

    func show() {
        print(DS.title("Profile"))
        print(DS.row("Name", userName))
    }
}

public struct ProfileBuilder: ProfileBuilding {           // only this is public

    private let client: HTTPClient

    public init(client: HTTPClient) {
        self.client = client
    }

    public func makeProfile(userName: String) -> ProfileScreen {
        ProfileView(userName: userName, client: client)
    }
}


// ============================================================
// MARK: - 7. APP TARGET — Composition Root
// ============================================================

/*
 The ONLY place that knows every module.
 Creates concrete types and injects them.
*/

@MainActor
final class AppContainer {

    let client: HTTPClient = URLSessionHTTPClient()

    func makeHome() -> HomeViewModel {
        HomeViewModel(
            client: client,
            profileBuilder: ProfileBuilder(client: client)
        )
    }
}


// ============================================================
// MARK: - 8. Testing a Module Alone
// ============================================================

/*
 HomeFeatureTests only needs HomeFeature + mocks.
 No ProfileFeature, no real network → fast & isolated.
*/

struct MockHTTPClient: HTTPClient {

    func get(_ path: String) async throws -> [String: String] {
        ["name": "Test User"]
    }
}

final class MockProfileScreen: ProfileScreen {

    func show() { print("   ✅ Mock profile shown") }
}

struct MockProfileBuilder: ProfileBuilding {

    func makeProfile(userName: String) -> ProfileScreen {
        print("   ✅ Profile requested for \(userName)")
        return MockProfileScreen()
    }
}


// ============================================================
// MARK: - Run
// ============================================================

Task { @MainActor in

    print("\n========== 01 - App Wires Modules ==========")

    let container = AppContainer()
    let home = container.makeHome()
    await home.load()


    print("\n========== 02 - Home → Profile via Interface ==========")

    home.profileTapped()                                   // Home never imports ProfileFeature


    print("\n========== 03 - Test HomeFeature Alone (mocks) ==========")

    let testHome = HomeViewModel(
        client: MockHTTPClient(),
        profileBuilder: MockProfileBuilder()
    )
    await testHome.load()
    testHome.profileTapped()


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 9. Types of Modules
// ============================================================

/*
 | Type        | Examples                          | Depends on        |
 |-------------|-----------------------------------|-------------------|
 | App         | Main target                       | Everything        |
 | Feature     | Home, Profile, Cart, Login        | Interface + Core  |
 | Interface   | ProfileInterface, CartInterface   | (nothing / Core)  |
 | Core        | Networking, Storage, Analytics    | Nothing           |
 | UI          | DesignSystem                      | Nothing           |
 | Utilities   | Extensions, Logger                | Nothing           |
*/


// ============================================================
// MARK: - 10. Access Control = Module Boundaries
// ============================================================

/*
 | Keyword       | Visible to                                 |
 |---------------|--------------------------------------------|
 | private       | Same declaration                           |
 | fileprivate   | Same file                                  |
 | internal      | Same MODULE (default)                      |
 | package       | Same Swift PACKAGE (Swift 5.9+)            |
 | public        | Other modules (cannot subclass/override)   |
 | open          | Other modules + subclass/override          |

 Rule: expose the SMALLEST public API.
 Everything else stays internal → nobody can misuse it.

 ⚠️ public types need a public init — the memberwise init is internal.
*/


// ============================================================
// MARK: - 11. Advantages / Disadvantages
// ============================================================

/*
 ✅ Faster incremental builds (only changed module rebuilds)
 ✅ Teams work in parallel, fewer merge conflicts
 ✅ Clear boundaries enforced by the compiler (public/internal)
 ✅ Reuse modules across apps / extensions (widgets, App Clips)
 ✅ Test each module alone; SwiftUI previews build faster
 ✅ Feature "demo apps" — run one feature in isolation

 ❌ Setup + Package.swift maintenance
 ❌ Must design public APIs carefully
 ❌ Dependency cycles are compile errors → needs planning
 ❌ Overkill for small apps / solo developer
*/


// ============================================================
// MARK: - 12. Pitfalls
// ============================================================

/*
 ❌ Feature imports another Feature → use an Interface module
 ❌ One giant "Common" module everything depends on → rebuilds everything
 ❌ Making everything public → boundaries become meaningless
 ❌ Circular dependency (A → B → A) → SPM refuses to build
 ❌ Splitting too early / too fine → more overhead than benefit
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is modular architecture?
     → Splitting the app into independent modules (Swift Packages /
       frameworks) — features, core services, design system.

 Q2. Main benefits?
     → Faster builds, parallel teamwork, enforced boundaries,
       reuse, isolated testing.

 Q3. How do two features talk without importing each other?
     → Through an Interface module of protocols; the App target
       injects the concrete implementation.

 Q4. Which tool do you use?
     → Swift Package Manager (local packages). Also Tuist / XCFrameworks.

 Q5. What does `public` vs `internal` mean here?
     → internal = visible inside the module only (default);
       public = visible to other modules.

 Q6. Where are dependencies wired?
     → In the App target (composition root / DI container).

 Q7. Modular vs Clean Architecture?
     → Clean = logical layers. Modular = physical split into modules.
       They combine: each feature module uses MVVM + Clean inside.

 Q8. When is it overkill?
     → Small apps, one developer, short-lived projects.
*/


// ============================================================
// MARK: - FINAL MENTAL MODEL
// ============================================================

/*
   App         → wires everything
   Features    → one feature each, never import each other
   Interfaces  → protocols that let features talk
   Core        → shared services, know no features

   "Modules depend DOWN, never SIDEWAYS."
*/
