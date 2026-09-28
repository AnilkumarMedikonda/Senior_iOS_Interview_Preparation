import Foundation

//==============================================================
// MARK: - Weak Self
//==============================================================
//
// [weak self] → closure doesn't keep self alive.
// Inside, self is Optional → unwrap with guard let self or self?.
// Use it when a closure is STORED or may OUTLIVE self.
//


//==============================================================
// MARK: - 01. guard let self vs self?
//==============================================================
//
// guard let self → one check, self stays alive for the whole block.
// self?.         → checked on every line; later lines may skip.
//

final class ProfileViewModel {

    var name = "Anil"

    var onRefresh: (() -> Void)?

    func bindGuard() {
        onRefresh = { [weak self] in
            guard let self else { return }
            self.name = "Updated"
            print("guard:", self.name)
        }
    }

    func bindOptional() {
        onRefresh = { [weak self] in
            self?.name = "Updated"
            print("optional:", self?.name as Any)
        }
    }

    deinit {
        print("ProfileViewModel deinit")
    }
}

print("\n========== 01 - guard let self vs self? ==========")

var profileVM: ProfileViewModel? = ProfileViewModel()

profileVM?.bindGuard()

profileVM?.onRefresh?()                  // guard: Updated

profileVM?.bindOptional()

profileVM?.onRefresh?()                  // optional: Optional("Updated")

profileVM = nil                          // ProfileViewModel deinit


//==============================================================
// MARK: - 02. self Freed Before the Callback
//==============================================================
//
// With [weak self], the callback simply does nothing.
//

@MainActor
final class DetailScreen {

    func loadData() {
        DispatchQueue.main.async { [weak self] in
            guard let self else {
                print("Screen already gone — skip update")
                return
            }
            print("Updating", self)
        }
    }

    deinit {
        print("DetailScreen deinit")
    }
}

print("\n========== 02 - self Freed Before the Callback ==========")

var detailScreen: DetailScreen? = DetailScreen()

detailScreen?.loadData()

detailScreen = nil                       // DetailScreen deinit

// Later: Screen already gone — skip update


//==============================================================
// MARK: - 03. Nested Closures
//==============================================================
//
// Put [weak self] on the OUTER closure.
// Inner closures capture the outer's weak self — no extra list needed.
//

final class FeedScreen {

    var items: [String] = []

    var onLoad: (() -> Void)?

    func setup() {
        onLoad = { [weak self] in
            let addPost = {
                self?.items.append("Post")   // reuses the outer weak self
            }
            addPost()
            print("Items:", self?.items.count as Any)
        }
    }

    deinit {
        print("FeedScreen deinit")
    }
}

print("\n========== 03 - Nested Closures ==========")

var feedScreen: FeedScreen? = FeedScreen()

feedScreen?.setup()

feedScreen?.onLoad?()                    // Items: Optional(1)

feedScreen = nil                         // FeedScreen deinit


//==============================================================
// MARK: - 04. When You Need It — and When You Don't
//==============================================================
//
// ✅ NEED [weak self]
// Stored closures (onTap, completion properties)
// Long network callbacks — user may leave the screen
// Timers, NotificationCenter blocks, Combine sink
// Task { } with long-running work or loops
//
// ❌ DON'T NEED [weak self]
// Non-escaping closures — map, filter, forEach
// UIView.animate — runs and releases quickly
// Short DispatchQueue.main.async — only delays deinit, no cycle
//
// Rule: ask "does self store this closure, or can it run long after
// the user leaves?" If yes → [weak self].
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Why use [weak self]?
//    → So a stored or long-running closure doesn't keep self alive or create a cycle.
//
// 2. guard let self vs self?.?
//    → guard checks once and keeps self for the block. self? re-checks every line.
//
// 3. What happens if self is freed before the callback runs?
//    → self is nil — the guard exits and the callback does nothing.
//
// 4. Do nested closures each need [weak self]?
//    → No. Put it on the outer closure; inner closures reuse it.
//
// 5. Do you need [weak self] in UIView.animate or map?
//    → No. They don't store the closure, so no cycle.
//
// 6. Is [weak self] always required with DispatchQueue.main.async?
//    → No. It only delays deinit. Use it when the work is long or self may be gone.
//
//==============================================================
