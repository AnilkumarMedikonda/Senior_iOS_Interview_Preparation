import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - @State
//==============================================================
//
// @State = value owned BY this view.
// SwiftUI stores it OUTSIDE the struct, so it survives when the
// view struct is recreated. Changing it → body re-runs.
//
// Use for simple, local UI state: toggles, text input, selection.
// Make it private — it belongs to this view only.
//
// ▶︎ Run, then tap the buttons in the live view and watch the console.
//


//==============================================================
// MARK: - 01. Basic Counter
//==============================================================

struct CounterView: View {

    @State private var count = 0

    var body: some View {
        let _ = Self._printChanges()                  // prints WHY body re-ran

        HStack {
            Text("Count: \(count)")
            Button("+1") {
                count += 1                            // change state → body re-runs
            }
        }
    }
}

// Console on tap:
// CounterView: _count changed.


//==============================================================
// MARK: - 02. State Survives View Recreation
//==============================================================
//
// Parent re-renders → child struct is created AGAIN (init prints),
// but its @State keeps its value — SwiftUI owns the storage.
//

struct CartBadge: View {

    @State private var items = 0

    init() {
        print("CartBadge init — struct recreated")
    }

    var body: some View {
        Button("Cart items: \(items)") {
            items += 1
        }
    }
}

struct ThemeParent: View {

    @State private var isHighlighted = false

    var body: some View {
        VStack {
            Toggle("Highlight", isOn: $isHighlighted)
            CartBadge()                               // recreated on each toggle
        }
        .padding()
        .background(isHighlighted ? Color.yellow.opacity(0.3) : Color.clear)
    }
}

// Tap "Cart items" 3 times → 3. Toggle Highlight →
// "CartBadge init — struct recreated" prints, but count stays 3.


//==============================================================
// MARK: - 03. Initial Value Trap
//==============================================================
//
// @State uses the initial value ONLY the first time.
// Later changes from the parent are IGNORED.
//

struct QuantityPicker: View {

    @State private var quantity: Int

    init(start: Int) {
        _quantity = State(initialValue: start)        // used once
    }

    var body: some View {
        Stepper("Quantity: \(quantity)", value: $quantity)
    }
}

struct QuantityParent: View {

    @State private var startValue = 1

    var body: some View {
        VStack {
            Button("Parent: set start to 10") {
                startValue = 10
            }
            QuantityPicker(start: startValue)                     // ❌ stays at old value
            QuantityPicker(start: startValue).id(startValue)      // ✅ new id → fresh state
        }
    }
}

// Fixes:
// 1. Parent owns the value → child takes @Binding (03_Binding)
// 2. .id(value) → new identity → state reset (08_View_Identity)


//==============================================================
// MARK: - 04. Rules
//==============================================================
//
// ✅ private — only this view reads / writes it
// ✅ Value types (Bool, String, Int, structs)
// ✅ One source of truth — pass down as a value or @Binding
// ❌ Don't mutate state inside body → "Modifying state during view update"
// ❌ Don't use @State for data a parent or other screens need
// ❌ Reference types: @State won't notice their property changes
//    → @StateObject (iOS 13+) or @Observable + @State (iOS 17+)
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    VStack(spacing: 24) {
        CounterView()
        ThemeParent()
        QuantityParent()
    }
    .padding()
    .frame(width: 360, height: 480)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is @State?
//    → Local value state owned by a view; changing it re-renders the view.
//
// 2. How does @State survive if the view struct is recreated?
//    → SwiftUI stores it outside the struct and reconnects it by view identity.
//
// 3. Why should @State be private?
//    → It belongs to the view — outside code shouldn't set it.
//
// 4. Why doesn't a new value from the parent update @State?
//    → The initial value is used only once; later values are ignored.
//
// 5. How do you fix that?
//    → Let the parent own it and pass a @Binding, or reset with .id(value).
//
// 6. Can you use @State with a class?
//    → Only with @Observable (iOS 17+); otherwise use @StateObject.
//
// 7. How do you find why a view re-rendered?
//    → Self._printChanges() inside body.
//
//==============================================================
