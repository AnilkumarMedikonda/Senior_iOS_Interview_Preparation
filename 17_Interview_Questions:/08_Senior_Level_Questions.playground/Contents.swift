import Foundation
import os
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - 07_PERFORMANCE_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Each question:
 1. Question + short spoken answer
 2. Follow-up the interviewer usually asks
 3. A tiny code proof with DEBUG output

 Instruments run in Xcode — these proofs show the PROBLEMS
 the instruments would find.
*/


// ============================================================
// MARK: - Q01. Diagnosing Slow Scrolling
// ============================================================

/*
 Q: How would you diagnose slow scrolling?

 Answer:
 Real device + Release → Animation Hitches + Time Profiler →
 heaviest main-thread work → fix one thing → measure again.
*/

let processSteps = ["Reproduce", "Measure", "Find bottleneck", "Fix one thing", "Measure again"]

print("DEBUG Q01 -", processSteps.joined(separator: " → "))


// ============================================================
// MARK: - Q02. Frame Budget
// ============================================================

/*
 Q: What is the frame budget?

 Answer:
 60 Hz → 16.67 ms, 120 Hz → 8.33 ms.
*/

for hz in [60.0, 120.0] {
    print("DEBUG Q02 - \(Int(hz)) Hz →", String(format: "%.2f ms per frame", 1000 / hz))
}


// ============================================================
// MARK: - Q03. Image Memory
// ============================================================

/*
 Q: How do you make images fast in a list?

 Answer:
 Right size from server, downsample off main, NSCache with
 cost, cancel on reuse.

 Follow-up: image memory?
 → width × height × 4 bytes.
*/

func decodedMB(_ width: Double, _ height: Double) -> Double {
    width * height * 4 / 1_048_576
}

print("DEBUG Q03 - 3000×3000 decoded:", String(format: "%.1f MB", decodedMB(3000, 3000)))   // ~34 MB

print("DEBUG Q03 - 300×300 thumbnail:", String(format: "%.2f MB", decodedMB(300, 300)))     // ~0.34 MB

let imageCache = NSCache<NSString, NSData>()

imageCache.totalCostLimit = 50 * 1_048_576                  // cost = decoded bytes


// ============================================================
// MARK: - Q04. Offscreen Rendering
// ============================================================

/*
 Q: What is offscreen rendering?

 Answer:
 Shadow without shadowPath, masks, cornerRadius +
 masksToBounds → extra render pass every frame.
 Fix: set layer.shadowPath explicitly.
*/

print("DEBUG Q04 - layer.shadowPath = UIBezierPath(roundedRect:…).cgPath")


// ============================================================
// MARK: - Q05. Cheap Cell Configuration
// ============================================================

/*
 Q: How should cellForRowAt look?

 Answer:
 Dequeue + assign pre-formatted values + async image load.
 No formatter creation, parsing, or sync work.
*/

let clock = ContinuousClock()

let slow = clock.measure {
    for price in 0..<2_000 {
        let formatter = NumberFormatter()                    // ❌ per "cell"
        formatter.numberStyle = .currency
        _ = formatter.string(from: NSNumber(value: price))
    }
}

let sharedFormatter = NumberFormatter()

sharedFormatter.numberStyle = .currency

let fast = clock.measure {
    for price in 0..<2_000 {
        _ = sharedFormatter.string(from: NSNumber(value: price))   // ✅ reused
    }
}

print("DEBUG Q05 - ❌ formatter per cell:", slow, "| ✅ shared:", fast)


// ============================================================
// MARK: - Q06. SwiftUI Performance
// ============================================================

/*
 Q: Heavy SwiftUI screen?

 Answer:
 Cheap body, small views, @Observable, stable IDs,
 lazy stacks, _printChanges.
*/

print("DEBUG Q06 - split views → unchanged inputs skip body")


// ============================================================
// MARK: - Q07. Memory Leak
// ============================================================

/*
 Q: Leaks — causes and finding?

 Answer:
 Retain cycles. deinit check → Memory Graph / Leaks.
*/

final class LeakyScreen {

    var onReload: (() -> Void)?

    func setup() {
        onReload = { self.reload() }                        // ❌ strong self
    }

    func reload() {}

    deinit { print("LeakyScreen deinit") }                  // never prints
}

final class FixedScreen {

    var onReload: (() -> Void)?

    func setup() {
        onReload = { [weak self] in self?.reload() }        // ✅ weak self
    }

    func reload() {}

    deinit { print("DEBUG Q07 - ✅ FixedScreen deinit") }
}

var leaky: LeakyScreen? = LeakyScreen()

leaky?.setup()

leaky = nil

print("DEBUG Q07 - ❌ LeakyScreen: no deinit → leak")

var fixed: FixedScreen? = FixedScreen()

fixed?.setup()

fixed = nil


// ============================================================
// MARK: - Q08. Memory Growth (Unbounded Cache)
// ============================================================

/*
 Q: Memory keeps growing?

 Answer:
 Allocations + Mark Generation. Common: full-size images,
 unbounded caches.

 Follow-up: leak vs abandoned?
 → Unreachable vs reachable-but-unused.
*/

var unboundedCache: [Int: Data] = [:]                        // ❌ never evicts

for id in 0..<100 {
    unboundedCache[id] = Data(count: 10_000)
}

print("DEBUG Q08 - ❌ dictionary cache entries:", unboundedCache.count, "(abandoned memory)")

let boundedCache = NSCache<NSNumber, NSData>()

boundedCache.countLimit = 20                                 // ✅ evicts

print("DEBUG Q08 - ✅ NSCache countLimit:", boundedCache.countLimit)


// ============================================================
// MARK: - Q09. Jetsam
// ============================================================

/*
 Q: What is jetsam?

 Answer:
 System kills the app for too much memory — no normal
 crash log; see Organizer memory reports.
*/

print("DEBUG Q09 - jetsam = killed for memory, not a code crash")


// ============================================================
// MARK: - Q10. Hang
// ============================================================

/*
 Q: Hang — what and how to fix?

 Answer:
 Main thread blocked ~250 ms+. Pause debugger / Hangs
 instrument → move work off main.
*/

func slowWork() -> Int {
    Thread.sleep(forTimeInterval: 0.3)
    return 42
}

let blocked = clock.measure {
    _ = slowWork()                                           // ❌ on main
}

print("DEBUG Q10 - ❌ main blocked:", blocked)


// ============================================================
// MARK: - Q11. Launch Time
// ============================================================

/*
 Q: Improve launch time?

 Answer:
 Defer SDK setup, no sync I/O / network before first frame,
 lazy features, App Launch instrument.

 Follow-up: 0x8badf00d?
 → Watchdog kill — main blocked too long.
*/

print("DEBUG Q11 - launch: show UI first, initialize the rest later")


// ============================================================
// MARK: - Q12–Q13. Instruments + Real Device
// ============================================================

/*
 Q12: Which tool?
 Time Profiler (CPU) · Animation Hitches (jank) ·
 Allocations (growth) · Leaks · Hangs · App Launch · Energy

 Q13: Why real device + Release?
 → Simulator / Debug performance is misleading.
*/

let toolMap = [
    ("Slow / CPU", "Time Profiler"),
    ("Janky scroll", "Animation Hitches"),
    ("Memory grows", "Allocations"),
    ("Never freed", "Leaks / Memory Graph"),
    ("UI frozen", "Hangs")
]

for (symptom, tool) in toolMap {
    print("DEBUG Q12 -", symptom, "→", tool)
}


// ============================================================
// MARK: - Q14. Measuring Your Own Code
// ============================================================

/*
 Q: Measure your own code?

 Answer:
 OSSignposter intervals → Instruments timeline;
 measure { } in tests.
*/

let signposter = OSSignposter(subsystem: "com.shop.app", category: .pointsOfInterest)

let interval = signposter.beginInterval("Parse")

let parsed = (1...5_000).map { "Item \($0)" }

signposter.endInterval("Parse", interval)

print("DEBUG Q14 - signpost around parsing \(parsed.count) items")


// ============================================================
// MARK: - Q15–Q16. Crashes
// ============================================================

/*
 Q15: Production crash?
 → Symbolicated log → crashed thread → my top frame →
   reproduce → fix root cause → guard / test → monitor.

 Q16: BAD_ACCESS vs BREAKPOINT?
 → Invalid memory vs Swift runtime trap.
*/

let items = ["Shoes", "Cap"]

// let third = items[2]                                     ❌ EXC_BREAKPOINT: Index out of range

let index = 2

if items.indices.contains(index) {
    print("DEBUG Q16 -", items[index])
} else {
    print("DEBUG Q16 - ✅ index \(index) out of range — handled, no crash")
}


// ============================================================
// MARK: - Q17. Battery & Network
// ============================================================

/*
 Q: Reduce battery / data?

 Answer:
 Batch + cache requests, no polling, system-scheduled
 background tasks, lower location accuracy, stop work
 when screens disappear.
*/

print("DEBUG Q17 - 10 small requests → 1 batched request")


// ============================================================
// MARK: - Q10 Fix (async) — Move Work Off Main
// ============================================================

Task { @MainActor in

    let start = ContinuousClock.now

    let work = Task.detached { slowWork() }                  // ✅ background

    print("DEBUG Q10 - ✅ main free after:", ContinuousClock.now - start)

    print("DEBUG Q10 - ✅ result back on main:", await work.value)

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Symptom → Instrument → Real device + Release → Fix one thing → Measure

   Janky   → main-thread work (images, formatters, layout, offscreen)
   Growing → Allocations (images, unbounded caches)
   Leaking → deinit + Memory Graph (retain cycles)
   Frozen  → pause on main thread → move work off main
   Crash   → symbolicated log → top frame → root cause


 Senior One-Liner:

 "I never guess — I reproduce on a real device in Release,
  measure with the right instrument, fix the real bottleneck
  on the main thread or in memory, and measure again."
*/
