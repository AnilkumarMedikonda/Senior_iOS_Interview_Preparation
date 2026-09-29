import UIKit

//==============================================================
// MARK: - Dynamic Cell Height (Self-Sizing Cells)
//==============================================================
//
// Let Auto Layout calculate each row's height from its content.
// Three requirements:
// 1. tableView.rowHeight = UITableView.automaticDimension
// 2. tableView.estimatedRowHeight = a realistic value
// 3. An UNBROKEN vertical chain of constraints: contentView top → … → bottom
//    (+ label.numberOfLines = 0 for multi-line text)
//


//==============================================================
// MARK: - 01. Self-Sizing Cell
//==============================================================
//
// Pin to contentView — NOT the cell itself.
//

final class ReviewCell: UITableViewCell {

    let reviewLabel = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        reviewLabel.numberOfLines = 0                        // allow wrapping
        reviewLabel.font = .systemFont(ofSize: 16)
        reviewLabel.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(reviewLabel)

        NSLayoutConstraint.activate([
            reviewLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            reviewLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            reviewLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            reviewLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12)   // closes the chain
        ])
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@MainActor
final class ReviewsDataSource: NSObject, UITableViewDataSource {

    let reviews = [
        "Great fit.",
        "Very comfortable for long runs. The cushioning holds up after 200 km, and the upper breathes well even in hot weather. Sizing runs slightly small, so order half a size up."
    ]

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        reviews.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Review", for: indexPath)
        if let reviewCell = cell as? ReviewCell {
            reviewCell.reviewLabel.text = reviews[indexPath.row]
        }
        return cell
    }
}

print("\n========== 01 - Self-Sizing Cell ==========")

let reviewsTable = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 600))

let reviewsDataSource = ReviewsDataSource()

reviewsTable.register(ReviewCell.self, forCellReuseIdentifier: "Review")

reviewsTable.rowHeight = UITableView.automaticDimension     // 1

reviewsTable.estimatedRowHeight = 60                        // 2

reviewsTable.dataSource = reviewsDataSource

reviewsTable.reloadData()

reviewsTable.layoutIfNeeded()

print("Short review height:", reviewsTable.rectForRow(at: IndexPath(row: 0, section: 0)).height)   // small

print("Long review height: ", reviewsTable.rectForRow(at: IndexPath(row: 1, section: 0)).height)   // much taller


//==============================================================
// MARK: - 02. Broken Chain
//==============================================================
//
// No bottom constraint → Auto Layout can't derive the cell height.
// Result: height collapses or falls back to the estimate — text clipped.
//

func measuredHeight(pinBottom: Bool) -> CGFloat {

    let contentView = UIView()

    let label = UILabel()

    label.numberOfLines = 0

    label.text = "Very comfortable for long runs. The cushioning holds up after 200 km."

    label.translatesAutoresizingMaskIntoConstraints = false

    contentView.addSubview(label)

    var constraints = [
        label.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
        label.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
        label.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
    ]

    if pinBottom {
        constraints.append(label.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12))
    }

    NSLayoutConstraint.activate(constraints)

    let size = contentView.systemLayoutSizeFitting(
        CGSize(width: 320, height: UIView.layoutFittingCompressedSize.height),
        withHorizontalFittingPriority: .required,
        verticalFittingPriority: .fittingSizeLevel
    )

    return size.height
}

print("\n========== 02 - Broken Chain ==========")

print("With bottom constraint:   ", measuredHeight(pinBottom: true))    // real height ✅

print("Without bottom constraint:", measuredHeight(pinBottom: false))   // ~0 ❌ collapsed


//==============================================================
// MARK: - 03. Changing Height at Runtime
//==============================================================
//
// "Read more" expands a review:
// 1. Update the model (isExpanded = true)
// 2. Update the cell (numberOfLines = 0)
// 3. tableView.performBatchUpdates(nil)   → recalculates heights, animated
//
// No need to reload the row.
//


//==============================================================
// MARK: - 04. Common Mistakes
//==============================================================
//
// ❌ Constraints pinned to the cell instead of contentView
// ❌ Missing bottom constraint → broken vertical chain
// ❌ numberOfLines = 1 → text never wraps
// ❌ A fixed height constraint inside the cell → fights self-sizing
// ❌ heightForRowAt returning a number → overrides automaticDimension
// ❌ estimatedRowHeight far from reality → scroll bar jumps, content jumps on scroll
// ❌ Images with no size before loading → cell resizes after load, list jumps
//    ✅ Give image views an aspect-ratio or fixed-height constraint
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. How do you make a self-sizing table cell?
//    → automaticDimension, an estimated height, and an unbroken top-to-bottom constraint chain.
//
// 2. Why pin to contentView and not the cell?
//    → contentView adjusts for accessories and editing; the cell's own bounds don't.
//
// 3. What happens if the bottom constraint is missing?
//    → The height can't be calculated — the cell collapses or uses the estimate.
//
// 4. Why does estimatedRowHeight matter?
//    → Bad estimates make the scroll indicator and content jump while scrolling.
//
// 5. How do you animate a cell growing (Read more)?
//    → Update the model and cell, then call performBatchUpdates(nil).
//
// 6. Why does a list jump when images load?
//    → The image view had no size until the image arrived — give it a fixed or aspect-ratio constraint.
//
//==============================================================
