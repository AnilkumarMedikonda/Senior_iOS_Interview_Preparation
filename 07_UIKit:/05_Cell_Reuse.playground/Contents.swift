import UIKit

//==============================================================
// MARK: - Cell Reuse
//==============================================================
//
// A table with 10,000 rows creates only enough cells to fill the screen
// (+ a few extra). Cells scrolling off are put in a reuse queue and
// handed back by dequeueReusableCell for new rows.
// Benefit: low memory, fast scrolling.
// Risk: a reused cell still holds the OLD row's state.
//


//==============================================================
// MARK: - 01. Proof: Few Cells, Many Rows
//==============================================================

final class CountingCell: UITableViewCell {

    static var created = 0

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        CountingCell.created += 1
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

@MainActor
final class LongListDataSource: NSObject, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        100
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        tableView.dequeueReusableCell(withIdentifier: "Counting", for: indexPath)
    }
}

print("\n========== 01 - Few Cells, Many Rows ==========")

let longList = UITableView(frame: CGRect(x: 0, y: 0, width: 320, height: 300))

let longListDataSource = LongListDataSource()

longList.register(CountingCell.self, forCellReuseIdentifier: "Counting")

longList.rowHeight = 44

longList.dataSource = longListDataSource

longList.reloadData()

longList.layoutIfNeeded()

for offset in stride(from: 0, through: 3000, by: 300) {
    longList.contentOffset = CGPoint(x: 0, y: offset)   // simulate scrolling
    longList.layoutIfNeeded()
}

print("Rows:", longList.numberOfRows(inSection: 0))      // 100

print("Cells created:", CountingCell.created)            // ~8–10, not 100


//==============================================================
// MARK: - 02. prepareForReuse
//==============================================================
//
// Called right before a cell is handed out again.
// Reset EVERYTHING row-specific: image, favorite, selection, running tasks.
//
// ┌─────────────────────────┬────────────────────────────────────────────┐
// │ Reset in prepareForReuse│ Visual state: image, favorite, badge,      │
// │                         │ cancel image download, clear represented ID│
// ├─────────────────────────┼────────────────────────────────────────────┤
// │ Set in cellForRowAt     │ All data for the NEW row — always, every   │
// │ (configure)             │ property, both true and false cases        │
// └─────────────────────────┴────────────────────────────────────────────┘
//


//==============================================================
// MARK: - 03. Stale Async Image
//==============================================================
//
// Classic bug:
// 1. Row 1 starts downloading its image
// 2. User scrolls → cell is reused for Row 2
// 3. Row 1's download finishes → sets the WRONG image on Row 2's cell
//
// ❌ Without a fix:
// Task { let image = await load(id); self.imageView.image = image }
//
// ✅ Fix:
// 1. Remember which row the cell shows (representedID)
// 2. Cancel the task in prepareForReuse
// 3. When the result arrives, check the ID still matches
//

final class ProductCell: UITableViewCell {

    private(set) var representedID: Int?

    private(set) var imageName: String?

    private(set) var isFavorite = false

    private var imageTask: Task<Void, Never>?

    func configure(id: Int, favorite: Bool) {
        representedID = id
        isFavorite = favorite                                // set true AND false cases
        imageTask = Task { [weak self] in
            try? await Task.sleep(for: .milliseconds(100))   // simulate download
            guard let self, !Task.isCancelled, self.representedID == id else {
                print("Ignored stale image for", id)
                return
            }
            self.imageName = "image\(id)"
            print("Set image for", id)
        }
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        imageTask?.cancel()                                  // stop the old download
        imageTask = nil
        imageName = nil
        isFavorite = false
        representedID = nil
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 02 - prepareForReuse ==========")

    let cell = ProductCell(style: .default, reuseIdentifier: "Product")

    cell.configure(id: 1, favorite: true)

    print("Row 1 favorite:", cell.isFavorite)                // true

    cell.prepareForReuse()                                   // scrolled off → reused

    print("After reuse favorite:", cell.isFavorite)          // false — reset


    print("\n========== 03 - Stale Async Image ==========")

    cell.configure(id: 2, favorite: false)                   // now showing Row 2

    try? await Task.sleep(for: .milliseconds(300))

    if let imageName = cell.imageName {
        print("Final image:", imageName)                     // image2 ✅ — not image1
    }

    // Output:
    // Ignored stale image for 1
    // Set image for 2
    // Final image: image2
}


//==============================================================
// MARK: - 04. Common Mistakes
//==============================================================
//
// ❌ Setting a property only in the "true" case
//    if product.isOnSale { saleBadge.isHidden = false }   // reused cell keeps the badge
//    ✅ saleBadge.isHidden = !product.isOnSale
//
// ❌ Not cancelling image downloads in prepareForReuse
// ❌ Storing row data only in the cell (e.g. favorite toggled in the cell)
//    → store it in the MODEL, cells just display it
// ❌ Creating cells with UITableViewCell() instead of dequeue → no reuse, memory grows
// ❌ Heavy reset logic in prepareForReuse → keep it cheap, it runs while scrolling
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. How does cell reuse work?
//    → Off-screen cells go to a reuse queue; dequeue hands them back for new rows.
//
// 2. Why does UIKit reuse cells?
//    → Only screen-full of cells exist — low memory and smooth scrolling.
//
// 3. What is prepareForReuse for?
//    → Resetting row-specific state and cancelling tasks before the cell is reused.
//
// 4. Why does a wrong image appear after fast scrolling?
//    → A slow download finished after the cell was reused for another row.
//
// 5. How do you fix the wrong-image bug?
//    → Track the represented ID, cancel in prepareForReuse, check the ID before setting.
//
// 6. Why does a badge appear on the wrong row?
//    → It was only set in the true case — always set both true and false.
//
// 7. Where should row state like "favorited" live?
//    → In the model — cells only display it.
//
//==============================================================
