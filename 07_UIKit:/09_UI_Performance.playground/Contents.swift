import UIKit

//==============================================================
// MARK: - UI Performance
//==============================================================
//
// Smooth UI = every frame finished on time.
// Keep the main thread for UI only — move heavy work off it.
//
// Related topics (not repeated here):
// Main thread / background work → 04_Swift_Concurrency
// Cell reuse                    → 05_Cell_Reuse
// Dynamic cell height           → 07_Dynamic_Cell_Height
// setNeedsLayout / layoutIfNeeded → 11_Layout_Cycle
//


//==============================================================
// MARK: - 01. Frame Budget
//==============================================================
//
// 60 Hz  → 16.67 ms per frame
// 120 Hz → 8.33 ms per frame (ProMotion)
// Miss the deadline → hitch (dropped frame) → scrolling stutters.
//

print("\n========== 01 - Frame Budget ==========")

let refreshRates = [60.0, 120.0]

for rate in refreshRates {
    print("\(Int(rate)) Hz → \(String(format: "%.2f", 1000 / rate)) ms per frame")
}


//==============================================================
// MARK: - 02. Reuse Expensive Objects
//==============================================================
//
// DateFormatter / NumberFormatter are expensive to CREATE.
// ❌ New formatter in cellForRowAt → paid on every cell, every scroll.
// ✅ Create once, reuse.
//

enum Formatters {

    static let price: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "INR"
        return formatter
    }()
}

print("\n========== 02 - Reuse Expensive Objects ==========")

let clock = ContinuousClock()

let newEachTime = clock.measure {
    for price in 0..<2_000 {
        let formatter = NumberFormatter()           // ❌ created every time
        formatter.numberStyle = .currency
        _ = formatter.string(from: NSNumber(value: price))
    }
}

let reused = clock.measure {
    for price in 0..<2_000 {
        _ = Formatters.price.string(from: NSNumber(value: price))   // ✅ reused
    }
}

print("New each time:", newEachTime)                 // much slower

print("Reused:       ", reused)                      // several times faster


//==============================================================
// MARK: - 03. Image Size & Decoding
//==============================================================
//
// Decoded image memory = width × height × 4 bytes — file size doesn't matter.
// Decoding happens on MAIN at first draw → hitch.
// ✅ Downsample / prepare a thumbnail off main before display.
//

func memoryMB(_ size: CGSize, scale: CGFloat) -> Double {
    Double(size.width * scale * size.height * scale * 4) / 1_048_576
}

print("\n========== 03 - Image Size & Decoding ==========")

let rendererFormat = UIGraphicsImageRendererFormat()

rendererFormat.scale = 1

let renderer = UIGraphicsImageRenderer(size: CGSize(width: 3000, height: 3000), format: rendererFormat)

let largeImage = renderer.image { context in
    UIColor.systemBlue.setFill()
    context.fill(CGRect(x: 0, y: 0, width: 3000, height: 3000))
}

print("Full image:", String(format: "%.1f MB", memoryMB(largeImage.size, scale: largeImage.scale)))   // ~34.3 MB

let thumbnail = largeImage.preparingThumbnail(of: CGSize(width: 300, height: 300))

if let thumbnail {
    print("Thumbnail: ", String(format: "%.2f MB", memoryMB(thumbnail.size, scale: thumbnail.scale))) // ~0.34 MB
}


//==============================================================
// MARK: - 04. Image Loading Flow + Cache
//==============================================================
//
// CDN → right-sized image → async download → decode off main → cache → display
//
// NSCache → in-memory, auto-evicts on memory pressure, thread-safe.
//

final class ImageCache {

    private let cache = NSCache<NSString, UIImage>()

    func set(_ image: UIImage, for key: String) {
        cache.setObject(image, forKey: key as NSString)
    }

    func image(for key: String) -> UIImage? {
        cache.object(forKey: key as NSString)       // ✅ String → NSString
    }
}

print("\n========== 04 - Image Loading Flow + Cache ==========")

let imageCache = ImageCache()

if let thumbnail {
    imageCache.set(thumbnail, for: "product_42")
}

print("Cache hit:", imageCache.image(for: "product_42") != nil)   // true

print("Cache miss:", imageCache.image(for: "product_99") != nil)  // false → download


//==============================================================
// MARK: - 05. Offscreen Rendering
//==============================================================
//
// Some layer effects force an extra render pass every frame.
// ❌ Shadow without shadowPath, masks, cornerRadius + masksToBounds on many cells
// ✅ Set shadowPath explicitly (update it when bounds change)
//

print("\n========== 05 - Offscreen Rendering ==========")

let cardView = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 120))

cardView.layer.shadowOpacity = 0.2

cardView.layer.shadowRadius = 8

print("Shadow path before:", cardView.layer.shadowPath as Any)   // nil ❌ offscreen pass

cardView.layer.shadowPath = UIBezierPath(roundedRect: cardView.bounds, cornerRadius: 12).cgPath

print("Shadow path set:", cardView.layer.shadowPath != nil)     // true ✅


//==============================================================
// MARK: - 06. Keep cellForRowAt Lightweight
//==============================================================
//
// ❌ Avoid inside cellForRowAt:
// Large JSON parsing, database queries, heavy calculations,
// image resizing, synchronous network calls, creating formatters.
//
// ✅ Pre-format text in the ViewModel — the cell only assigns values.
//


//==============================================================
// MARK: - 07. Targeted Table Updates
//==============================================================
//
// ❌ tableView.reloadData() for one changed row → every visible cell reconfigured
// ✅ tableView.reloadRows(at: [indexPath], with: .automatic)
// ✅ Diffable data source → only changed items are updated
//


//==============================================================
// MARK: - 08. Common Performance Problems
//==============================================================

print("\n========== 08 - Common Performance Problems ==========")

let problems = [
    "Heavy work on the main thread",
    "Expensive cell configuration",
    "Large image decoding on main",
    "Oversized images (memory spikes)",
    "Offscreen rendering (shadows, masks)",
    "Too many layout passes",
    "Unnecessary reloadData()",
    "Missing image caching"
]

for problem in problems {
    print("•", problem)
}


//==============================================================
// MARK: - 09. Instruments
//==============================================================

print("\n========== 09 - Instruments ==========")

let instruments = [
    "Time Profiler      → CPU-heavy code on main",
    "Animation Hitches  → which frames were missed and why",
    "Allocations        → memory spikes (images)",
    "Leaks              → memory leaks",
    "Simulator → Debug → Color Offscreen-Rendered / Blended Layers"
]

for instrument in instruments {
    print(instrument)
}


//==============================================================
// MARK: - 10. Debugging Flow
//==============================================================

print("\n========== 10 - Debugging Flow ==========")

print("""
1. Reproduce the issue (real device, release build)
2. Measure with Instruments
3. Identify the actual bottleneck
4. Fix that bottleneck
5. Measure again
""")


//==============================================================
// MARK: - 11. Senior Mental Model
//==============================================================

print("\n========== 11 - Senior Mental Model ==========")

print("""
Frame budget (16.67 / 8.33 ms)
     ↓
Main thread only does UI
     ↓
Cheap cells + right-sized, cached images
     ↓
No offscreen rendering, no extra layout / reloads
     ↓
Measure with Instruments — don't guess
""")


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is the frame budget?
//    → 16.67 ms at 60 Hz, 8.33 ms at 120 Hz — miss it and a frame drops.
//
// 2. Why does scrolling stutter?
//    → Heavy work on main: image decoding, formatting, layout, or offscreen rendering.
//
// 3. How much memory does an image take?
//    → Width × height × 4 bytes when decoded — file size doesn't matter.
//
// 4. How do you load large images efficiently in cells?
//    → Right-sized from CDN, downsample off main, cache with NSCache, check reuse.
//
// 5. Why NSCache instead of a Dictionary?
//    → Auto-evicts on memory pressure and is thread-safe.
//
// 6. What causes offscreen rendering?
//    → Shadows without shadowPath, masks, cornerRadius with masksToBounds.
//
// 7. Why is creating a DateFormatter in cellForRowAt bad?
//    → Formatters are expensive to create — make one and reuse it.
//
// 8. How do you debug a performance problem?
//    → Reproduce, measure with Instruments, fix the real bottleneck, measure again.
//
//==============================================================
