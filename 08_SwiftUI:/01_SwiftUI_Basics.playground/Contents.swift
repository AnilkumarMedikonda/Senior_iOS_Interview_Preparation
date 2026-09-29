import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - SwiftUI Basics
//==============================================================
//
// Declarative UI: describe WHAT the screen looks like for a given state.
// UI = f(state). When state changes, SwiftUI re-runs body and updates
// only what changed.
//
// A View is a lightweight STRUCT — a description, not the pixels.
// body returns `some View` (opaque type → 02_Any_vs_Some).
//


//==============================================================
// MARK: - 01. UIKit vs SwiftUI
//==============================================================
//
// ┌──────────────────┬──────────────────────────────┬──────────────────────────────┐
// │                  │ UIKit (imperative)           │ SwiftUI (declarative)        │
// ├──────────────────┼──────────────────────────────┼──────────────────────────────┤
// │ You write        │ Steps: create, add, update   │ What it looks like for state │
// │ View type        │ Class (UIView), long-lived   │ Struct, recreated often      │
// │ Updating UI      │ label.text = newValue        │ Change state → body re-runs  │
// │ Layout           │ Auto Layout constraints      │ Stacks, frames, modifiers    │
// │ Source of truth  │ Spread across views          │ State drives everything      │
// └──────────────────┴──────────────────────────────┴──────────────────────────────┘
//


//==============================================================
// MARK: - 02. A View Is a Cheap Struct
//==============================================================

struct ProductCard: View {

    let name: String

    let price: Int

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(name)
                .font(.headline)
            Text("₹\(price)")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .padding()
        .background(.blue.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

print("\n========== 02 - A View Is a Cheap Struct ==========")

print("ProductCard size:", MemoryLayout<ProductCard>.size, "bytes")   // tiny — just its properties

// Recreating views is cheap. The expensive part (rendering) is
// handled by SwiftUI, which diffs and updates only what changed.


//==============================================================
// MARK: - 03. Modifiers Wrap Views — Order Matters
//==============================================================
//
// Each modifier returns a NEW view wrapping the previous one.
// padding → background  = background covers the padding
// background → padding  = padding sits outside the background
//

print("\n========== 03 - Modifiers Wrap Views ==========")

let paddedThenBackground = Text("Sale").padding().background(Color.red)

let backgroundThenPadded = Text("Sale").background(Color.red).padding()

print(type(of: paddedThenBackground))   // ModifiedContent<ModifiedContent<Text, _PaddingLayout>, _BackgroundStyleModifier<Color>>

print(type(of: backgroundThenPadded))   // ModifiedContent<ModifiedContent<Text, _BackgroundStyleModifier<Color>>, _PaddingLayout>

// Same modifiers, different nesting → different result on screen.


//==============================================================
// MARK: - 04. Stacks & Layout
//==============================================================
//
// VStack → vertical   HStack → horizontal   ZStack → layered (back to front)
// Spacer → pushes content apart   alignment / spacing → fine-tune
// Parent proposes a size → child picks its size → parent places it.
//

struct PriceRow: View {

    var body: some View {
        HStack {
            Text("Running Shoes")
            Spacer()                          // pushes price to the trailing edge
            Text("₹4999")
                .bold()
        }
        .padding(.horizontal)
    }
}


//==============================================================
// MARK: - 05. Conditional Views
//==============================================================
//
// if / else inside a @ViewBuilder creates two DIFFERENT view types.
// Switching between them destroys one view and creates the other
// (state inside is lost) → see 08_View_Identity.
//

@ViewBuilder
func saleBadge(isOnSale: Bool) -> some View {
    if isOnSale {
        Text("SALE")
    } else {
        EmptyView()
    }
}

print("\n========== 05 - Conditional Views ==========")

print(type(of: saleBadge(isOnSale: true)))   // _ConditionalContent<Text, EmptyView>

// ✅ To keep the same view and just hide it: .opacity(isOnSale ? 1 : 0)


//==============================================================
// MARK: - 06. Lists
//==============================================================
//
// ForEach / List need stable IDs → Identifiable (details in 08_View_Identity).
//

struct Product: Identifiable {
    let id: Int
    let name: String
}

struct ProductList: View {

    let products = [Product(id: 1, name: "Shoes"), Product(id: 2, name: "Cap")]

    var body: some View {
        List(products) { product in
            Text(product.name)
        }
    }
}


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    VStack(spacing: 16) {
        ProductCard(name: "Running Shoes", price: 4999)
        PriceRow()
        saleBadge(isOnSale: true)
    }
    .padding()
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What does declarative UI mean?
//    → You describe the UI for a given state; SwiftUI updates it when state changes.
//
// 2. Why are SwiftUI views structs?
//    → They're cheap descriptions — recreated often, while SwiftUI keeps the real UI.
//
// 3. What does `some View` mean in body?
//    → An opaque type — one concrete view type, hidden from the caller.
//
// 4. Why does modifier order matter?
//    → Each modifier wraps the previous view, so a different order builds a different view.
//
// 5. What happens with if / else in a view body?
//    → Two different view types — switching destroys one and creates the other, resetting state.
//
// 6. VStack vs HStack vs ZStack?
//    → Vertical, horizontal, and layered (back to front).
//
// 7. How does SwiftUI layout work?
//    → Parent proposes a size, child chooses its size, parent positions it.
//
//==============================================================
