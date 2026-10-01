import Foundation

// ============================================================
// MARK: - CRASH DEBUGGING
// ============================================================

/*
 A crash = the app is terminated by a runtime trap, an
 unhandled exception, a bad memory access, or the system
 (watchdog / out of memory).

 Senior answer = a PROCESS:
 Symbolicated crash log → crashed thread → your top frame
 → reproduce → fix → guard → monitor.

 The crashing lines below are COMMENTED OUT so the playground
 keeps running — each one is shown with its safe version.
*/


// ============================================================
// MARK: - 1. Common Crash Types
// ============================================================

/*
 ┌───────────────────────────┬─────────────────────────────────────────┐
 │ Crash log says            │ Usually means                           │
 ├───────────────────────────┼─────────────────────────────────────────┤
 │ EXC_BREAKPOINT / SIGTRAP  │ Swift runtime trap: force unwrap nil,   │
 │                           │ index out of range, fatalError, as!     │
 │ EXC_BAD_ACCESS            │ Accessing freed / invalid memory        │
 │                           │ (unowned, unsafe pointers, races)       │
 │ SIGABRT + NSException     │ Obj-C exception: unrecognized selector, │
 │                           │ table view update inconsistency         │
 │ 0x8badf00d                │ Watchdog — main thread blocked too long │
 │ Jetsam (no crash log)     │ Killed for using too much memory        │
 └───────────────────────────┴─────────────────────────────────────────┘
*/


// ============================================================
// MARK: - 2. Force Unwrap of nil
// ============================================================

let apiPrice: String? = nil

// let price = Double(apiPrice!)!                          ❌ Fatal error: Unexpectedly found nil

if let text = apiPrice, let price = Double(text) {
    print("DEBUG Q01 - Price:", price)
} else {
    print("DEBUG Q01 - ✅ No price — show placeholder instead of crashing")
}


// ============================================================
// MARK: - 3. Index Out of Range
// ============================================================

let products = ["Shoes", "Cap"]

// let third = products[2]                                 ❌ Fatal error: Index out of range

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}

if let third = products[safe: 2] {
    print("DEBUG Q02 - Third:", third)
} else {
    print("DEBUG Q02 - ✅ Index 2 doesn't exist — handled safely")
}


// ============================================================
// MARK: - 4. Force Cast
// ============================================================

let payload: Any = "42"

// let count = payload as! Int                             ❌ Could not cast value of type 'String' to 'Int'

if let count = payload as? Int {
    print("DEBUG Q03 - Count:", count)
} else {
    print("DEBUG Q03 - ✅ Unexpected type — handled with as?")
}


// ============================================================
// MARK: - 5. Integer Overflow
// ============================================================

let big = Int.max

// let next = big + 1                                      ❌ Arithmetic overflow

let (result, didOverflow) = big.addingReportingOverflow(1)

print("DEBUG Q04 - ✅ Overflow detected:", didOverflow, "| result:", result)


// ============================================================
// MARK: - 6. Crashes You Can't Show in a Playground
// ============================================================

/*
 ❌ UITableView "Invalid update: invalid number of rows"
    → model changed but insertRows/deleteRows didn't match
    → update the data source FIRST, then the table (or use diffable)

 ❌ EXC_BAD_ACCESS with unowned
    → object freed, unowned reference used → use weak

 ❌ UI from a background thread
    → Main Thread Checker flags it → update UI on main

 ❌ Data race (two threads mutate a dictionary)
    → random EXC_BAD_ACCESS → actor / serial queue; Thread Sanitizer finds it

 ❌ Unrecognized selector (Obj-C / #selector typo)
    → SIGABRT with NSInvalidArgumentException
*/


// ============================================================
// MARK: - 7. Reading a Crash Log
// ============================================================

/*
 Exception Type:   EXC_BREAKPOINT (SIGTRAP)       ← what kind of crash
 Crashed Thread:   0  (main thread)               ← where
 Thread 0 Crashed:
 0  MyApp   ProductViewModel.price(for:) + 84     ← first frame in YOUR code
 1  MyApp   ProductViewController.configure()
 2  UIKitCore ...

 Steps:
 1. Make sure it's SYMBOLICATED (needs the build's dSYM) —
    otherwise you only see memory addresses
 2. Read the exception type
 3. Find the crashed thread
 4. Find the first frame in your own code
 5. Check "Last Exception Backtrace" for Obj-C exceptions
*/


// ============================================================
// MARK: - 8. Tools
// ============================================================

/*
 Exception / Swift Error breakpoint  → stop exactly where it throws
 Zombies                             → find messages to freed objects
 Address Sanitizer                   → memory corruption, use-after-free
 Thread Sanitizer                    → data races
 Main Thread Checker                 → UI updates off main
 Xcode Organizer → Crashes           → real-user crashes, symbolicated
 Firebase Crashlytics                → crash-free %, breadcrumbs, custom keys
 MetricKit (MXCrashDiagnostic)       → crash reports in your own pipeline
*/


// ============================================================
// MARK: - 9. Defensive Coding
// ============================================================

/*
 ✅ if let / guard let instead of !
 ✅ as? instead of as!
 ✅ Safe subscripts for untrusted indices
 ✅ assertionFailure → stops in DEBUG, continues in RELEASE
 ✅ precondition only for true programmer errors
 ✅ Decode API data defensively (optional fields, defaults)
 ❌ Hiding real bugs — log them (non-fatal) so you can fix them
*/

func validateQuantity(_ quantity: Int) -> Int {
    guard quantity >= 0 else {
        // assertionFailure("Negative quantity")          // would stop in Debug builds
        print("DEBUG Q05 - ⚠️ Negative quantity logged, clamped to 0")
        return 0
    }
    return quantity
}

_ = validateQuantity(-3)


// ============================================================
// MARK: - 10. Investigation Flow
// ============================================================

/*
 1. Get the symbolicated crash (Organizer / Crashlytics)
 2. Read exception type + crashed thread + your top frame
 3. Check how many users / which OS / which app version
 4. Reproduce (steps, device, data, breadcrumbs)
 5. Fix the root cause — not just the symptom
 6. Add a test / guard so it can't come back
 7. Ship and watch the crash-free rate
*/


// ============================================================
// MARK: - 11. Senior Interview Questions
// ============================================================

/*
 Q1. How do you debug a production crash?

 Answer:
 Get the symbolicated crash log, find the crashed thread and
 the first frame in my code, reproduce it, fix the root
 cause, add a guard or test, then monitor the crash-free rate.


 Q2. What is symbolication?

 Answer:
 Turning memory addresses in a crash log into function names
 and line numbers using the build's dSYM file.


 Q3. EXC_BAD_ACCESS vs EXC_BREAKPOINT?

 Answer:
 BAD_ACCESS is invalid memory (freed object, unowned, race);
 BREAKPOINT is a Swift runtime trap (force unwrap, index,
 fatalError).


 Q4. Common Swift crash causes?

 Answer:
 Force unwraps, index out of range, force casts, unowned
 references, and UI updates off the main thread.


 Q5. What is 0x8badf00d?

 Answer:
 A watchdog termination — the main thread was blocked too
 long (often at launch).


 Q6. Which tools find memory and threading crashes?

 Answer:
 Zombies and Address Sanitizer for memory; Thread Sanitizer
 for data races; Main Thread Checker for UI off main.


 Q7. assertionFailure vs fatalError?

 Answer:
 assertionFailure stops only in Debug; fatalError always
 crashes, even in Release.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Crash reported
        ↓
   Symbolicated log (dSYM)
        ↓
   Exception type → crashed thread → YOUR top frame
        ↓
   Reproduce
        ↓
   Fix root cause → add guard / test
        ↓
   Monitor crash-free rate


 Remember:

 !    → crash risk      → if let / guard let
 as!  → crash risk      → as?
 [i]  → crash risk      → bounds check
*/
