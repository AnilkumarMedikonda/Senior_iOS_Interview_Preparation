import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - @StateObject
//==============================================================
//
// @StateObject = the view CREATES and OWNS a reference-type model
// (an ObservableObject). SwiftUI creates it once and keeps it alive
// for the view's whole lifetime — even when the view struct is recreated.
//
// ObservableObject + @Published → any published change re-renders the view.
// iOS 17+: @Observable + @State replaces this (07_Observation_Framework).
//
// ▶︎ Run, then interact with the live view and watch the console.
//


//==============================================================
// MARK: - 01. ViewModel
//==============================================================

@MainActor
final class ProductViewModel: ObservableObject {

    let productID: Int

    @Published private(set) var name = "Loading…"

    @Published var isFavorite = false

    init(productID: Int) {
        self.productID = productID
        print("ProductViewModel init — id \(productID)")
    }

    deinit {
        print("ProductViewModel deinit")
    }

    func load() async {
        try? await Task.sleep(for: .milliseconds(300))   // simulate API
        name = "Running Shoes #\(productID)"
    }
}


//==============================================================
// MARK: - 02. View Owns the Model
//==============================================================
//
// Created lazily the first time the view appears — not on every struct init.
// Load data with .task (auto-cancelled when the view disappears).
//

struct ProductScreen: View {

    @StateObject private var viewModel: ProductViewModel

    init(productID: Int) {
        print("ProductScreen init — struct recreated")
        _viewModel = StateObject(wrappedValue: ProductViewModel(productID: productID))   // autoclosure → used once
    }

    var body: some View {
        VStack(alignment: .leading) {
            Text(viewModel.name)
            Toggle("Favorite", isOn: $viewModel.isFavorite)   // $ → binding to a @Published property
        }
        .task {
            await viewModel.load()
        }
    }
}


//==============================================================
// MARK: - 03. Model Survives Parent Re-Renders
//==============================================================
//
// Toggle "Highlight" → ProductScreen struct is recreated (init prints),
// but "ProductViewModel init" does NOT print again → same model, same state.
//

struct HighlightParent: View {

    @State private var isHighlighted = false

    var body: some View {
        VStack {
            Toggle("Highlight", isOn: $isHighlighted)
            ProductScreen(productID: 42)
        }
        .padding()
        .background(isHighlighted ? Color.yellow.opacity(0.3) : Color.clear)
    }
}

// Console:
// ProductScreen init — struct recreated
// ProductViewModel init — id 42          ← only ONCE
// (toggle) ProductScreen init — struct recreated
// (toggle) ProductScreen init — struct recreated


//==============================================================
// MARK: - 04. Parameter Trap
//==============================================================
//
// Same as @State: the initial value is used only once.
// Parent changes productID 42 → 7 → the model still shows 42.
//

struct ProductSwitcher: View {

    @State private var productID = 42

    var body: some View {
        VStack(alignment: .leading) {
            Button("Switch to product 7") {
                productID = 7
            }
            ProductScreen(productID: productID)                  // ❌ still id 42
            ProductScreen(productID: productID).id(productID)    // ✅ new identity → new model
        }
    }
}

// Tap the button → second screen prints "ProductViewModel deinit" (old)
// + "ProductViewModel init — id 7" (new). First screen keeps 42.


//==============================================================
// MARK: - 05. Rules
//==============================================================
//
// ✅ @StateObject where the model is CREATED (the owner)
// ✅ @ObservedObject where it's PASSED IN (05_ObservedObject)
// ✅ Mark ViewModels @MainActor — @Published drives UI
// ✅ Load with .task, not in init (init may run often)
// ❌ @StateObject for a model passed from the parent → parent's updates ignored
// ❌ @ObservedObject var vm = ViewModel() → recreated on every parent re-render
// ⚠️ Any @Published change re-renders every view observing the object
//    → @Observable updates only views that read the changed property
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    VStack(spacing: 24) {
        HighlightParent()
        ProductSwitcher()
    }
    .padding()
    .frame(width: 360, height: 480)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is @StateObject?
//    → A property wrapper for a view that creates and owns an ObservableObject.
//
// 2. Why does the model survive when the view struct is recreated?
//    → SwiftUI stores it outside the struct and creates it only once per view identity.
//
// 3. @StateObject vs @ObservedObject?
//    → StateObject owns and creates the model; ObservedObject only watches one passed in.
//
// 4. Why pass the model via StateObject(wrappedValue:)?
//    → It's an autoclosure — SwiftUI evaluates it only the first time.
//
// 5. What happens if the parent passes a new id?
//    → Ignored — the existing model is kept. Reset with .id(id) or react with .task(id:).
//
// 6. Where should you load data?
//    → In .task — it runs on appear and is cancelled automatically on disappear.
//
// 7. What replaces @StateObject in iOS 17?
//    → @Observable model held in @State.
//
//==============================================================
