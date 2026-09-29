import Foundation

//==============================================================
// MARK: - UserDefaults
//==============================================================
//
// Small key–value storage for settings and flags.
// Stored as a plist in the app's sandbox, loaded into memory.
// NOT encrypted → never store tokens or passwords (use Keychain).
//
// Uses its own suite so the demo starts clean every run.
//

let defaults = UserDefaults(suiteName: "prep.userdefaults.demo")!

defaults.removePersistentDomain(forName: "prep.userdefaults.demo")      // fresh start


//==============================================================
// MARK: - 01. Save & Read Basic Types
//==============================================================

print("\n========== 01 - Save & Read ==========")

defaults.set(true, forKey: "hasSeenOnboarding")

defaults.set(3, forKey: "launchCount")

defaults.set("dark", forKey: "theme")

print(defaults.bool(forKey: "hasSeenOnboarding"))       // true

print(defaults.integer(forKey: "launchCount"))          // 3

print(defaults.string(forKey: "theme") as Any)          // Optional("dark")


//==============================================================
// MARK: - 02. Missing Keys — the Trap
//==============================================================
//
// bool / integer return false / 0 when the key doesn't exist.
// You can't tell "never set" from "set to 0".
// Fix: register defaults, or use object(forKey:) to check for nil.
//

print("\n========== 02 - Missing Keys ==========")

print("Missing bool:", defaults.bool(forKey: "notificationsOn"))        // false ⚠️ never set

print("Missing object:", defaults.object(forKey: "notificationsOn") as Any)   // nil ✅ clearly missing

defaults.register(defaults: ["notificationsOn": true])                  // app-wide defaults

print("After register:", defaults.bool(forKey: "notificationsOn"))       // true

// register(defaults:) is NOT saved to disk — call it at every launch.


//==============================================================
// MARK: - 03. Saving Codable Types
//==============================================================
//
// UserDefaults stores plist types only (String, Int, Bool, Data, Array, Dictionary).
// Custom types → encode to Data first.
//

struct FilterSettings: Codable {
    let sortBy: String
    let maxPrice: Int
}

print("\n========== 03 - Codable ==========")

if let data = try? JSONEncoder().encode(FilterSettings(sortBy: "price", maxPrice: 5000)) {
    defaults.set(data, forKey: "filters")
}

if let data = defaults.data(forKey: "filters"),
   let filters = try? JSONDecoder().decode(FilterSettings.self, from: data) {
    print(filters.sortBy, filters.maxPrice)             // price 5000
}


//==============================================================
// MARK: - 04. Typed Wrapper
//==============================================================
//
// No string keys scattered around the app → one type owns them.
// (Property wrapper version → 02_Advanced_Swift/04_Property_Wrappers)
//

struct SettingsStore {

    private enum Key {
        static let launchCount = "launchCount"
        static let theme = "theme"
    }

    let store: UserDefaults

    var launchCount: Int {
        get { store.integer(forKey: Key.launchCount) }
        nonmutating set { store.set(newValue, forKey: Key.launchCount) }
    }

    var theme: String {
        get {
            if let value = store.string(forKey: Key.theme) {
                return value
            }
            return "light"
        }
        nonmutating set { store.set(newValue, forKey: Key.theme) }
    }
}

print("\n========== 04 - Typed Wrapper ==========")

let settings = SettingsStore(store: defaults)

settings.launchCount += 1

print("Launch count:", settings.launchCount)            // 4

print("Theme:", settings.theme)                         // dark


//==============================================================
// MARK: - 05. Removing Values
//==============================================================

print("\n========== 05 - Removing ==========")

defaults.removeObject(forKey: "theme")

print("Theme after remove:", settings.theme)            // light (fallback)

// Logout: remove user-specific keys — don't wipe app-wide settings by accident.


//==============================================================
// MARK: - 06. SwiftUI & Sharing
//==============================================================
//
// SwiftUI:
// @AppStorage("theme") private var theme = "light"    // view updates when it changes
//
// Share with widgets / extensions (App Group):
// UserDefaults(suiteName: "group.com.shop.app")
//
// synchronize() → not needed anymore; the system saves automatically.
//


//==============================================================
// MARK: - 07. What NOT to Store
//==============================================================
//
// ❌ Tokens, passwords, API keys → Keychain (not encrypted here)
// ❌ Large data (images, JSON feeds) → files / Core Data (whole plist loads into memory)
// ❌ Lists that grow over time (history, cart) → Core Data / files
// ❌ Data that changes very often → slows app launch, wastes writes
// ✅ Small settings, flags, last-selected tab, onboarding done, simple preferences
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is UserDefaults for?
//    → Small settings and flags stored as key–value pairs.
//
// 2. Why not store a token in UserDefaults?
//    → It's plain text in a plist — use the Keychain for secrets.
//
// 3. What does integer(forKey:) return for a missing key?
//    → 0 — use object(forKey:) or register(defaults:) to tell missing apart.
//
// 4. How do you store a custom struct?
//    → Encode it to Data with Codable, then save the Data.
//
// 5. Why not store large data there?
//    → The whole plist is loaded into memory — it slows launch and wastes memory.
//
// 6. How do you share UserDefaults with a widget?
//    → An App Group with UserDefaults(suiteName:).
//
// 7. Do you need synchronize()?
//    → No — the system saves changes automatically.
//
//==============================================================
