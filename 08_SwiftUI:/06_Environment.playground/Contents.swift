import SwiftUI
import PlaygroundSupport

//==============================================================
// MARK: - Environment
//==============================================================
//
// Values that flow DOWN the view tree automatically.
// A parent sets them once; any descendant can read them — no passing
// through every initializer.
//
// @Environment(\.key)   → read a value (system or custom)
// .environment(\.key, v) → override it for a subtree
// @EnvironmentObject    → shared ObservableObject injected at the top
//
// ▶︎ Run, then interact with the live view and watch the console.
//


//==============================================================
// MARK: - 01. System Environment Values
//==============================================================
//
// colorScheme, dismiss, locale, dynamicTypeSize, horizontalSizeClass, openURL …
//

struct ThemeLabel: View {

    @Environment(\.colorScheme) private var colorScheme

    var body: some View {
        Text("Mode: \(colorScheme == .dark ? "Dark" : "Light")")
    }
}

struct ThemeDemo: View {

    var body: some View {
        VStack(alignment: .leading) {
            ThemeLabel()                                          // system value
            ThemeLabel()
                .environment(\.colorScheme, .dark)                // overridden for this subtree
        }
    }
}


//==============================================================
// MARK: - 02. Custom Environment Value
//==============================================================
//
// Define a key with a default, expose it on EnvironmentValues.
// (Xcode 16+: @Entry var currencyCode = "INR" does the same in one line.)
//

private struct CurrencyCodeKey: EnvironmentKey {
    static let defaultValue = "INR"
}

extension EnvironmentValues {
    var currencyCode: String {
        get { self[CurrencyCodeKey.self] }
        set { self[CurrencyCodeKey.self] = newValue }
    }
}

struct PriceLabel: View {

    let amount: Int

    @Environment(\.currencyCode) private var currencyCode      // read — no parameter needed

    var body: some View {
        Text("\(amount) \(currencyCode)")
    }
}

struct CurrencyDemo: View {

    var body: some View {
        VStack(alignment: .leading) {
            PriceLabel(amount: 4999)                              // 4999 INR (default)
            VStack {
                PriceLabel(amount: 59)
                PriceLabel(amount: 25)
            }
            .environment(\.currencyCode, "USD")                   // whole subtree → USD
        }
    }
}


//==============================================================
// MARK: - 03. @EnvironmentObject
//==============================================================
//
// Inject a shared model once at the top → any descendant reads it,
// however deep, without passing it through every view.
//

@MainActor
final class UserSession: ObservableObject {

    @Published var name = "Anil"

    @Published var isLoggedIn = true

    func logout() {
        isLoggedIn = false
        print("Logged out — every view reading the session updates")
    }
}

struct ProfileHeader: View {                                      // deep child

    @EnvironmentObject private var session: UserSession

    var body: some View {
        Text(session.isLoggedIn ? "Hi, \(session.name)" : "Guest")
    }
}

struct SettingsRow: View {                                        // another deep child

    @EnvironmentObject private var session: UserSession

    var body: some View {
        Button("Log out") {
            session.logout()
        }
        .disabled(!session.isLoggedIn)
    }
}

struct AccountScreen: View {                                      // middle view — knows nothing

    var body: some View {
        VStack(alignment: .leading) {
            ProfileHeader()
            SettingsRow()
        }
    }
}

// ❌ Forget .environmentObject(session) above AccountScreen →
//    crash: "No ObservableObject of type UserSession found"


//==============================================================
// MARK: - 04. dismiss
//==============================================================
//
// Close a sheet / pop a screen from inside it — no binding needed.
//
// struct EditSheet: View {
//     @Environment(\.dismiss) private var dismiss
//     var body: some View {
//         Button("Done") { dismiss() }
//     }
// }
//


//==============================================================
// MARK: - 05. iOS 17+ with @Observable
//==============================================================
//
// .environment(session)                        // inject (no Object suffix)
// @Environment(UserSession.self) var session   // read by type
//
// Same idea, finer updates → 07_Observation_Framework
//


//==============================================================
// MARK: - 06. When to Use
//==============================================================
//
// ✅ Environment: app-wide things — session, theme, settings, locale, services
// ✅ Parameters: screen data — product, order, the item being edited
// ❌ Everything in the environment → hidden dependencies, crashes when missing,
//    harder previews and tests
//


//==============================================================
// MARK: - Live Preview
//==============================================================

let session = UserSession()

PlaygroundPage.current.setLiveView(
    VStack(alignment: .leading, spacing: 24) {
        ThemeDemo()
        CurrencyDemo()
        AccountScreen()
    }
    .environmentObject(session)                                   // injected once, at the top
    .padding()
    .frame(width: 360, height: 360)
)


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is the SwiftUI environment?
//    → Values that flow down the view tree; any descendant can read them.
//
// 2. How do you read and override an environment value?
//    → @Environment(\.key) to read, .environment(\.key, value) to override a subtree.
//
// 3. How do you create a custom environment value?
//    → An EnvironmentKey with a default + an EnvironmentValues property (or @Entry).
//
// 4. What is @EnvironmentObject?
//    → A shared ObservableObject injected once and read by any descendant.
//
// 5. What happens if the environment object isn't injected?
//    → Runtime crash — no ObservableObject of that type found.
//
// 6. Environment vs passing parameters?
//    → Environment for app-wide dependencies; parameters for screen-specific data.
//
// 7. How do you dismiss a sheet from inside it?
//    → @Environment(\.dismiss) and call dismiss().
//
//==============================================================
