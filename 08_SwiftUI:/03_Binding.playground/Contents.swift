import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - @Binding
//==============================================================
//
// @Binding = read / write access to state owned SOMEWHERE ELSE.
// It stores nothing itself — it points to the parent's source of truth.
// Created with $ : $count on @State gives a Binding<Int>.
//
// Parent owns the value → child edits it through the binding →
// parent (and every other view using it) updates.
//
// ▶︎ Run, then interact with the live view and watch the console.
//


//==============================================================
// MARK: - 01. Parent Owns, Child Edits
//==============================================================

struct QuantityStepper: View {

    @Binding var quantity: Int                        // no initial value — it's borrowed

    var body: some View {
        Stepper("Quantity: \(quantity)", value: $quantity, in: 1...10)
    }
}

struct CartScreen: View {

    @State private var quantity = 1                   // single source of truth

    let price = 499

    var body: some View {
        let _ = Self._printChanges()

        VStack(alignment: .leading) {
            QuantityStepper(quantity: $quantity)      // pass a binding with $
            Text("Total: ₹\(quantity * price)")       // updates when child changes it
        }
    }
}

// Tap + in the stepper → console: "CartScreen: _quantity changed."
// This also fixes the @State initial value trap from 02_State.


//==============================================================
// MARK: - 02. Binding to a Struct Property
//==============================================================
//
// $profile.name → Binding<String> to one property of a struct.
//

struct Profile {
    var name = "Anil"
    var notificationsOn = true
}

struct ProfileEditor: View {

    @State private var profile = Profile()

    var body: some View {
        VStack(alignment: .leading) {
            TextField("Name", text: $profile.name)
            Toggle("Notifications", isOn: $profile.notificationsOn)
            Text("Hello, \(profile.name)")
        }
    }
}


//==============================================================
// MARK: - 03. Custom Binding
//==============================================================
//
// Binding(get:set:) → add logic between the view and the value.
// Common uses: clamping, validation, logging, mapping types.
//

struct RatingPicker: View {

    @State private var rating = 3

    var body: some View {
        let clampedRating = Binding(
            get: { rating },
            set: { newValue in
                rating = min(max(newValue, 1), 5)     // keep between 1 and 5
                print("Rating set to", rating)
            }
        )

        Stepper("Rating: \(rating)", value: clampedRating)
    }
}


//==============================================================
// MARK: - 04. Optional → Bool Binding
//==============================================================
//
// A sheet / alert needs Binding<Bool>, but the real state is an optional item.
// Map it with a custom binding.
//

struct OrderList: View {

    @State private var selectedOrderID: Int?

    var body: some View {
        let isShowingDetail = Binding(
            get: { selectedOrderID != nil },
            set: { isShown in
                if !isShown { selectedOrderID = nil }  // dismiss clears the selection
            }
        )

        Button("Open order 42") {
            selectedOrderID = 42
        }
        .alert("Order details", isPresented: isShowingDetail) {
            Button("Close") {}
        } message: {
            if let id = selectedOrderID {
                Text("Order #\(id)")
            }
        }
    }
}

// Tip: .sheet(item: $selectedOrder) does this for you when the item is Identifiable.


//==============================================================
// MARK: - 05. Binding.constant
//==============================================================
//
// A fixed binding that ignores writes — for previews and tests.
//

let previewStepper = QuantityStepper(quantity: .constant(3))


//==============================================================
// MARK: - 06. Rules
//==============================================================
//
// ✅ @Binding when the child must CHANGE the parent's value
// ✅ Plain let when the child only READS it — simpler, fewer updates
// ✅ Pass a binding further down with $ again ($quantity on a @Binding)
// ❌ Don't give @Binding an initial value — it has no storage
// ❌ Don't create a @State copy of a binding's value — two sources of truth
//


//==============================================================
// MARK: - Live Preview
//==============================================================

PlaygroundPage.current.setLiveView(
    VStack(alignment: .leading, spacing: 24) {
        CartScreen()
        ProfileEditor()
        RatingPicker()
        OrderList()
        previewStepper
    }
    .padding()
    .frame(width: 360, height: 520)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is @Binding?
//    → Read / write access to state owned by another view — no storage of its own.
//
// 2. How do you create a binding?
//    → $ on a @State (or @Binding / @Bindable) property.
//
// 3. @State vs @Binding?
//    → @State owns the value; @Binding borrows the parent's value.
//
// 4. When should a child get a plain value instead of a binding?
//    → When it only reads the value and never changes it.
//
// 5. What is a custom binding for?
//    → Adding logic on get / set — clamping, validation, or mapping types.
//
// 6. How do you drive an alert from an optional?
//    → Custom Binding<Bool> (item != nil), or .sheet(item:) / .alert(item:) APIs.
//
// 7. What is Binding.constant used for?
//    → Previews and tests — a fixed value that ignores writes.
//
//==============================================================
