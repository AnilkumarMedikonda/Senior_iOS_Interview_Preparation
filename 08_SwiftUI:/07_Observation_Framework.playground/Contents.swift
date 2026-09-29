import SwiftUI
import Observation
import PlaygroundSupport

//==============================================================
// MARK: - Observation Framework (@Observable, iOS 17+)
//==============================================================
//
// @Observable macro replaces ObservableObject + @Published.
// Key difference — FINE-GRAINED tracking:
// a view re-renders only when a property it actually READ changes.
// ObservableObject re-renders every observing view on ANY @Published change.
//
// ▶︎ Run, tap both "Cart +1" buttons, and compare the console output.
//


//==============================================================
// MARK: - 01. @Observable Model
//==============================================================
//
// No @Published — every stored property is tracked automatically.
// @ObservationIgnored → exclude a property from tracking.
//

@MainActor
@Observable
final class ProfileStore {

    var name = "Anil"

    var cartCount = 0

    @ObservationIgnored var analyticsEvents = 0       // changes never re-render
}


//==============================================================
// MARK: - 02. Fine-Grained Updates
//==============================================================
//
// NameView reads only `name`; CartView reads only `cartCount`.
// Tap Cart +1 → only CartView's body runs.
//

struct NameView: View {

    let store: ProfileStore                           // plain property — still observed

    var body: some View {
        let _ = print("NameView body")
        Text("Name: \(store.name)")
    }
}

struct CartView: View {

    let store: ProfileStore

    var body: some View {
        let _ = print("CartView body")
        Button("✅ @Observable Cart +1 (\(store.cartCount))") {
            store.cartCount += 1
        }
    }
}

// Tap → console: "CartView body"  (NameView untouched)


//==============================================================
// MARK: - 03. Compare: ObservableObject
//==============================================================

@MainActor
final class LegacyStore: ObservableObject {

    @Published var name = "Anil"

    @Published var cartCount = 0
}

struct LegacyNameView: View {

    @ObservedObject var store: LegacyStore

    var body: some View {
        let _ = print("LegacyNameView body")
        Text("Name: \(store.name)")
    }
}

struct LegacyCartView: View {

    @ObservedObject var store: LegacyStore

    var body: some View {
        let _ = print("LegacyCartView body")
        Button("❌ ObservableObject Cart +1 (\(store.cartCount))") {
            store.cartCount += 1
        }
    }
}

// Tap → console: "LegacyNameView body" AND "LegacyCartView body"
// Name never changed, but its view re-rendered anyway.


//==============================================================
// MARK: - 04. @Bindable for Bindings
//==============================================================
//
// Need $store.name for a TextField? Mark the property @Bindable.
//

struct NameEditor: View {

    @Bindable var store: ProfileStore

    var body: some View {
        TextField("Name", text: $store.name)          // edits update NameView live
    }
}


//==============================================================
// MARK: - 05. Ownership & Environment
//==============================================================
//
// Owner:       @State private var store = ProfileStore()      (replaces @StateObject)
// Child:       let store: ProfileStore                        (replaces @ObservedObject)
// Binding:     @Bindable var store: ProfileStore
// Inject:      .environment(store)                            (replaces .environmentObject)
// Read:        @Environment(ProfileStore.self) private var store
//
// ⚠️ @State's initial value expression runs on EVERY struct init
//    (SwiftUI keeps only the first instance). Keep the model's init cheap —
//    load data in .task, not init.
//

struct ObservationDemo: View {

    @State private var store = ProfileStore()         // owner

    @StateObject private var legacyStore = LegacyStore()

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            NameView(store: store)
            CartView(store: store)
            NameEditor(store: store)
            Divider()
            LegacyNameView(store: legacyStore)
            LegacyCartView(store: legacyStore)
        }
    }
}


//==============================================================
// MARK: - 06. Migration Cheat Sheet
//==============================================================
//
// ┌──────────────────────────────┬──────────────────────────────────────┐
// │ ObservableObject (iOS 13+)   │ @Observable (iOS 17+)                │
// ├──────────────────────────────┼──────────────────────────────────────┤
// │ class M: ObservableObject    │ @Observable class M                  │
// │ @Published var x             │ var x                                │
// │ @StateObject var m = M()     │ @State var m = M()                   │
// │ @ObservedObject var m: M     │ let m: M  (or @Bindable var m: M)    │
// │ .environmentObject(m)        │ .environment(m)                      │
// │ @EnvironmentObject var m: M  │ @Environment(M.self) var m           │
// │ Any change → all observers   │ Only views that read that property   │
// └──────────────────────────────┴──────────────────────────────────────┘
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    ObservationDemo()
        .padding()
        .frame(width: 380, height: 360)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What does @Observable change compared to ObservableObject?
//    → Views update only when properties they read change, not on every change.
//
// 2. Do you still need @Published?
//    → No — all stored properties are tracked; @ObservationIgnored opts one out.
//
// 3. What replaces @StateObject and @ObservedObject?
//    → @State to own the model; a plain property (or @Bindable) to pass it.
//
// 4. When do you need @Bindable?
//    → To create bindings ($model.name) to an @Observable model's properties.
//
// 5. How do you inject an @Observable model through the environment?
//    → .environment(model) and read with @Environment(Model.self).
//
// 6. What is the @State initializer gotcha?
//    → The model's init can run on every view init — keep it cheap, load in .task.
//
// 7. Why is @Observable better for performance?
//    → Fewer unnecessary body re-evaluations — only dependent views refresh.
//
//==============================================================
