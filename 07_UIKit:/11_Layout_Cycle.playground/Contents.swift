import UIKit

//==============================================================
// MARK: - Layout Cycle
//==============================================================
//
// Every run loop, UIKit runs up to 3 passes for "dirty" views:
//
//   1. Update Constraints → updateConstraints()   (bottom-up)
//   2. Layout             → layoutSubviews()      (top-down)
//   3. Display            → draw(_:)              (only if setNeedsDisplay)
//
// You MARK views dirty; UIKit does the work once, at the end of the run loop.
//

final class TrackingView: UIView {

    var layoutCount = 0

    override func updateConstraints() {
        print("updateConstraints")
        super.updateConstraints()                    // always call super last here
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        layoutCount += 1
        print("layoutSubviews #\(layoutCount)")
    }
}


//==============================================================
// MARK: - 01. setNeedsLayout Batches
//==============================================================
//
// setNeedsLayout → "lay me out on the next cycle" (cheap, asynchronous).
// Call it 3 times → still ONE layoutSubviews.
//

print("\n========== 01 - setNeedsLayout Batches ==========")

let batchView = TrackingView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))

batchView.layoutIfNeeded()                           // first layout

batchView.setNeedsLayout()

batchView.setNeedsLayout()

batchView.setNeedsLayout()

batchView.layoutIfNeeded()                           // layoutSubviews #2 — once, not 3 times


//==============================================================
// MARK: - 02. layoutIfNeeded Only Works When Dirty
//==============================================================
//
// layoutIfNeeded → "if a layout is pending, do it NOW" (synchronous).
// Nothing marked dirty → nothing happens.
//

print("\n========== 02 - layoutIfNeeded Only When Dirty ==========")

let before = batchView.layoutCount

batchView.layoutIfNeeded()                           // nothing pending

print("Extra layouts:", batchView.layoutCount - before)   // 0


//==============================================================
// MARK: - 03. What Triggers Layout Automatically
//==============================================================
//
// ✅ Size change (frame / bounds size), addSubview, rotation, constraint change
// ❌ Moving the origin only → no layoutSubviews (content doesn't change)
//

print("\n========== 03 - Automatic Triggers ==========")

let moved = batchView.layoutCount

batchView.frame.origin = CGPoint(x: 50, y: 50)       // move only

batchView.layoutIfNeeded()

print("After move:", batchView.layoutCount - moved)       // 0

batchView.frame.size = CGSize(width: 300, height: 300)   // resize

batchView.layoutIfNeeded()                               // layoutSubviews #3

print("After resize:", batchView.layoutCount - moved)     // 1


//==============================================================
// MARK: - 04. Update Constraints Pass
//==============================================================
//
// setNeedsUpdateConstraints → updateConstraints() runs before layout.
// Apple's advice: change constraints directly where they change;
// use updateConstraints only when batching many changes for performance.
//

print("\n========== 04 - Update Constraints Pass ==========")

batchView.setNeedsUpdateConstraints()

batchView.updateConstraintsIfNeeded()               // updateConstraints


//==============================================================
// MARK: - 05. Animating a Constraint Change
//==============================================================
//
// 1. Change the constraint (constant / isActive)
// 2. Call layoutIfNeeded() INSIDE the animation block on the SUPERVIEW
//

print("\n========== 05 - Animating Constraints ==========")

let screen = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 400))

let panel = UIView()

panel.translatesAutoresizingMaskIntoConstraints = false

screen.addSubview(panel)

let panelHeight = panel.heightAnchor.constraint(equalToConstant: 100)

NSLayoutConstraint.activate([
    panel.topAnchor.constraint(equalTo: screen.topAnchor),
    panel.leadingAnchor.constraint(equalTo: screen.leadingAnchor),
    panel.trailingAnchor.constraint(equalTo: screen.trailingAnchor),
    panelHeight
])

screen.layoutIfNeeded()

print("Before:", panel.frame.height)                 // 100

panelHeight.constant = 250                           // 1. change

UIView.animate(withDuration: 0.3) {
    screen.layoutIfNeeded()                          // 2. animate the new layout
}

print("After:", panel.frame.height)                  // 250


//==============================================================
// MARK: - 06. setNeedsDisplay → draw(_:)
//==============================================================
//
// Only for custom drawing (draw(_:) overridden).
// setNeedsDisplay → draw(_:) on the next cycle. Never call draw(_:) directly.
// Most apps rarely need it — layers and subviews handle drawing.
//


//==============================================================
// MARK: - 07. Quick Reference
//==============================================================
//
// ┌──────────────────────────┬──────────────┬────────────────────────────────┐
// │ Method                   │ Timing       │ Use for                        │
// ├──────────────────────────┼──────────────┼────────────────────────────────┤
// │ setNeedsLayout()         │ Next cycle   │ Mark dirty — cheap, batched    │
// │ layoutIfNeeded()         │ Right now    │ Need frames immediately /      │
// │                          │              │ animate constraint changes     │
// │ layoutSubviews()         │ Called by    │ Override to position subviews  │
// │                          │ UIKit        │ — never call directly          │
// │ setNeedsUpdateConstraints│ Next cycle   │ Batch constraint updates       │
// │ setNeedsDisplay()        │ Next cycle   │ Redraw custom draw(_:)         │
// └──────────────────────────┴──────────────┴────────────────────────────────┘
//


//==============================================================
// MARK: - 08. Common Mistakes
//==============================================================
//
// ❌ Calling layoutSubviews() or draw(_:) directly → use setNeeds… instead
// ❌ layoutIfNeeded() inside loops → forces many layout passes
// ❌ Changing constraints / sizes inside layoutSubviews → can loop forever
// ❌ Forgetting super.layoutSubviews() → Auto Layout results not applied
// ❌ Heavy work in layoutSubviews → it runs often (rotation, resize, scroll)
// ❌ Animating by calling layoutIfNeeded on the changed view, not its superview
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What are the passes of the layout cycle?
//    → Update constraints, layout (layoutSubviews), display (draw).
//
// 2. setNeedsLayout vs layoutIfNeeded?
//    → setNeedsLayout marks dirty for the next cycle; layoutIfNeeded lays out pending changes now.
//
// 3. Does layoutIfNeeded always call layoutSubviews?
//    → No — only if the view is marked dirty.
//
// 4. What triggers layoutSubviews automatically?
//    → Size changes, addSubview, rotation, constraint changes — not moving the origin.
//
// 5. How do you animate a constraint change?
//    → Change the constant, then call superview.layoutIfNeeded() inside UIView.animate.
//
// 6. Why should you never call layoutSubviews directly?
//    → UIKit manages the cycle; use setNeedsLayout / layoutIfNeeded instead.
//
// 7. What happens if you change constraints inside layoutSubviews?
//    → It marks layout dirty again and can cause an infinite layout loop.
//
//==============================================================
