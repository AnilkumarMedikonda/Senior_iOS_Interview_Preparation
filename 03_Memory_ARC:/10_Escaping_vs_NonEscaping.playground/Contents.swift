import Foundation

//==============================================================
// MARK: - Escaping vs Non-Escaping (Memory View)
//==============================================================
//
// Non-escaping (default) → runs before the function returns → can't leak.
// @escaping → can be stored or run later → may keep self alive.
// Syntax basics → 01_Swift_Fundamentals/06_Closures
//


//==============================================================
// MARK: - 01. Non-Escaping — No Memory Risk
//==============================================================
//
// Closure is gone when the function returns.
// Can't be stored. self can be implicit. No [weak self] needed.
//

func runNow(_ work: () -> Void) {
    work()
    // saved = work                      ❌ non-escaping can't be stored
}

final class ReportScreen {

    let title = "Report"

    func build() {
        runNow {
            print("Building", title)     // implicit self — safe
        }
    }

    deinit {
        print("ReportScreen deinit")
    }
}

print("\n========== 01 - Non-Escaping ==========")

var reportScreen: ReportScreen? = ReportScreen()

reportScreen?.build()                    // Building Report

reportScreen = nil                       // ReportScreen deinit


//==============================================================
// MARK: - 02. Escaping + Stored by self — Cycle Risk
//==============================================================
//
// self stores the closure, closure captures self → cycle.
// Fix: [weak self].
//

final class CartViewModel {

    var items = 0

    var onChange: (() -> Void)?

    func bindLeaking() {
        onChange = {
            print("Items:", self.items)  // ❌ self → onChange → self
        }
    }

    func bindSafe() {
        onChange = { [weak self] in
            guard let self else { return }
            print("Items:", self.items)  // ✅
        }
    }

    deinit {
        print("CartViewModel deinit")
    }
}

print("\n========== 02 - Escaping + Stored by self ==========")

var leakingVM: CartViewModel? = CartViewModel()

leakingVM?.bindLeaking()

leakingVM = nil                          // no deinit — leaked

var safeVM: CartViewModel? = CartViewModel()

safeVM?.bindSafe()

safeVM = nil                             // CartViewModel deinit


//==============================================================
// MARK: - 03. Escaping but Not Stored by self — No Cycle
//==============================================================
//
// Closure is held by the queue, not by self.
// self stays alive until the closure runs → deinit delayed, not lost.
//

@MainActor
final class Uploader {

    func upload() {
        DispatchQueue.main.async {
            print("Upload finished")
            _ = self
        }
    }

    deinit {
        print("Uploader deinit")
    }
}

print("\n========== 03 - Escaping but Not Stored ==========")

var uploader: Uploader? = Uploader()

uploader?.upload()

uploader = nil

// Later: Upload finished → Uploader deinit


//==============================================================
// MARK: - 04. Summary
//==============================================================
//
// ┌──────────────────────────────┬───────────┬─────────────────┐
// │ Closure                      │ Can leak? │ [weak self]?    │
// ├──────────────────────────────┼───────────┼─────────────────┤
// │ Non-escaping (map, forEach)  │ No        │ Not needed      │
// │ Escaping, stored by self     │ Yes       │ Required        │
// │ Escaping, held elsewhere     │ No*       │ If work is long │
// └──────────────────────────────┴───────────┴─────────────────┘
// * Delays deinit until the closure runs.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Why can't a non-escaping closure cause a retain cycle?
//    → It finishes before the function returns — nothing is stored.
//
// 2. When does an escaping closure create a cycle?
//    → When self stores the closure and the closure captures self strongly.
//
// 3. Does DispatchQueue.main.async { self... } leak?
//    → No. The queue holds it, not self — deinit is only delayed.
//
// 4. Why must escaping closures use self explicitly?
//    → To make the capture of self a visible, deliberate choice.
//
// 5. Why are closure parameters non-escaping by default?
//    → Safer and faster — no heap storage, no retain risk.
//
//==============================================================
