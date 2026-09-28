import Foundation

//==============================================================
// MARK: - Concurrency Basics
//==============================================================
//
// Thread      → a path of execution the CPU runs.
// Queue       → a list of work; GCD decides which thread runs it.
// Main thread → the only thread allowed to update UI.
// Rule: heavy work in the background, UI updates back on main.
//


//==============================================================
// MARK: - 01. Main Thread
//==============================================================
//
// App code starts on main. UIKit / SwiftUI must be touched only here.
//

print("\n========== 01 - Main Thread ==========")

print("Is main:", Thread.isMainThread)          // true


//==============================================================
// MARK: - 02. Background Work
//==============================================================
//
// Move slow work off main so the UI stays responsive.
// Hop back to main to update UI.
//

print("\n========== 02 - Background Work ==========")

DispatchQueue.global().async {

    print("Background — is main:", Thread.isMainThread)   // false

    DispatchQueue.main.async {
        print("Back on main:", Thread.isMainThread)       // true
    }
}

print("Main continues immediately")

// Output order:
// Main continues immediately
// Background — is main: false
// Back on main: true


//==============================================================
// MARK: - 03. Concurrency vs Parallelism
//==============================================================
//
// Concurrency → multiple tasks in progress, switching between them
//               (possible on a single core).
// Parallelism → multiple tasks running at the SAME instant
//               (needs multiple cores).
//
// iOS gives you concurrency; the system decides if it's parallel.
//


//==============================================================
// MARK: - 04. Blocking the Main Thread
//==============================================================
//
// Main runs the UI at 60/120 fps → ~16 / 8 ms per frame.
// Long work on main (network, JSON, image decode) → frozen UI, dropped frames.
// > 5 s hang on launch → watchdog kills the app.
//
// ❌ let data = try Data(contentsOf: remoteURL)   // on main — blocks UI
// ✅ URLSession / Task { } → work off main, then update UI on main
//


//==============================================================
// MARK: - 05. GCD vs Swift Concurrency
//==============================================================
//
// ┌──────────────────┬──────────────────────────┬─────────────────────────────┐
// │                  │ GCD                      │ Swift Concurrency           │
// ├──────────────────┼──────────────────────────┼─────────────────────────────┤
// │ Style            │ Closures, callbacks      │ async / await               │
// │ Thread safety    │ Manual (queues, locks)   │ Actors, compile-time checks │
// │ Cancellation     │ Manual                   │ Built-in (Task.cancel)      │
// │ UI updates       │ DispatchQueue.main.async │ @MainActor                  │
// │ Thread explosion │ Possible                 │ Limited thread pool         │
// └──────────────────┴──────────────────────────┴─────────────────────────────┘
//
// New code → Swift Concurrency. Still know GCD — it's in every older codebase.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Thread vs queue?
//    → A thread runs code; a queue holds work and GCD assigns it to threads.
//
// 2. Why must UI updates happen on the main thread?
//    → UIKit / SwiftUI aren't thread-safe; the main run loop drives rendering.
//
// 3. Concurrency vs parallelism?
//    → Concurrency = many tasks in progress. Parallelism = running at the same instant.
//
// 4. What happens if you block the main thread?
//    → Frozen UI, dropped frames; long hangs get the app killed by the watchdog.
//
// 5. GCD vs Swift Concurrency?
//    → GCD = closures + manual safety. Swift Concurrency = async/await, actors, built-in cancellation.
//
//==============================================================
