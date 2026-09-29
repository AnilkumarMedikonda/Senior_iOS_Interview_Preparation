import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - SwiftUI Performance
//==============================================================
//
// SwiftUI re-runs `body` whenever a view's dependencies change.
// Fast SwiftUI = few body runs + cheap bodies.
//
// 1. Keep body cheap — no sorting / filtering / formatting inside it
// 2. Split views → a change re-renders only the part that depends on it
// 3. Lazy containers for long lists
// 4. Stable identity (08) + fine-grained @Observable (07)
//
// ▶︎ Run, interact with the live view, and watch the console.
//


//==============================================================
// MARK: - 01. Heavy Work in body + No Split
//==============================================================
//
// ❌ Sorting inside body, all in one view → every tap re-sorts.
//

let catalog = (1...300).map { "Product \($0)" }

struct SlowScreen: View {

    @State private var taps = 0

    var body: some View {
        let sorted = catalog.sorted(by: >)                   // ❌ runs on EVERY body call
        let _ = print("SlowScreen: sorted \(sorted.count) products")

        VStack(alignment: .leading) {
            Button("❌ Slow tap: \(taps)") {
                taps += 1
            }
            Text("Top: \(sorted[0])")
        }
    }
}

// Tap → console prints "sorted 300 products" every time.


//==============================================================
// MARK: - 02. Precompute + Split Views
//==============================================================
//
// ✅ Sort once (model / init), put the list part in its own view.
// Tapping changes only `taps` → the child's input is unchanged → its body is skipped.
//

struct TopProductView: View {

    let topProduct: String

    var body: some View {
        let _ = print("TopProductView body")
        Text("Top: \(topProduct)")
    }
}

struct FastScreen: View {

    @State private var taps = 0

    private let topProduct = catalog.sorted(by: >)[0]        // ✅ computed once

    var body: some View {
        VStack(alignment: .leading) {
            Button("✅ Fast tap: \(taps)") {
                taps += 1
            }
            TopProductView(topProduct: topProduct)           // same input → body skipped
        }
    }
}

// Tap → no sorting, "TopProductView body" does NOT print again.


//==============================================================
// MARK: - 03. Lazy vs Eager Stacks
//==============================================================
//
// VStack        → builds EVERY row immediately
// LazyVStack / List → builds only rows near the screen
//

@MainActor
enum RowCounter {
    static var eager = 0
    static var lazy = 0
}

struct EagerRow: View {

    let index: Int

    var body: some View {
        let _ = RowCounter.eager += 1
        Text("Eager row \(index)")
    }
}

struct LazyRow: View {

    let index: Int

    var body: some View {
        let _ = RowCounter.lazy += 1
        Text("Lazy row \(index)")
    }
}

struct StackComparison: View {

    var body: some View {
        VStack(alignment: .leading) {
            ScrollView {
                VStack {                                     // ❌ eager
                    ForEach(0..<200, id: \.self) { EagerRow(index: $0) }
                }
            }
            .frame(height: 100)

            ScrollView {
                LazyVStack {                                 // ✅ lazy
                    ForEach(0..<200, id: \.self) { LazyRow(index: $0) }
                }
            }
            .frame(height: 100)

            Button("Print rows built") {
                print("VStack rows built:    ", RowCounter.eager)   // 200
                print("LazyVStack rows built:", RowCounter.lazy)    // only visible (~5–10)
            }
        }
    }
}


//==============================================================
// MARK: - 04. More Rules
//==============================================================
//
// ✅ Pass the smallest input a child needs (a String, not the whole model)
// ✅ @Observable → views update only for properties they read
// ✅ Stable ForEach IDs; avoid AnyView (breaks diffing)
// ✅ .equatable() / Equatable views → skip body when inputs are equal
// ✅ Pre-format dates / prices in the model, not in body
// ❌ Creating objects in body (formatters, view models)
// ❌ Huge single body with many unrelated @State values
// ❌ GeometryReader everywhere → extra layout passes
//


//==============================================================
// MARK: - 05. Finding Problems
//==============================================================
//
// Self._printChanges()                   → why this body ran
// let _ = print("… body")                → how often it runs
// Instruments → SwiftUI template         → View Body / View Properties counts
// Instruments → Animation Hitches        → dropped frames while scrolling
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    VStack(alignment: .leading, spacing: 24) {
        SlowScreen()
        FastScreen()
        StackComparison()
    }
    .padding()
    .frame(width: 360, height: 480)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. When does SwiftUI re-run a view's body?
//    → When state or inputs it depends on change.
//
// 2. Why keep body cheap?
//    → It can run many times — sorting or formatting there repeats the work every time.
//
// 3. How does splitting views help performance?
//    → A child with unchanged inputs skips its body, so less work per update.
//
// 4. VStack vs LazyVStack?
//    → VStack builds every row now; LazyVStack builds only rows near the screen.
//
// 5. How does @Observable improve performance?
//    → Views refresh only when properties they read change.
//
// 6. Why avoid AnyView?
//    → It erases the view type, hurting identity and diffing.
//
// 7. How do you debug extra re-renders?
//    → Self._printChanges() and the Instruments SwiftUI template.
//
//==============================================================
