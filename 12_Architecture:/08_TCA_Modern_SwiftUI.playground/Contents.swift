import Foundation
import Observation
import SwiftUI
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - TCA / MODERN SWIFTUI ARCHITECTURE
// ============================================================

/*
 Two modern ways to structure a SwiftUI app:

 A) MODERN MVVM  (@Observable, iOS 17+)
    View ──▶ @Observable Model ──▶ Client (API)
    • Simple, Apple-native, most common


 B) TCA — The Composable Architecture (Point-Free library)
    Unidirectional data flow:

         ┌──────────── send(Action) ────────────┐
         │                                      ↓
      ┌──────┐   reads    ┌───────┐       ┌──────────┐
      │ View │ ◀───────── │ State │ ◀──── │ Reducer  │
      └──────┘            └───────┘ mutates└────┬─────┘
                                                │ returns
                                                ↓
                                          ┌──────────┐
                                          │  Effect  │ (API, timers)
                                          └────┬─────┘
                                               │ sends new Action
                                               └──────▶ Reducer

    State   → ALL data for the feature (struct)
    Action  → EVERYTHING that can happen (enum)
    Reducer → pure function: (inout State, Action) → Effect
    Effect  → side effects; result comes back as an Action
    Store   → holds State, runs Reducer, the View talks to it


 NOTE:
 The real TCA is a Swift Package (import ComposableArchitecture),
 so it can't be imported in a plain playground.
 Below is a MINI TCA built from scratch to show HOW it works,
 with the real TCA syntax in comments.
*/


// ============================================================
// MARK: - 1. Shared Dependency — API Client (struct of closures)
// ============================================================

/*
 Closure-based client = easy to swap live / mock / failing.
 (Same style TCA uses with @Dependency.)
*/

struct FeatureError: Error, Equatable {
    let message: String
}

struct ProductClient: Sendable {

    var fetch: @Sendable () async throws -> [String]
}

extension ProductClient {

    static let live = ProductClient {
        try await Task.sleep(for: .milliseconds(80))         // fake network
        return ["iPhone", "MacBook", "AirPods"]
    }

    static let mock = ProductClient {
        ["Test Phone"]
    }

    static let failing = ProductClient {
        throw FeatureError(message: "Network down")
    }
}


// ============================================================
// MARK: - PART A — MODERN MVVM (@Observable)
// ============================================================

/*
 iOS 17+: @Observable replaces ObservableObject + @Published.
 SwiftUI tracks ONLY the properties the view actually reads.
*/

@MainActor
@Observable
final class ProductsModel {

    var products: [String] = []
    var isLoading = false
    var errorMessage: String?
    var favorites: Set<String> = []

    @ObservationIgnored
    private let client: ProductClient                        // not observed

    init(client: ProductClient) {
        self.client = client
    }

    func onAppear() async {
        isLoading = true
        defer { isLoading = false }

        do {
            products = try await client.fetch()
        } catch {
            errorMessage = "Unable to load"
        }
    }

    func favoriteTapped(_ product: String) {
        if favorites.contains(product) {
            favorites.remove(product)
        } else {
            favorites.insert(product)
        }
    }
}

struct ProductsMVVMView: View {

    @State private var model = ProductsModel(client: .live)  // owns the model

    var body: some View {
        List(model.products, id: \.self) { product in
            Button {
                model.favoriteTapped(product)
            } label: {
                Label(product, systemImage: model.favorites.contains(product) ? "heart.fill" : "heart")
            }
        }
        .overlay { if model.isLoading { ProgressView() } }
        .task { await model.onAppear() }                     // auto-cancelled on disappear
    }
}


// ============================================================
// MARK: - PART B — MINI TCA (built from scratch)
// ============================================================

// ---------- Effect ----------

/*
 An Effect is "work to do later" that may produce a new Action.
*/

struct Effect<Action: Sendable>: Sendable {

    let operation: (@Sendable () async -> Action?)?

    static var none: Effect { Effect(operation: nil) }

    static func run(_ work: @escaping @Sendable () async -> Action?) -> Effect {
        Effect(operation: work)
    }
}

// ---------- Reducer ----------

protocol Reducer {

    associatedtype State
    associatedtype Action: Sendable

    func reduce(into state: inout State, action: Action) -> Effect<Action>
}

// ---------- Store ----------

/*
 Store = the ONLY way to change state.
 View reads store.state and calls store.send(action).
*/

@MainActor
@Observable
final class Store<R: Reducer> {

    private(set) var state: R.State

    @ObservationIgnored
    private let reducer: R

    init(initialState: R.State, reducer: R) {
        self.state = initialState
        self.reducer = reducer
    }

    @discardableResult
    func send(_ action: R.Action) -> Task<Void, Never> {

        print("   ▶️ action:", action)

        let effect = reducer.reduce(into: &state, action: action)   // 1. mutate state

        return Task {
            guard let operation = effect.operation,
                  let next = await operation() else { return }       // 2. run effect

            await self.send(next).value                               // 3. feed result back
        }
    }
}


// ============================================================
// MARK: - 2. TCA Feature — State / Action / Reducer
// ============================================================

struct ProductsFeature: Reducer {

    // ALL state for this feature
    struct State: Equatable {
        var products: [String] = []
        var isLoading = false
        var errorMessage: String?
        var favorites: Set<String> = []
    }

    // EVERYTHING that can happen
    enum Action: Sendable, Equatable {
        case onAppear                                       // user / lifecycle
        case productsResponse(Result<[String], FeatureError>) // effect result
        case favoriteTapped(String)                         // user
    }

    let client: ProductClient                               // dependency

    // PURE: same state + action → same result. No API calls here.
    func reduce(into state: inout State, action: Action) -> Effect<Action> {

        switch action {

        case .onAppear:
            state.isLoading = true
            state.errorMessage = nil
            return .run { [client] in
                do {
                    return .productsResponse(.success(try await client.fetch()))
                } catch let error as FeatureError {
                    return .productsResponse(.failure(error))
                } catch {
                    return .productsResponse(.failure(FeatureError(message: "Unknown")))
                }
            }

        case .productsResponse(.success(let products)):
            state.isLoading = false
            state.products = products
            return .none

        case .productsResponse(.failure(let error)):
            state.isLoading = false
            state.errorMessage = error.message
            return .none

        case .favoriteTapped(let product):
            if state.favorites.contains(product) {
                state.favorites.remove(product)
            } else {
                state.favorites.insert(product)
            }
            return .none
        }
    }
}


// ============================================================
// MARK: - 3. TCA View
// ============================================================

/*
 View never mutates state directly.
 It only READS state and SENDS actions.
*/

struct ProductsTCAView: View {

    let store: Store<ProductsFeature>

    var body: some View {
        List(store.state.products, id: \.self) { product in
            Button {
                store.send(.favoriteTapped(product))
            } label: {
                Label(product, systemImage: store.state.favorites.contains(product) ? "heart.fill" : "heart")
            }
        }
        .overlay { if store.state.isLoading { ProgressView() } }
        .task { await store.send(.onAppear).value }
    }
}


// ============================================================
// MARK: - 4. Real TCA Syntax (reference)
// ============================================================

/*
 import ComposableArchitecture

 @Reducer
 struct ProductsFeature {

     @ObservableState
     struct State: Equatable {
         var products: [String] = []
         var isLoading = false
     }

     enum Action {
         case onAppear
         case productsResponse(Result<[String], Error>)
     }

     @Dependency(\.productClient) var client

     var body: some ReducerOf<Self> {
         Reduce { state, action in
             switch action {
             case .onAppear:
                 state.isLoading = true
                 return .run { send in
                     await send(.productsResponse(Result { try await client.fetch() }))
                 }
             case let .productsResponse(.success(products)):
                 state.isLoading = false
                 state.products = products
                 return .none
             case .productsResponse(.failure):
                 state.isLoading = false
                 return .none
             }
         }
     }
 }

 // View
 struct ProductsView: View {
     let store: StoreOf<ProductsFeature>
     var body: some View {
         List(store.products, id: \.self) { Text($0) }
             .task { store.send(.onAppear) }
     }
 }

 // App
 ProductsView(store: Store(initialState: ProductsFeature.State()) {
     ProductsFeature()
 })

 // Test — exhaustive: every state change must be asserted
 let store = TestStore(initialState: ProductsFeature.State()) {
     ProductsFeature()
 } withDependencies: {
     $0.productClient.fetch = { ["Test Phone"] }
 }
 await store.send(.onAppear) { $0.isLoading = true }
 await store.receive(\.productsResponse.success) {
     $0.isLoading = false
     $0.products = ["Test Phone"]
 }
*/


// ============================================================
// MARK: - Run
// ============================================================

Task { @MainActor in

    print("\n========== 01 - Modern MVVM (@Observable) ==========")

    let model = ProductsModel(client: .live)
    await model.onAppear()
    model.favoriteTapped("MacBook")
    print("Products:", model.products)
    print("Favorites:", model.favorites)


    print("\n========== 02 - Mini TCA: Action → Reducer → Effect → Action ==========")

    let store = Store(
        initialState: ProductsFeature.State(),
        reducer: ProductsFeature(client: .live)
    )
    await store.send(.onAppear).value
    store.send(.favoriteTapped("AirPods"))
    print("State.products:", store.state.products)
    print("State.favorites:", store.state.favorites)


    print("\n========== 03 - TCA Test: Reducer is Pure (no Store, no UI) ==========")

    var testState = ProductsFeature.State()
    let reducer = ProductsFeature(client: .mock)

    _ = reducer.reduce(into: &testState, action: .onAppear)
    print("After .onAppear → isLoading:", testState.isLoading)          // true

    _ = reducer.reduce(into: &testState, action: .productsResponse(.success(["Test Phone"])))
    print("After response → products:", testState.products, "isLoading:", testState.isLoading)

    let expected = ProductsFeature.State(products: ["Test Phone"], isLoading: false)
    print("Matches expected:", testState == expected)                   // true


    print("\n========== 04 - TCA Error Path (failing client) ==========")

    let failingStore = Store(
        initialState: ProductsFeature.State(),
        reducer: ProductsFeature(client: .failing)
    )
    await failingStore.send(.onAppear).value
    print("Error:", failingStore.state.errorMessage ?? "nil")


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 5. SwiftUI State Tools (Modern)
// ============================================================

/*
 | Tool                 | Use                                          |
 |----------------------|----------------------------------------------|
 | @State               | View-owned value OR view-owned @Observable   |
 | @Binding             | Read/write a parent's value                  |
 | @Bindable            | Make bindings ($model.name) to @Observable   |
 | @Environment         | Inject shared objects / values down the tree |
 | @Observable (macro)  | iOS 17+ model, fine-grained updates          |
 | .task { }            | Async work tied to view lifetime             |

 OLD (iOS 13–16)              NEW (iOS 17+)
 ObservableObject        →    @Observable
 @Published var          →    plain var
 @StateObject            →    @State
 @ObservedObject         →    plain let / @Bindable
 @EnvironmentObject      →    @Environment(Model.self)
*/


// ============================================================
// MARK: - 6. Modern MVVM vs TCA
// ============================================================

/*
 |                 | Modern MVVM (@Observable) | TCA                         |
 |-----------------|---------------------------|-----------------------------|
 | Data flow       | Two-way (VM methods)      | One-way (Action → Reducer)  |
 | State changes   | Anywhere in the VM        | ONLY in the Reducer         |
 | Side effects    | async funcs in VM         | Effects, returned explicitly|
 | Testing         | Unit test the VM          | TestStore, exhaustive       |
 | Dependencies    | init injection            | @Dependency                 |
 | Composition     | Manual                    | Scope child features        |
 | Learning curve  | Low                       | High                        |
 | Library         | None (Apple)              | Third-party (Point-Free)    |
 | Best for        | Most apps                 | Complex state, big teams    |
*/


// ============================================================
// MARK: - 7. Advantages / Disadvantages of TCA
// ============================================================

/*
 ✅ Single source of truth, predictable one-way flow
 ✅ Every change is an Action → easy to debug / log / replay
 ✅ Reducers are pure → exhaustive, deterministic tests
 ✅ Side effects are explicit and controllable
 ✅ Features compose (parent scopes child stores)

 ❌ Steep learning curve, lots of new concepts
 ❌ Boilerplate (State, Action, Reducer for everything)
 ❌ Third-party dependency, frequent API changes between versions
 ❌ Can hurt performance if state is huge and poorly scoped
 ❌ Overkill for simple screens
*/


// ============================================================
// MARK: - 8. Pitfalls
// ============================================================

/*
 ❌ Calling APIs inside the reducer → return an Effect instead
 ❌ Mutating state from a View or Effect → only the Reducer mutates
 ❌ Huge single AppState → scope into child features
 ❌ (MVVM) Using ObservableObject on iOS 17+ → prefer @Observable
 ❌ (MVVM) @State for a model passed in from parent → use let / @Bindable
 ❌ (MVVM) Heavy work in body → move to the model / .task
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is TCA?
     → Point-Free's library for unidirectional architecture:
       State, Action, Reducer, Effect, Store.

 Q2. What is a Reducer?
     → A pure function (inout State, Action) → Effect.
       The ONLY place state changes.

 Q3. How are side effects handled?
     → Reducer returns an Effect; its result comes back as a new Action.

 Q4. Why is TCA easy to test?
     → Reducers are pure; TestStore asserts every state change and
       every received action, with mocked dependencies.

 Q5. @Observable vs ObservableObject?
     → @Observable (iOS 17) tracks per-property reads → fewer redraws,
       no @Published, use @State instead of @StateObject.

 Q6. MVVM vs TCA — which would you choose?
     → MVVM with @Observable for most apps (simple, native).
       TCA for complex shared state, strict predictability,
       and teams already invested in it.

 Q7. What is unidirectional data flow?
     → Data moves one way: View → Action → Reducer → State → View.
       No direct two-way mutations.

 Q8. Is MVVM still needed in SwiftUI?
     → SwiftUI views are already state-driven; a light @Observable
       model holds logic + async work so views stay simple and testable.
*/


// ============================================================
// MARK: - FINAL MENTAL MODEL
// ============================================================

/*
   Modern MVVM:   View ⇄ @Observable Model → Client

   TCA:           View → Action → Reducer → State → View
                                     ↓
                                   Effect → Action

   "In TCA, the Reducer is the only place state can change."
*/
