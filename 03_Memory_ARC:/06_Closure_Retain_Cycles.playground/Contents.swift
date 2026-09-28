import Foundation

//==============================================================
// MARK: - Closure Retain Cycles
//==============================================================
//
// Closures are reference types and capture self strongly by default.
// Cycle = self stores a closure AND that closure captures self.
//   self → closure → self
// Fix: [weak self] or [unowned self] in the capture list.
//


//==============================================================
// MARK: - 01. Stored Closure Cycle
//==============================================================

final class ProfileScreen {

    let name = "Profile"

    var onTap: (() -> Void)?

    func setup() {
        onTap = {
            print(self.name)             // ❌ strong capture
        }
    }

    deinit {
        print("ProfileScreen deinit")
    }
}

print("\n========== 01 - Stored Closure Cycle ==========")

var profileScreen: ProfileScreen? = ProfileScreen()

profileScreen?.setup()

profileScreen = nil

// No deinit printed — leaked


//==============================================================
// MARK: - 02. Fix with [weak self]
//==============================================================

final class SettingsScreen {

    let name = "Settings"

    var onTap: (() -> Void)?

    func setup() {
        onTap = { [weak self] in
            guard let self else { return }
            print(self.name)             // ✅ no strong capture
        }
    }

    deinit {
        print("SettingsScreen deinit")
    }
}

print("\n========== 02 - Fix with [weak self] ==========")

var settingsScreen: SettingsScreen? = SettingsScreen()

settingsScreen?.setup()

settingsScreen?.onTap?()                 // Settings

settingsScreen = nil                     // SettingsScreen deinit


//==============================================================
// MARK: - 03. Escaping ≠ Leak
//==============================================================
//
// An escaping closure that self does NOT store is not a cycle.
// It holds self only until it runs → deinit is delayed, not lost.
//

@MainActor
final class Loader {

    func load() {
        DispatchQueue.main.async {
            print("Loaded")              // holds self until this runs
            _ = self
        }
    }

    deinit {
        print("Loader deinit")
    }
}

print("\n========== 03 - Escaping ≠ Leak ==========")

var loader: Loader? = Loader()

loader?.load()

loader = nil

// Later: Loaded → Loader deinit (freed after the block runs)


//==============================================================
// MARK: - 04. Non-Escaping Never Leaks
//==============================================================
//
// map, filter, forEach run immediately → nothing stored → no cycle.
// [weak self] is unnecessary here.
//

final class Cart {

    let prices = [10, 20, 30]

    let tax = 2

    func totals() -> [Int] {
        prices.map { $0 + tax }          // implicit self — safe
    }

    deinit {
        print("Cart deinit")
    }
}

print("\n========== 04 - Non-Escaping Never Leaks ==========")

var cart: Cart? = Cart()

print(cart?.totals() as Any)             // Optional([12, 22, 32])

cart = nil                               // Cart deinit


//==============================================================
// MARK: - 05. Common Real-World Sources
//==============================================================
//
// Timer.scheduledTimer(withTimeInterval:repeats: true) { self... }
//   → the run loop keeps the timer, the timer keeps self → invalidate() + [weak self]
//
// NotificationCenter.addObserver(forName:...) { self... }
//   → the token keeps the closure → [weak self] + removeObserver
//
// Combine: publisher.sink { self... }.store(in: &cancellables)
//   → self owns cancellables → [weak self]
//
// lazy var handler = { self... }
//   → self stores the closure → [weak self]
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. How does a closure create a retain cycle?
//    → self stores the closure and the closure strongly captures self.
//
// 2. How do you fix it?
//    → [weak self] (or [unowned self] if self always outlives the closure).
//
// 3. Does every escaping closure cause a leak?
//    → No. Only when self stores it. DispatchQueue.async just delays deinit.
//
// 4. Do you need [weak self] in map / filter / forEach?
//    → No. They are non-escaping — nothing is stored.
//
// 5. [weak self] vs [unowned self]?
//    → weak → Optional, safe. unowned → crashes if self is already freed.
//
// 6. Where do closure cycles appear in real iOS code?
//    → Timers, NotificationCenter blocks, Combine sink, stored completion handlers.
//
//==============================================================
