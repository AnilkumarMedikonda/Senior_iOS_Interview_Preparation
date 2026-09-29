import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - @ObservedObject
//==============================================================
//
// @ObservedObject = WATCH an ObservableObject that someone else owns.
// It re-renders the view on changes, but does NOT create or keep
// the object alive.
//
// Owner:  @StateObject  (creates it once)
// Others: @ObservedObject (receive it as a parameter)
//
// ▶︎ Run, then interact with the live view and watch the console.
//


//==============================================================
// MARK: - 01. Model
//==============================================================

@MainActor
final class CounterModel: ObservableObject {

    let label: String

    @Published var count = 0

    init(label: String) {
        self.label = label
        print("\(label) → model init")
    }

    deinit {
        print("\(label) → model deinit")
    }
}


//==============================================================
// MARK: - 02. The Classic Bug
//==============================================================
//
// @ObservedObject var model = CounterModel()
// → a NEW model every time the parent re-renders → count resets to 0.
//

struct BuggyCounter: View {

    @ObservedObject var model = CounterModel(label: "❌ ObservedObject")   // recreated

    var body: some View {
        Button("❌ Observed: \(model.count)") {
            model.count += 1
        }
    }
}

struct CorrectCounter: View {

    @StateObject private var model = CounterModel(label: "✅ StateObject")  // created once

    var body: some View {
        Button("✅ StateObject: \(model.count)") {
            model.count += 1
        }
    }
}

struct RecreationParent: View {

    @State private var isHighlighted = false

    var body: some View {
        VStack {
            Toggle("Highlight (re-render parent)", isOn: $isHighlighted)
            BuggyCounter()
            CorrectCounter()
        }
        .padding()
        .background(isHighlighted ? Color.yellow.opacity(0.3) : Color.clear)
    }
}

// Tap both counters 3 times → both show 3. Toggle Highlight →
// ❌ Observed resets to 0, console: "❌ ObservedObject → model init"
// ✅ StateObject stays at 3


//==============================================================
// MARK: - 03. Correct Use: Owner Passes It Down
//==============================================================
//
// One owner (@StateObject) → children observe the same instance.
// A change in one child updates every view watching the object.
//

@MainActor
final class CartModel: ObservableObject {

    @Published var items: [String] = []
}

struct CartBadge: View {

    @ObservedObject var cart: CartModel               // passed in — not created

    var body: some View {
        Text("🛒 \(cart.items.count)")
    }
}

struct AddToCartButton: View {

    @ObservedObject var cart: CartModel

    var body: some View {
        Button("Add Shoes") {
            cart.items.append("Shoes")
        }
    }
}

struct ShopScreen: View {

    @StateObject private var cart = CartModel()       // the ONE owner

    var body: some View {
        HStack {
            AddToCartButton(cart: cart)
            Spacer()
            CartBadge(cart: cart)                     // updates when the button adds
        }
    }
}


//==============================================================
// MARK: - 04. Pass Only What the Child Needs
//==============================================================
//
// Child only READS one value    → pass the value (let count: Int)
// Child EDITS one property      → pass a binding ($cart.items)
// Child needs the whole model   → @ObservedObject
// Smaller inputs = fewer re-renders and easier previews / tests.
//


//==============================================================
// MARK: - 05. Manual objectWillChange
//==============================================================
//
// @Published sends objectWillChange automatically.
// For non-published state, send it yourself BEFORE the change.
//

@MainActor
final class DownloadModel: ObservableObject {

    private(set) var progress = 0.0                   // not @Published

    func advance() {
        objectWillChange.send()                       // notify first
        progress += 0.25
        print("Progress:", progress)
    }
}

struct DownloadView: View {

    @StateObject private var model = DownloadModel()

    var body: some View {
        Button("Download: \(Int(model.progress * 100))%") {
            model.advance()
        }
    }
}


//==============================================================
// MARK: - 06. StateObject vs ObservedObject
//==============================================================
//
// ┌────────────────────┬───────────────────────┬────────────────────────────┐
// │                    │ @StateObject          │ @ObservedObject            │
// ├────────────────────┼───────────────────────┼────────────────────────────┤
// │ Creates the object │ Yes — once            │ No — receives it           │
// │ Keeps it alive     │ Yes                   │ No — the owner does        │
// │ Parent re-render   │ Same instance kept    │ Recreated if created inline│
// │ Use in             │ The owning view       │ Child views                │
// └────────────────────┴───────────────────────┴────────────────────────────┘
//
// iOS 17+: @Observable → plain `let model` or @Bindable (07_Observation_Framework)
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    VStack(spacing: 24) {
        RecreationParent()
        ShopScreen()
        DownloadView()
    }
    .padding()
    .frame(width: 360, height: 420)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is @ObservedObject?
//    → Watches an ObservableObject owned elsewhere and re-renders when it changes.
//
// 2. Why does @ObservedObject var vm = ViewModel() lose state?
//    → The view struct is recreated on parent re-renders, creating a new model each time.
//
// 3. @StateObject vs @ObservedObject?
//    → StateObject creates and owns; ObservedObject receives and watches.
//
// 4. How do two child views share one model?
//    → Parent owns it with @StateObject and passes it to both as @ObservedObject.
//
// 5. When should a child get a value or binding instead of the model?
//    → When it only needs one property — fewer re-renders and simpler tests.
//
// 6. How do you trigger an update for a non-@Published property?
//    → Call objectWillChange.send() before changing it.
//
//==============================================================
