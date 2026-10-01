import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - MEMORY LEAKS & HANGS
// ============================================================

/*
 Memory leak:
 An object that is no longer needed but is NEVER freed.
 In Swift, almost always a RETAIN CYCLE (ARC can't break it).

 Hang:
 The MAIN THREAD is blocked, so the UI can't respond.
 ~250 ms → user notices.  Several seconds → watchdog may kill the app.
*/


// ============================================================
// MARK: - 1. ❌ Leak — Closure Captures self Strongly
// ============================================================

/*
 self → closure (stored property)
 closure → self (strong capture)
 = cycle → deinit never runs
*/

final class LeakyScreen {

    var onReload: (() -> Void)?

    func setup() {
        onReload = {
            self.reload()                                    // ❌ strong self
        }
    }

    func reload() {}

    deinit {
        print("LeakyScreen deinit")                          // never prints
    }
}

var leaky: LeakyScreen? = LeakyScreen()

leaky?.setup()

leaky = nil

print("DEBUG Q01 - ❌ LeakyScreen set to nil — no deinit → LEAK")


// ============================================================
// MARK: - 2. ✅ Fix — [weak self]
// ============================================================

final class FixedScreen {

    var onReload: (() -> Void)?

    func setup() {
        onReload = { [weak self] in
            self?.reload()                                   // ✅ weak self
        }
    }

    func reload() {}

    deinit {
        print("DEBUG Q02 - ✅ FixedScreen deinit")
    }
}

var fixed: FixedScreen? = FixedScreen()

fixed?.setup()

fixed = nil


// ============================================================
// MARK: - 3. ❌ Leak — Strong Delegate
// ============================================================

/*
 Screen → Cell (strong)
 Cell → delegate = Screen (strong)
 = cycle
*/

protocol CellDelegate: AnyObject {}

final class Cell {

    var delegate: CellDelegate?                              // ❌ should be weak
}

final class ListScreen: CellDelegate {

    let cell = Cell()

    init() {
        cell.delegate = self
    }

    deinit {
        print("ListScreen deinit")                           // never prints
    }
}

var list: ListScreen? = ListScreen()

list = nil

print("DEBUG Q03 - ❌ Strong delegate — no deinit → LEAK  (fix: weak var delegate)")


// ============================================================
// MARK: - 4. Common Leak Sources in iOS
// ============================================================

/*
 ❌ Stored closures capturing self        → [weak self]
 ❌ Strong delegate                        → weak var delegate
 ❌ Timer.scheduledTimer(target: self)     → invalidate() / block timer with [weak self]
 ❌ NotificationCenter block observer      → removeObserver(token), [weak self]
 ❌ Combine sink capturing self            → [weak self] / cancel
 ❌ Parent ↔ child both strong             → child holds parent weakly
 ❌ Child coordinators never removed       → removeChild when finished

 Not a leak but same symptom ("abandoned memory"):
 ❌ Unbounded cache / array that only grows → NSCache, limits
*/


// ============================================================
// MARK: - 5. Finding Leaks
// ============================================================

/*
 1. deinit log         → quickest check: leave the screen, deinit should print
 2. Memory Graph       → Xcode Debug Navigator / ⚠️ purple "!" = leaked object,
                         follow the arrows to see who holds it
 3. Leaks instrument   → finds unreachable objects while you use the app
 4. Allocations        → Mark Generation: open + close screen 5×;
                         memory that stays = not released
*/


// ============================================================
// MARK: - 6. ❌ Hang — Blocking the Main Thread
// ============================================================

/*
 Anything slow on main blocks touches, scrolling, animations.
 (Thread.sleep stands in for slow work: sync network, big JSON,
  image decoding, file I/O.)
*/

let clock = ContinuousClock()

func slowWork() -> Int {
    Thread.sleep(forTimeInterval: 0.3)                       // 300 ms of "work"
    return 42
}

let blocked = clock.measure {
    _ = slowWork()                                           // ❌ runs ON main
}

print("DEBUG Q04 - ❌ Main thread blocked for:", blocked, "→ HANG (> 250 ms)")


// ============================================================
// MARK: - 7. ✅ Fix — Move Work Off the Main Thread
// ============================================================

/*
 Do slow work in the background, come back to main for UI.
*/

Task { @MainActor in

    let start = ContinuousClock.now

    let work = Task.detached(priority: .userInitiated) {
        slowWork()                                           // ✅ background thread
    }

    let mainFreeAfter = ContinuousClock.now - start          // main is free right away

    print("DEBUG Q05 - ✅ Main thread free after:", mainFreeAfter)

    let result = await work.value                            // suspends — doesn't block

    print("DEBUG Q06 - ✅ Result back on main:", result)     // update UI here

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 8. Common Hang Causes
// ============================================================

/*
 ❌ Synchronous network / file I/O on main
 ❌ Large JSON decoding or image decoding on main
 ❌ DispatchQueue.main.sync from the main thread → deadlock (permanent hang)
 ❌ Waiting on a lock / semaphore on main
 ❌ Huge layout passes (deep stack views, many constraints)
 ❌ Too much work in viewDidLoad / app launch → watchdog kill
*/


// ============================================================
// MARK: - 9. Finding Hangs
// ============================================================

/*
 1. Pause the debugger during the freeze → look at the MAIN thread stack
 2. Hangs instrument / Time Profiler      → long main-thread intervals
 3. Thread Performance Checker (scheme)  → warns about priority inversions
 4. Xcode Organizer → Hangs report       → real users' hang stack traces
 5. MetricKit (MXHangDiagnostic)         → hang reports in your own analytics
*/


// ============================================================
// MARK: - 10. Senior Interview Questions
// ============================================================

/*
 Q1. What causes most memory leaks in Swift?

 Answer:
 Retain cycles — two objects (or an object and a closure)
 holding each other strongly.


 Q2. How do you find a leak?

 Answer:
 Check deinit, then use the Memory Graph Debugger or the
 Leaks instrument to see who holds the object.


 Q3. Name common leak sources.

 Answer:
 Closures capturing self, strong delegates, timers,
 notification observers, Combine sinks, child coordinators.


 Q4. What is a hang?

 Answer:
 The main thread is blocked long enough that the UI stops
 responding — about 250 ms or more.


 Q5. How do you fix a hang?

 Answer:
 Find the main-thread work (pause debugger / Instruments),
 move it to the background, update UI back on main.


 Q6. What is the watchdog?

 Answer:
 iOS kills apps that take too long to launch or respond,
 e.g. heavy synchronous work at startup.


 Q7. Leak vs abandoned memory?

 Answer:
 A leak is unreachable but never freed; abandoned memory
 is still reachable but never used again (e.g. unbounded cache).
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

        MEMORY LEAK

   A ──strong──→ B
   ↑             │
   └───strong────┘     → neither is freed

   Fix: make one side weak / unowned


        HANG

   Main thread: [ slow work ██████████ ] → UI frozen

   Fix: background thread → result → main thread


 Remember:

 deinit not called   → leak    → Memory Graph
 UI frozen           → hang    → pause debugger, main thread
*/
