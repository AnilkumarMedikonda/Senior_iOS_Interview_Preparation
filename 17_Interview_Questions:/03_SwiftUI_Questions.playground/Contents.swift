import SwiftUI
import Observation
import Combine

// ============================================================
// MARK: - 03_SWIFTUI_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Each question:
 1. Question + short spoken answer
 2. Follow-up the interviewer usually asks
 3. A tiny code proof with DEBUG output (where code helps)

 Answer out loud BEFORE reading.
*/


// ============================================================
// MARK: - Q01. Declarative + Views Are Structs
// ============================================================

/*
 Q: What does "declarative" mean?

 Answer:
 Describe the UI for a state; SwiftUI updates it.
 Views are cheap structs — descriptions, not real UI.
*/

struct PriceLabel: View {

    let price: Int

    var body: some View {
        Text("₹\(price)")
    }
}

print("DEBUG Q01 - PriceLabel size:", MemoryLayout<PriceLabel>.size, "bytes — cheap to recreate")


// ============================================================
// MARK: - Q02. @State vs @Binding
// ============================================================

/*
 Q: @State vs @Binding?

 Answer:
 @State → owned, private value state.
 @Binding → read/write access to a parent's state ($).
*/

// A Binding is just "get + set" pointing at someone else's storage:

final class ParentState {
    var quantity = 1
}

struct MiniBinding<Value> {

    let get: () -> Value
    let set: (Value) -> Void

    var wrappedValue: Value {
        get { get() }
        nonmutating set { set(newValue) }
    }
}

let parent = ParentState()

let quantityBinding = MiniBinding(
    get: { parent.quantity },
    set: { parent.quantity = $0 }
)

quantityBinding.wrappedValue = 3                             // child writes through binding

print("DEBUG Q02 - parent now has:", parent.quantity)        // 3 — no copy, same storage


// ============================================================
// MARK: - Q03. @StateObject vs @ObservedObject
// ============================================================

/*
 Q: @StateObject vs @ObservedObject?

 Answer:
 StateObject creates + owns (once per identity).
 ObservedObject only watches one passed in.

 ❌ @ObservedObject var vm = ViewModel()
    → recreated on every parent re-render → state lost
*/

print("DEBUG Q03 - create → @StateObject | receive → @ObservedObject")


// ============================================================
// MARK: - Q04. @Environment vs @EnvironmentObject
// ============================================================

/*
 Q: @Environment vs @EnvironmentObject?

 Answer:
 @Environment → values (colorScheme, dismiss, custom keys)
 @EnvironmentObject → shared model injected at the top
 Missing injection → runtime crash.
*/

print("DEBUG Q04 - forget .environmentObject(...) → crash")


// ============================================================
// MARK: - Q05. @Observable — Fine-Grained Updates
// ============================================================

/*
 Q: @Observable vs ObservableObject?

 Answer:
 ObservableObject → any @Published change updates every observer.
 @Observable → only views that READ the changed property update.
*/

@Observable
final class ProfileStore {
    var name = "Anil"
    var cartCount = 0
}

let store = ProfileStore()

withObservationTracking {
    _ = store.name                                           // "view" reads only name
} onChange: {
    print("DEBUG Q05 - name changed → this view re-renders")
}

store.cartCount = 5                                          // not read → no update

store.name = "Kumar"                                         // read → update fires


// ============================================================
// MARK: - Q06. @State Initial Value Trap
// ============================================================

/*
 Q: The @State initial value trap?

 Answer:
 Initial value used ONCE. New values from the parent are
 ignored. Fix: @Binding, or .id(value) to reset.
*/

struct QuantityPicker: View {

    @State private var quantity: Int

    init(start: Int) {
        _quantity = State(initialValue: start)               // used only the first time
    }

    var body: some View {
        Stepper("\(quantity)", value: $quantity)
    }
}

print("DEBUG Q06 - parent changes start → picker keeps old value unless .id(start)")


// ============================================================
// MARK: - Q07. When Does body Re-Run?
// ============================================================

/*
 Q: When does body re-run?

 Answer:
 When anything it READS changes (state, bindings,
 observed properties, environment).

 Follow-up: debug it?
 → let _ = Self._printChanges() inside body.
*/

print("DEBUG Q07 - Self._printChanges() tells you WHY body ran")


// ============================================================
// MARK: - Q08. View Identity (if / else)
// ============================================================

/*
 Q: What is view identity?

 Answer:
 Structural (type + position) or explicit (.id, ForEach ID).
 New identity → state reset.
*/

@ViewBuilder
func badge(isSale: Bool) -> some View {
    if isSale {
        Text("SALE")
    } else {
        EmptyView()
    }
}

print("DEBUG Q08 - if/else type:", type(of: badge(isSale: true)))   // _ConditionalContent<Text, EmptyView>


// ============================================================
// MARK: - Q09. ForEach Indices Bug
// ============================================================

/*
 Q: Why is ForEach with indices dangerous?

 Answer:
 Indices shift on delete/insert → row state moves to the
 wrong item. Use stable IDs.
*/

var items = ["Pack", "Ship", "Invoice"]

let tickedIndex = 1                                          // user ticked "Ship"

items.removeFirst()

print("DEBUG Q09 - tick at index 1 now shows:", items[tickedIndex])   // Invoice ❌


// ============================================================
// MARK: - Q10. Modifier Order
// ============================================================

/*
 Q: Why does modifier order matter?

 Answer:
 Each modifier wraps the previous view in a new one.
*/

let paddedFirst = Text("Sale").padding().background(Color.red)

let backgroundFirst = Text("Sale").background(Color.red).padding()

print("DEBUG Q10 - different types:", type(of: paddedFirst) != type(of: backgroundFirst))   // true


// ============================================================
// MARK: - Q11. AnyView
// ============================================================

/*
 Q: Why avoid AnyView?

 Answer:
 Erases the type → hides identity → worse diffing.
 Prefer @ViewBuilder / some View.
*/

print("DEBUG Q11 - AnyView type:", type(of: AnyView(Text("Hi"))))


// ============================================================
// MARK: - Q12. NavigationStack Path
// ============================================================

/*
 Q: How does NavigationStack work?

 Answer:
 A path array of values. Append = push, removeLast = pop,
 removeAll = root.

 Follow-up: deep link?
 → Build the full path so Back works.
*/

enum Route: Hashable {
    case category(String)
    case product(Int)
}

var path: [Route] = []

path.append(.category("Running"))                           // push

path.append(.product(42))                                    // push

print("DEBUG Q12 - path:", path)

path = [.category("Running"), .product(7)]                   // deep link → full stack

print("DEBUG Q12 - deep link path:", path)


// ============================================================
// MARK: - Q13. .task vs .onAppear
// ============================================================

/*
 Q: .task vs .onAppear?

 Answer:
 .task → async, auto-cancelled when the view disappears.
 .onAppear → sync, no cancellation.
*/

print("DEBUG Q13 - load data in .task { await viewModel.load() }")


// ============================================================
// MARK: - Q14. Optimizing a Complex Screen
// ============================================================

/*
 Q: How do you optimize a complex SwiftUI screen?

 Answer:
 Cheap body, small subviews with minimal inputs,
 @Observable, stable IDs, lazy stacks, measure first.
*/

print("DEBUG Q14 - split views → unchanged inputs skip body")


// ============================================================
// MARK: - Q15. VStack vs LazyVStack
// ============================================================

/*
 Q: VStack vs LazyVStack?

 Answer:
 VStack builds all children now; LazyVStack only what's
 near the screen.
*/

print("DEBUG Q15 - 1,000 rows: VStack builds 1,000 | LazyVStack builds ~15")


// ============================================================
// MARK: - Q16. UIKit ↔ SwiftUI
// ============================================================

/*
 Q: How do you mix UIKit and SwiftUI?

 Answer:
 SwiftUI in UIKit → UIHostingController
 UIKit in SwiftUI → UIViewRepresentable
   makeUIView once, updateUIView on changes,
   Coordinator for delegates.
*/

print("DEBUG Q16 - Hosting (SwiftUI→UIKit) | Representable (UIKit→SwiftUI)")


// ============================================================
// MARK: - Q17. Store the AnyCancellable
// ============================================================

/*
 Q: Why store an AnyCancellable?

 Answer:
 The subscription lives only as long as the cancellable.
*/

let updates = PassthroughSubject<Int, Never>()

_ = updates.sink { print("DEBUG Q17 - ❌ lost:", $0) }       // dropped immediately

var cancellables = Set<AnyCancellable>()

updates
    .sink { print("DEBUG Q17 - ✅ stored:", $0) }
    .store(in: &cancellables)

updates.send(1)                                              // only "stored" prints


// ============================================================
// MARK: - Q18. @Published willSet Trap
// ============================================================

/*
 Q: The @Published willSet trap?

 Answer:
 $property emits in willSet → self.property is still OLD
 inside sink. Use the value passed in.
*/

final class CartModel {

    @Published var count = 0

    private var bag = Set<AnyCancellable>()

    init() {
        $count
            .dropFirst()
            .sink { [weak self] newValue in
                if let self {
                    print("DEBUG Q18 - received \(newValue), self.count is \(self.count)")   // 5, 0
                }
            }
            .store(in: &bag)
    }
}

let cart = CartModel()

cart.count = 5


// ============================================================
// MARK: - Q19. Combine vs async/await
// ============================================================

/*
 Q: Combine vs async/await?

 Answer:
 async/await → one-shot work (API calls).
 Combine → continuous streams (debounce search,
 combineLatest validation). Bridge with .values.
*/

print("DEBUG Q19 - one value → async/await | stream → Combine")


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Who owns it?      → @State / @StateObject / @State + @Observable
   Who borrows it?   → @Binding / @ObservedObject / plain property
   Shared app-wide?  → @Environment
   Why re-render?    → it READ something that changed
   Identity          → stable IDs, avoid if/else resets, no AnyView
   Navigation        → data-driven path


 Senior One-Liner:

 "I decide who owns each piece of state, use @Observable for
  fine-grained updates, keep IDs stable and bodies cheap, and
  drive navigation from data."
*/
