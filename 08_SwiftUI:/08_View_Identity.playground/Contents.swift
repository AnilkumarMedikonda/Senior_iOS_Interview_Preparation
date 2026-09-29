import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - View Identity
//==============================================================
//
// Identity = how SwiftUI decides "is this the SAME view as before?"
// Same identity      → keep @State, animate changes
// Different identity → destroy old view, create new one (state reset,
//                      onDisappear + onAppear fire)
//
// Two kinds:
// Structural → the view's type + position in the hierarchy
// Explicit   → .id(value) and ForEach IDs
//
// ▶︎ Run, interact with the live view, and watch the console.
//


//==============================================================
// MARK: - Shared: Counter with Lifecycle Prints
//==============================================================

struct CounterBox: View {

    let label: String

    @State private var count = 0

    var body: some View {
        Button("\(label): \(count)") {
            count += 1
        }
        .onAppear { print("\(label) appeared") }
        .onDisappear { print("\(label) disappeared") }
    }
}


//==============================================================
// MARK: - 01. Structural Identity: if / else vs Modifier
//==============================================================
//
// if / else → two DIFFERENT views → switching resets state.
// One view + changing input → SAME view → state kept.
//

struct StructuralDemo: View {

    @State private var isSale = false

    var body: some View {
        VStack(alignment: .leading) {
            Toggle("Sale mode", isOn: $isSale)

            if isSale {                                       // ❌ two identities
                CounterBox(label: "Branch Sale")
            } else {
                CounterBox(label: "Branch Normal")
            }

            CounterBox(label: isSale ? "Same Sale" : "Same Normal")   // ✅ one identity
        }
    }
}

// Tap both counters to 3 → toggle Sale mode →
// Branch counter resets to 0 (console: disappeared / appeared)
// Same counter keeps 3


//==============================================================
// MARK: - 02. Explicit Identity: .id() to Reset
//==============================================================
//
// Change the id → SwiftUI treats it as a brand-new view.
// Useful: reset a form, restart an animation, reload on new product.
//

struct CheckoutForm: View {

    @State private var note = ""

    var body: some View {
        TextField("Delivery note", text: $note)
            .textFieldStyle(.roundedBorder)
    }
}

struct ResetDemo: View {

    @State private var formID = UUID()

    var body: some View {
        VStack(alignment: .leading) {
            CheckoutForm()
                .id(formID)                                   // new id → fresh @State
            Button("Reset form") {
                formID = UUID()
            }
        }
    }
}


//==============================================================
// MARK: - 03. ForEach IDs: Index vs Stable ID
//==============================================================
//
// Row state is tied to the row's ID.
// ❌ id: index → delete first item, every index shifts → state moves to the wrong row
// ✅ id: stable model ID → state stays with its item
//

struct Chore: Identifiable {
    let id: Int
    let title: String
}

struct ChoreRow: View {

    let title: String

    @State private var isDone = false

    var body: some View {
        Toggle(title, isOn: $isDone)
    }
}

struct ForEachDemo: View {

    @State private var chores = [
        Chore(id: 1, title: "Pack"),
        Chore(id: 2, title: "Ship"),
        Chore(id: 3, title: "Invoice")
    ]

    var body: some View {
        VStack(alignment: .leading) {
            Text("❌ By index").bold()
            ForEach(chores.indices, id: \.self) { index in
                ChoreRow(title: chores[index].title)
            }

            Text("✅ By ID").bold()
            ForEach(chores) { chore in
                ChoreRow(title: chore.title)
            }

            Button("Delete first") {
                if !chores.isEmpty {
                    chores.removeFirst()
                }
            }
        }
    }
}

// Tick "Ship" in both lists → Delete first →
// ❌ By index: tick jumps to "Invoice" (row 2's state now belongs to index 1)
// ✅ By ID: "Ship" stays ticked


//==============================================================
// MARK: - 04. Rules
//==============================================================
//
// ✅ Prefer changing inputs / modifiers over if-else when state must survive
// ✅ Use stable, unique IDs (database / API IDs) in ForEach and List
// ✅ Use .id(value) deliberately to reset state
// ❌ id: \.self on non-unique values (duplicate strings) → glitches, wrong rows
// ❌ UUID() created inside body as an id → new identity every render → state lost
// ❌ AnyView → erases structural identity → worse diffing and animations
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    VStack(alignment: .leading, spacing: 24) {
        StructuralDemo()
        ResetDemo()
        ForEachDemo()
    }
    .padding()
    .frame(width: 360, height: 560)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is view identity?
//    → How SwiftUI decides two renders are the same view — it controls state and animation.
//
// 2. Structural vs explicit identity?
//    → Structural = type + position; explicit = .id() or ForEach IDs.
//
// 3. Why does state reset when switching an if / else branch?
//    → Each branch is a different view identity — one is destroyed, the other created.
//
// 4. How do you reset a view's state on purpose?
//    → Change its .id(value).
//
// 5. Why is ForEach with indices dangerous?
//    → Deleting or inserting shifts indices, so row state attaches to the wrong item.
//
// 6. What makes a good ForEach ID?
//    → Stable and unique — like a database or API ID.
//
// 7. Why avoid AnyView?
//    → It hides the view type, breaking structural identity and efficient diffing.
//
//==============================================================
