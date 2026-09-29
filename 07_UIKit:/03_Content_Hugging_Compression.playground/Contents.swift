import UIKit

//==============================================================
// MARK: - Content Hugging & Compression Resistance
//==============================================================
//
// Intrinsic content size = a view's natural size from its content
// (UILabel text, UIButton title, UIImageView image).
//
// Hugging     → resists growing BIGGER than intrinsic size.   Default 250.
// Compression → resists shrinking SMALLER than intrinsic size. Default 750.
// Higher priority wins. Used when two views compete for space.
//


//==============================================================
// MARK: - Setup: Name + Price Row
//==============================================================
//
// [ Name label ............ ][ Price ]
// Goal: price never truncates and stays tight; name takes the rest.
//

func makeRow(width: CGFloat, name: String, price: String, setPriorities: Bool) -> (UILabel, UILabel) {

    let container = UIView(frame: CGRect(x: 0, y: 0, width: width, height: 44))

    let nameLabel = UILabel()

    let priceLabel = UILabel()

    nameLabel.text = name

    priceLabel.text = price

    nameLabel.font = .systemFont(ofSize: 16)

    priceLabel.font = .boldSystemFont(ofSize: 16)

    for label in [nameLabel, priceLabel] {
        label.translatesAutoresizingMaskIntoConstraints = false
        container.addSubview(label)
    }

    if setPriorities {
        priceLabel.setContentHuggingPriority(.required, for: .horizontal)             // stay tight
        priceLabel.setContentCompressionResistancePriority(.required, for: .horizontal) // never truncate
    }

    NSLayoutConstraint.activate([
        nameLabel.leadingAnchor.constraint(equalTo: container.leadingAnchor, constant: 16),
        nameLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor),
        priceLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: 8),
        priceLabel.trailingAnchor.constraint(equalTo: container.trailingAnchor, constant: -16),
        priceLabel.centerYAnchor.constraint(equalTo: container.centerYAnchor)
    ])

    container.layoutIfNeeded()

    return (nameLabel, priceLabel)
}


//==============================================================
// MARK: - 01. Extra Space → Who Stretches?
//==============================================================
//
// Price hugging 1000 > name hugging 250 → NAME stretches, price stays tight.
//

print("\n========== 01 - Extra Space ==========")

let (wideName, widePrice) = makeRow(width: 320, name: "Shoes", price: "₹4999", setPriorities: true)

print("Price intrinsic:", widePrice.intrinsicContentSize.width)

print("Price actual:   ", widePrice.frame.width)     // same as intrinsic — hugged

print("Name actual:    ", wideName.frame.width)      // stretched to fill the rest


//==============================================================
// MARK: - 02. Not Enough Space → Who Shrinks?
//==============================================================
//
// Price compression 1000 > name compression 750 → NAME truncates, price stays full.
//

print("\n========== 02 - Not Enough Space ==========")

let (tightName, tightPrice) = makeRow(width: 180, name: "Running Shoes Ultra Boost", price: "₹4999", setPriorities: true)

print("Price intrinsic:", tightPrice.intrinsicContentSize.width)

print("Price actual:   ", tightPrice.frame.width)    // full — not compressed

print("Name intrinsic: ", tightName.intrinsicContentSize.width)

print("Name actual:    ", tightName.frame.width)     // smaller → "Running Sh…"


//==============================================================
// MARK: - 03. Equal Priorities → Ambiguous
//==============================================================
//
// Both labels at default 250 / 750 → engine picks one arbitrarily.
// Xcode warns "Content Priority Ambiguity" — result can change between runs / OS versions.
// ✅ Always make one view clearly higher.
//


//==============================================================
// MARK: - 04. Custom Intrinsic Content Size
//==============================================================
//
// A custom view can report its own natural size.
// Call invalidateIntrinsicContentSize() when it changes.
//

final class BadgeView: UIView {

    var count = 0 {
        didSet { invalidateIntrinsicContentSize() }  // tell Auto Layout to re-measure
    }

    override var intrinsicContentSize: CGSize {
        let width: CGFloat = count > 9 ? 32 : 20
        return CGSize(width: width, height: 20)
    }
}

print("\n========== 04 - Custom Intrinsic Content Size ==========")

let badge = BadgeView()

badge.count = 5

print("Count 5:", badge.intrinsicContentSize)        // (20, 20)

badge.count = 42

print("Count 42:", badge.intrinsicContentSize)       // (32, 20)


//==============================================================
// MARK: - 05. Quick Reference
//==============================================================
//
// ┌──────────────────────┬──────────────────────────┬──────────────────────────┐
// │                      │ Content Hugging          │ Compression Resistance   │
// ├──────────────────────┼──────────────────────────┼──────────────────────────┤
// │ Resists              │ Growing                  │ Shrinking                │
// │ Default (label)      │ 250                      │ 750                      │
// │ Raise it to          │ Keep a view tight        │ Prevent truncation       │
// │ Example              │ Price / icon / badge     │ Price / button title     │
// └──────────────────────┴──────────────────────────┴──────────────────────────┘
//
// Memory trick: Hugging = "don't make me bigger", Compression = "don't squeeze me".
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is intrinsic content size?
//    → A view's natural size based on its content, like a label's text.
//
// 2. Content hugging vs compression resistance?
//    → Hugging resists growing; compression resistance resists shrinking.
//
// 3. Default priorities for a UILabel?
//    → Hugging 250, compression resistance 750.
//
// 4. Two labels in a row — how do you keep the price from truncating?
//    → Give the price higher compression resistance (and hugging) than the name.
//
// 5. What happens when two views have equal priorities?
//    → Ambiguous layout — the engine picks one, and Xcode warns.
//
// 6. How does a custom view report its size to Auto Layout?
//    → Override intrinsicContentSize; call invalidateIntrinsicContentSize() when it changes.
//
//==============================================================
