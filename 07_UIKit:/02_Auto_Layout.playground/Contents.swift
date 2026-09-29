import UIKit

//==============================================================
// MARK: - Auto Layout
//==============================================================
//
// Describe relationships (constraints) instead of fixed frames.
// The layout engine solves them → frames adapt to screen size,
// rotation, Dynamic Type, and localization.
// Rule: each view needs enough constraints for x, y, width, height.
//


//==============================================================
// MARK: - 01. Anchors
//==============================================================
//
// translatesAutoresizingMaskIntoConstraints = false for every
// view you constrain in code — otherwise its frame is converted
// into constraints that conflict with yours.
//

print("\n========== 01 - Anchors ==========")

let card = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 200))

let titleLabel = UILabel()

titleLabel.translatesAutoresizingMaskIntoConstraints = false

card.addSubview(titleLabel)

NSLayoutConstraint.activate([
    titleLabel.topAnchor.constraint(equalTo: card.topAnchor, constant: 16),
    titleLabel.leadingAnchor.constraint(equalTo: card.leadingAnchor, constant: 16),
    titleLabel.trailingAnchor.constraint(equalTo: card.trailingAnchor, constant: -16),
    titleLabel.heightAnchor.constraint(equalToConstant: 24)
])

card.layoutIfNeeded()                                // solve constraints now

print("Title frame:", titleLabel.frame)              // (16, 16, 288, 24)

// ❌ Forget translatesAutoresizingMaskIntoConstraints = false →
//    "Unable to simultaneously satisfy constraints" in the console.


//==============================================================
// MARK: - 02. Priorities
//==============================================================
//
// required (1000) must hold. Lower priorities can break.
// defaultHigh (750) / defaultLow (250) → preferences, not rules.
//

print("\n========== 02 - Priorities ==========")

let bannerContainer = UIView(frame: CGRect(x: 0, y: 0, width: 320, height: 100))

let banner = UIView()

banner.translatesAutoresizingMaskIntoConstraints = false

bannerContainer.addSubview(banner)

let preferredWidth = banner.widthAnchor.constraint(equalToConstant: 400)

preferredWidth.priority = .defaultHigh               // 750 — can break

NSLayoutConstraint.activate([
    banner.topAnchor.constraint(equalTo: bannerContainer.topAnchor),
    banner.leadingAnchor.constraint(equalTo: bannerContainer.leadingAnchor),
    banner.heightAnchor.constraint(equalToConstant: 50),
    banner.widthAnchor.constraint(lessThanOrEqualToConstant: 200),   // required
    preferredWidth
])

bannerContainer.layoutIfNeeded()

print("Banner width:", banner.frame.width)           // 200 — required wins over 750


//==============================================================
// MARK: - 03. Switching Layouts
//==============================================================
//
// Keep references, activate / deactivate — don't remove and recreate.
//

final class ExpandableView: UIView {

    let content = UIView()

    private var collapsedHeight: NSLayoutConstraint!

    private var expandedHeight: NSLayoutConstraint!

    override init(frame: CGRect) {
        super.init(frame: frame)
        content.translatesAutoresizingMaskIntoConstraints = false
        addSubview(content)
        collapsedHeight = content.heightAnchor.constraint(equalToConstant: 60)
        expandedHeight = content.heightAnchor.constraint(equalToConstant: 180)
        NSLayoutConstraint.activate([
            content.topAnchor.constraint(equalTo: topAnchor),
            content.leadingAnchor.constraint(equalTo: leadingAnchor),
            content.trailingAnchor.constraint(equalTo: trailingAnchor),
            collapsedHeight
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func setExpanded(_ expanded: Bool) {
        if expanded {
            collapsedHeight.isActive = false         // deactivate FIRST — avoids a conflict
            expandedHeight.isActive = true
        } else {
            expandedHeight.isActive = false
            collapsedHeight.isActive = true
        }
        layoutIfNeeded()                             // wrap in UIView.animate to animate
    }
}

print("\n========== 03 - Switching Layouts ==========")

let expandable = ExpandableView(frame: CGRect(x: 0, y: 0, width: 320, height: 300))

expandable.layoutIfNeeded()

print("Collapsed:", expandable.content.frame.height) // 60

expandable.setExpanded(true)

print("Expanded:", expandable.content.frame.height)  // 180


//==============================================================
// MARK: - 04. Ambiguous vs Conflicting
//==============================================================
//
// Ambiguous  → too FEW constraints, many valid answers → view jumps / 0 size
// Conflicting → too MANY, can't all hold → engine breaks one, logs a warning
//
// Debugging:
// 1. view.hasAmbiguousLayout → true if ambiguous
// 2. Symbolic breakpoint: UIViewAlertForUnsatisfiableConstraints
// 3. constraint.identifier = "title.top" → readable conflict logs
// 4. Xcode View Debugger → purple warnings on the view
//


//==============================================================
// MARK: - 05. Safe Area & Margins
//==============================================================
//
// Pin to view.safeAreaLayoutGuide, not view edges → avoids notch,
// Dynamic Island, and home indicator.
//
// button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
//
// layoutMarginsGuide → system-standard padding inside a view.
//


//==============================================================
// MARK: - 06. Performance Tips
//==============================================================
//
// 1. NSLayoutConstraint.activate([...]) → one batch, not one-by-one.
// 2. Create constraints once — change .constant or .isActive later.
// 3. Never add constraints in layoutSubviews — it runs many times.
// 4. UIStackView for rows / columns → fewer manual constraints.
// 5. Deep nesting of stack views in cells can hurt scrolling — flatten hot cells.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Why set translatesAutoresizingMaskIntoConstraints = false?
//    → Otherwise the frame becomes constraints that conflict with yours.
//
// 2. How many constraints does a view need?
//    → Enough to define x, y, width, and height (intrinsic size can supply width/height).
//
// 3. What are constraint priorities?
//    → 1–1000; 1000 is required, lower ones can break to satisfy higher ones.
//
// 4. Ambiguous vs conflicting layout?
//    → Ambiguous = too few constraints; conflicting = too many that can't all hold.
//
// 5. How do you debug a constraint conflict?
//    → Read the log, add identifiers, UIViewAlertForUnsatisfiableConstraints breakpoint, View Debugger.
//
// 6. How do you animate a constraint change?
//    → Change constant / isActive, then call layoutIfNeeded inside UIView.animate.
//
// 7. Why pin to safeAreaLayoutGuide?
//    → Keeps content clear of the notch, Dynamic Island, and home indicator.
//
//==============================================================
