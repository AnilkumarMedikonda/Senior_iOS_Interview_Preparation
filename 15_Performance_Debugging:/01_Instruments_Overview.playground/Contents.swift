import Foundation
import os

// ============================================================
// MARK: - INSTRUMENTS OVERVIEW
// ============================================================

/*
 Instruments = Xcode's profiling app.

 Open it:  Product → Profile  (⌘I)

 Golden rules:
 - Real device (simulator CPU/GPU/memory are different)
 - Release build (Debug is slower and misleading)
 - Measure → fix ONE thing → measure again

 This playground shows the kinds of problems each
 instrument finds. The instruments run in Xcode, not here.
*/


// ============================================================
// MARK: - 1. Which Instrument for Which Problem?
// ============================================================

/*
 ┌──────────────────────────┬───────────────────────────────────┐
 │ Symptom                  │ Instrument                        │
 ├──────────────────────────┼───────────────────────────────────┤
 │ Slow screen / high CPU   │ Time Profiler                     │
 │ Janky scrolling          │ Animation Hitches + Time Profiler │
 │ Memory keeps growing     │ Allocations                       │
 │ Object never freed       │ Leaks + Memory Graph Debugger     │
 │ UI freezes               │ Hangs                             │
 │ Slow app launch          │ App Launch                        │
 │ Too many network calls   │ Network                           │
 │ Battery drain            │ Energy Log                        │
 │ SwiftUI re-renders       │ SwiftUI instrument                │
 └──────────────────────────┴───────────────────────────────────┘
*/


// ============================================================
// MARK: - 2. Time Profiler — CPU-Heavy Code
// ============================================================

/*
 Time Profiler samples the call stack every ~1 ms and shows
 which functions use the most CPU.

 Call Tree tips:
 - Invert Call Tree        → heaviest functions on top
 - Hide System Libraries   → only YOUR code
 - Separate by Thread      → see what runs on main

 Classic finding: an expensive object created in a loop.
*/

let clock = ContinuousClock()

let slowTime = clock.measure {
    for price in 0..<3_000 {
        let formatter = NumberFormatter()                    // ❌ created every iteration
        formatter.numberStyle = .currency
        _ = formatter.string(from: NSNumber(value: price))
    }
}

let sharedFormatter = NumberFormatter()

sharedFormatter.numberStyle = .currency

let fastTime = clock.measure {
    for price in 0..<3_000 {
        _ = sharedFormatter.string(from: NSNumber(value: price))   // ✅ reused
    }
}

print("DEBUG Q01 - ❌ New formatter each time:", slowTime)

print("DEBUG Q02 - ✅ Reused formatter:", fastTime)

// In Time Profiler, NumberFormatter.init would be at the top of the inverted tree.


// ============================================================
// MARK: - 3. Animation Hitches — Frame Budget
// ============================================================

/*
 Each frame must finish in time:

 60 Hz  → 16.67 ms
 120 Hz →  8.33 ms (ProMotion)

 Work on the main thread longer than that = dropped frame (hitch).
*/

func frameBudget(hz: Double) -> Double {
    1000 / hz
}

let workMs = 25.0                                           // e.g. decoding a big image on main

for hz in [60.0, 120.0] {
    let budget = frameBudget(hz: hz)
    let missed = workMs > budget
    print("DEBUG Q03 - \(Int(hz)) Hz budget \(String(format: "%.2f", budget)) ms → \(Int(workMs)) ms work:", missed ? "❌ hitch" : "✅ smooth")
}


// ============================================================
// MARK: - 4. Allocations — Memory Growth
// ============================================================

/*
 Allocations shows memory over time and WHO allocated it.

 Look for:
 - A graph that only goes up (never comes down)
 - Mark Generation: do an action, go back, mark again —
   memory that stays = not released

 Classic finding: huge decoded images, unbounded caches.
*/

func decodedImageMB(width: Double, height: Double) -> Double {
    width * height * 4 / 1_048_576                           // 4 bytes per pixel
}

print("DEBUG Q04 - 3000×3000 photo in memory:", String(format: "%.1f MB", decodedImageMB(width: 3000, height: 3000)))   // ~34 MB

print("DEBUG Q05 - 300×300 thumbnail:", String(format: "%.2f MB", decodedImageMB(width: 300, height: 300)))             // ~0.34 MB


// ============================================================
// MARK: - 5. Leaks — Objects Never Freed
// ============================================================

/*
 Leaks instrument + Xcode's Memory Graph Debugger find
 objects that are no longer reachable but still alive.

 Fastest everyday check: log in deinit.
 Details → 02_Memory_Leaks_And_Hangs
*/

final class ProductScreen {

    var onTap: (() -> Void)?

    func setup() {
        onTap = { [weak self] in                             // ✅ weak → no cycle
            _ = self
        }
    }

    deinit {
        print("DEBUG Q06 - ProductScreen deinit ✅ (no leak)")
    }
}

var screen: ProductScreen? = ProductScreen()

screen?.setup()

screen = nil


// ============================================================
// MARK: - 6. Points of Interest — Mark Your Own Code
// ============================================================

/*
 OSSignposter marks intervals that show up as a timeline in
 Instruments ("Points of Interest" track).

 Great for measuring: screen load, image decode, JSON parse.
 (Runs silently here — visible only in Instruments.)
*/

let signposter = OSSignposter(subsystem: "com.shop.app", category: .pointsOfInterest)

let state = signposter.beginInterval("Parse Products")

let products = (1...10_000).map { "Product \($0)" }          // the work being measured

signposter.endInterval("Parse Products", state)

print("DEBUG Q07 - Signpost recorded around parsing \(products.count) products")


// ============================================================
// MARK: - 7. Profiling Workflow
// ============================================================

/*
 1. Reproduce the problem (exact steps)
 2. ⌘I → choose the template for the symptom
 3. Record → perform the steps → stop
 4. Find the heaviest / growing / leaking item
 5. Fix ONE thing
 6. Profile again and compare
*/


// ============================================================
// MARK: - 8. Senior Interview Questions
// ============================================================

/*
 Q1. How would you investigate a slow screen?

 Answer:
 Reproduce it, profile on a real device in Release with
 Time Profiler, find the heaviest main-thread work, fix it,
 then measure again.


 Q2. Which instrument for janky scrolling?

 Answer:
 Animation Hitches to see dropped frames, then Time
 Profiler to find what's blocking the main thread.


 Q3. Allocations vs Leaks?

 Answer:
 Allocations shows memory growth and who allocated it;
 Leaks finds objects that are unreachable but never freed.


 Q4. Why profile on a real device in Release?

 Answer:
 The simulator and Debug builds have different
 performance and give misleading results.


 Q5. What is a signpost?

 Answer:
 A marker (OSSignposter) that shows your own code's
 intervals on the Instruments timeline.


 Q6. What is the frame budget?

 Answer:
 16.67 ms at 60 Hz, 8.33 ms at 120 Hz — main-thread work
 longer than that drops a frame.
*/


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Symptom
      ↓
   Pick the instrument
      ↓
   Real device + Release build
      ↓
   Record → find the hot spot
      ↓
   Fix one thing
      ↓
   Measure again


 Remember:

 Slow     → Time Profiler
 Janky    → Animation Hitches
 Growing  → Allocations
 Leaking  → Leaks / Memory Graph
 Frozen   → Hangs
*/
