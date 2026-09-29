import UIKit

//==============================================================
// MARK: - UITableView
//==============================================================
//
// A scrolling, single-column list of reusable cells.
// Data source → WHAT to show (counts, cells).
// Delegate    → HOW it behaves (selection, height, swipe).
// Modern apps → UITableViewDiffableDataSource (no index crashes).
//


//==============================================================
// MARK: - 01. Data Source vs Delegate
//==============================================================
//
// ┌────────────────────────┬──────────────────────────────────────────┐
// │ UITableViewDataSource  │ numberOfRowsInSection, cellForRowAt,     │
// │                        │ numberOfSections, titleForHeader         │
// ├────────────────────────┼──────────────────────────────────────────┤
// │ UITableViewDelegate    │ didSelectRowAt, heightForRowAt,          │
// │                        │ willDisplay, swipe actions               │
// └────────────────────────┴──────────────────────────────────────────┘
//
// Both are weak — the table doesn't retain them.
//


//==============================================================
// MARK: - 02. Classic Data Source
//==============================================================

final class ProductListViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    let tableView = UITableView()

    var products = ["Shoes", "Cap", "Bag"]

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ProductCell")
        tableView.dataSource = self
        tableView.delegate = self
        view.addSubview(tableView)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        products.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ProductCell", for: indexPath)
        var content = cell.defaultContentConfiguration()
        content.text = products[indexPath.row]
        cell.contentConfiguration = content
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("Selected:", products[indexPath.row])
        tableView.deselectRow(at: indexPath, animated: true)
    }


//==============================================================
// MARK: - 03. Inserting Rows Safely
//==============================================================
//
// Update the MODEL first, then tell the table.
// ❌ insertRows without updating products → crash:
//    "Invalid update: invalid number of rows in section 0"
//

    func addProduct(_ name: String) {
        products.append(name)                                    // 1. model
        let indexPath = IndexPath(row: products.count - 1, section: 0)
        tableView.performBatchUpdates {
            tableView.insertRows(at: [indexPath], with: .automatic)   // 2. table
        }
    }
}

func cellText(_ cell: UITableViewCell?) -> String {
    if let content = cell?.contentConfiguration as? UIListContentConfiguration, let text = content.text {
        return text
    }
    return "-"
}

print("\n========== 02 - Classic Data Source ==========")

let listVC = ProductListViewController()

listVC.loadViewIfNeeded()

listVC.tableView.reloadData()

listVC.tableView.layoutIfNeeded()

print("Rows:", listVC.tableView.numberOfRows(inSection: 0))              // 3

print("Row 0:", cellText(listVC.tableView.cellForRow(at: IndexPath(row: 0, section: 0))))   // Shoes

listVC.tableView(listVC.tableView, didSelectRowAt: IndexPath(row: 1, section: 0))          // Selected: Cap


print("\n========== 03 - Inserting Rows Safely ==========")

listVC.addProduct("Watch")

print("Rows after insert:", listVC.tableView.numberOfRows(inSection: 0))  // 4


//==============================================================
// MARK: - 04. Diffable Data Source
//==============================================================
//
// Describe the data as a snapshot → apply → UIKit calculates
// inserts / deletes / moves. No index math, no "invalid update" crashes.
// Items must be Hashable (use a stable ID).
//

struct Product: Hashable {
    let id: Int
    let name: String
}

enum Section {
    case main
}

final class DiffableListViewController: UIViewController {

    let tableView = UITableView()

    private var dataSource: UITableViewDiffableDataSource<Section, Product>!

    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.frame = view.bounds
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "Cell")
        view.addSubview(tableView)

        dataSource = UITableViewDiffableDataSource<Section, Product>(tableView: tableView) { tableView, indexPath, product in
            let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
            var content = cell.defaultContentConfiguration()
            content.text = product.name
            cell.contentConfiguration = content
            return cell
        }
    }

    func show(_ products: [Product]) {
        var snapshot = NSDiffableDataSourceSnapshot<Section, Product>()
        snapshot.appendSections([.main])
        snapshot.appendItems(products)
        dataSource.apply(snapshot, animatingDifferences: true)   // UIKit diffs old vs new
    }

    var itemCount: Int {
        dataSource.snapshot().numberOfItems
    }
}

print("\n========== 04 - Diffable Data Source ==========")

let diffableVC = DiffableListViewController()

diffableVC.loadViewIfNeeded()

diffableVC.show([Product(id: 1, name: "Shoes"), Product(id: 2, name: "Cap")])

print("Items:", diffableVC.itemCount)                // 2

diffableVC.show([Product(id: 1, name: "Shoes"), Product(id: 3, name: "Bag"), Product(id: 2, name: "Cap")])

print("Items after update:", diffableVC.itemCount)   // 3 — Bag inserted, no index math


//==============================================================
// MARK: - 05. Common Mistakes
//==============================================================
//
// ❌ Forgetting register(_:forCellReuseIdentifier:) → crash on dequeue
// ❌ Forgetting tableView.dataSource = self → empty table
// ❌ Changing the table without updating the model → invalid update crash
// ❌ Heavy work in cellForRowAt (image decoding, date formatting) → janky scroll
// ❌ Calling reloadData for one changed row → use reloadRows / diffable snapshot
// ❌ Diffable item with unstable hash (random UUID every time) → full reload, lost animations
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Data source vs delegate?
//    → Data source supplies counts and cells; delegate handles selection, height, and events.
//
// 2. Why are dataSource and delegate weak?
//    → The VC owns the table; strong back-references would create a retain cycle.
//
// 3. What causes "Invalid update: invalid number of rows"?
//    → The table was changed without updating the model first, or counts don't match.
//
// 4. reloadData vs insertRows / reloadRows?
//    → reloadData redraws everything with no animation; row APIs update only what changed.
//
// 5. Why use a diffable data source?
//    → Apply a snapshot and UIKit computes the changes — no index math or update crashes.
//
// 6. What must diffable items be?
//    → Hashable with a stable identity, like an ID.
//
// 7. What should you avoid in cellForRowAt?
//    → Heavy work — decode images and format data ahead of time or off the main thread.
//
//==============================================================
