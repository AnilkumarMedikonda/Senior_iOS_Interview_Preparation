import UIKit

//==============================================================
// MARK: - Frame vs Bounds
//==============================================================
//
// frame  → position + size in the SUPERVIEW's coordinate space
// bounds → position + size in the view's OWN coordinate space
//          (origin is usually (0, 0))
// center → the view's center, in superview coordinates
//
// Place a view in its parent → frame. Lay out inside a view → bounds.
//


//==============================================================
// MARK: - 01. Basic Difference
//==============================================================

print("\n========== 01 - Basic Difference ==========")

let container = UIView(frame: CGRect(x: 0, y: 0, width: 300, height: 300))

let box = UIView(frame: CGRect(x: 50, y: 50, width: 100, height: 100))

container.addSubview(box)

print("Frame: ", box.frame)                          // (50, 50, 100, 100) — where it sits in container

print("Bounds:", box.bounds)                         // (0, 0, 100, 100)  — its own space

print("Center:", box.center)                         // (100, 100)        — in container space


//==============================================================
// MARK: - 02. Rotation Changes Frame, Not Bounds
//==============================================================
//
// With a transform, frame = the bounding box around the rotated view.
// bounds stays the real size. Apple: frame is undefined with a transform —
// use bounds + center instead.
//

print("\n========== 02 - Rotation ==========")

box.transform = CGAffineTransform(rotationAngle: .pi / 4)   // 45°

print("Frame after rotate: ", box.frame.size)        // ~(141.4, 141.4) ❌ bigger box

print("Bounds after rotate:", box.bounds.size)       // (100, 100) ✅ real size

box.transform = .identity


//==============================================================
// MARK: - 03. Changing Bounds Origin = Scrolling
//==============================================================
//
// Moving bounds.origin shifts what the view SHOWS, not where it sits.
// This is exactly how UIScrollView scrolls: contentOffset == bounds.origin.
//

print("\n========== 03 - Bounds Origin = Scrolling ==========")

let scrollView = UIScrollView(frame: CGRect(x: 0, y: 0, width: 320, height: 480))

scrollView.contentSize = CGSize(width: 320, height: 2000)

scrollView.contentOffset = CGPoint(x: 0, y: 300)

print("contentOffset:", scrollView.contentOffset)    // (0, 300)

print("bounds.origin:", scrollView.bounds.origin)    // (0, 300) — same thing

print("frame.origin: ", scrollView.frame.origin)     // (0, 0)   — didn't move on screen


//==============================================================
// MARK: - 04. Changing Bounds Size Keeps the Center
//==============================================================

print("\n========== 04 - Bounds Size Keeps Center ==========")

let square = UIView(frame: CGRect(x: 100, y: 100, width: 100, height: 100))

square.bounds.size = CGSize(width: 200, height: 200)

print("Center:", square.center)                      // (150, 150) — unchanged

print("Frame: ", square.frame)                       // (50, 50, 200, 200) — grew around center


//==============================================================
// MARK: - 05. Converting Between Coordinate Spaces
//==============================================================
//
// Point inside a child → where is it in the parent (or window)?
// Common for: popovers, tooltips, scrolling a field above the keyboard.
//

print("\n========== 05 - Converting Coordinates ==========")

let parent = UIView(frame: CGRect(x: 0, y: 0, width: 400, height: 400))

let card = UIView(frame: CGRect(x: 40, y: 60, width: 200, height: 100))

parent.addSubview(card)

let tapInCard = CGPoint(x: 10, y: 10)

print("In parent:", card.convert(tapInCard, to: parent))   // (50, 70)

print("Card frame in parent:", card.convert(card.bounds, to: parent))   // (40, 60, 200, 100)


//==============================================================
// MARK: - 06. When to Use Which
//==============================================================
//
// ┌──────────────────────────────────────────┬───────────────────────────┐
// │ Task                                     │ Use                       │
// ├──────────────────────────────────────────┼───────────────────────────┤
// │ Position a view inside its superview     │ frame (or center)         │
// │ Lay out subviews in layoutSubviews       │ bounds                    │
// │ Draw in draw(_:)                         │ bounds                    │
// │ View has a transform (rotate / scale)    │ bounds + center, NOT frame│
// │ Scroll position                          │ bounds.origin / offset    │
// │ Compare positions across views           │ convert(_:to:)            │
// └──────────────────────────────────────────┴───────────────────────────┘
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Frame vs bounds?
//    → Frame is in the superview's coordinates; bounds is in the view's own coordinates.
//
// 2. Is bounds.origin always (0, 0)?
//    → No — scroll views change it; contentOffset is bounds.origin.
//
// 3. What happens to frame when you rotate a view?
//    → It becomes the bounding box and grows; bounds stays the real size.
//
// 4. Which should you use with a transform?
//    → bounds and center — frame is undefined with a non-identity transform.
//
// 5. What happens when you change bounds.size?
//    → The view resizes around its center; frame changes, center doesn't.
//
// 6. How do you convert a point between views?
//    → view.convert(point, to: otherView).
//
// 7. Why use bounds in layoutSubviews?
//    → You're laying out inside the view's own space, independent of where it sits.
//
//==============================================================
