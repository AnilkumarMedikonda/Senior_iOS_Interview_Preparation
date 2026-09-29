import UIKit

//==============================================================
// MARK: - UICollectionView
//==============================================================
//
// Like UITableView, but the LAYOUT is a separate object →
// grids, horizontal carousels, mixed sections, any arrangement.
// Data: data source (or diffable). Positioning: layout object.
// Same reuse rules as table cells (05_Cell_Reuse).
//


//==============================================================
// MARK: - 01. Table vs Collection
//==============================================================
//
// ┌─────────────────────┬──────────────────────────┬────────────────────────────┐
// │                     │ UITableView              │ UICollectionView           │
// ├─────────────────────┼──────────────────────────┼────────────────────────────┤
// │ Layout              │ Single column, vertical  │ Any — grid, carousel, mix  │
// │ Layout object       │ Built in                 │ Flow / Compositional       │
// │ Units               │ Rows                     │ Items                      │
// │ Use for             │ Settings, simple lists   │ Product grids, home feeds  │
// └─────────────────────┴──────────────────────────┴────────────────────────────┘
//
// UICollectionLayoutListConfiguration → table-style lists inside a collection view.
//


//==============================================================
// MARK: - 02. Flow Layout — 2-Column Grid
//==============================================================
//
// Item width = (total width − insets − spacing) / columns
// (320 − 16 − 16 − 8) / 2 = 140
//

@MainActor
final class GridDataSource: NSObject, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        6
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        collectionView.dequeueReusableCell(withReuseIdentifier: "GridCell", for: indexPath)
    }
}

print("\n========== 02 - Flow Layout Grid ==========")

let flowLayout = UICollectionViewFlowLayout()

flowLayout.sectionInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)

flowLayout.minimumInteritemSpacing = 8

flowLayout.minimumLineSpacing = 8

flowLayout.itemSize = CGSize(width: 140, height: 180)

let gridView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 600), collectionViewLayout: flowLayout)

let gridDataSource = GridDataSource()

gridView.register(UICollectionViewCell.self, forCellWithReuseIdentifier: "GridCell")

gridView.dataSource = gridDataSource

gridView.reloadData()

gridView.layoutIfNeeded()

for item in 0..<3 {
    if let attributes = gridView.layoutAttributesForItem(at: IndexPath(item: item, section: 0)) {
        print("Item \(item):", attributes.frame)
    }
}

// Item 0: (16, 0, 140, 180)    — left column
// Item 1: (164, 0, 140, 180)   — right column
// Item 2: (16, 188, 140, 180)  — next row

// ❌ Width math forgetting insets / spacing → 141 won't fit → grid drops to 1 column


//==============================================================
// MARK: - 03. Compositional Layout + Diffable
//==============================================================
//
// Item → Group → Section. Sizes as fractions of the container,
// so the grid adapts to any screen width — no manual math.
//

func makeGridLayout() -> UICollectionViewCompositionalLayout {

    let item = NSCollectionLayoutItem(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(0.5), heightDimension: .fractionalHeight(1))
    )

    item.contentInsets = NSDirectionalEdgeInsets(top: 4, leading: 4, bottom: 4, trailing: 4)

    let group = NSCollectionLayoutGroup.horizontal(
        layoutSize: NSCollectionLayoutSize(widthDimension: .fractionalWidth(1), heightDimension: .absolute(200)),
        subitems: [item]                                     // repeats → 2 per row
    )

    return UICollectionViewCompositionalLayout(section: NSCollectionLayoutSection(group: group))
}

// Horizontal carousel = same section + one line:
// section.orthogonalScrollingBehavior = .continuous   (or .groupPaging)

@MainActor
final class ProductGrid {

    let collectionView = UICollectionView(frame: CGRect(x: 0, y: 0, width: 320, height: 800), collectionViewLayout: makeGridLayout())

    private var dataSource: UICollectionViewDiffableDataSource<Int, String>!

    init() {
        // ✅ Create the registration ONCE — outside the cell provider
        let registration = UICollectionView.CellRegistration<UICollectionViewListCell, String> { cell, _, name in
            var content = cell.defaultContentConfiguration()
            content.text = name
            cell.contentConfiguration = content
        }

        dataSource = UICollectionViewDiffableDataSource<Int, String>(collectionView: collectionView) { collectionView, indexPath, name in
            collectionView.dequeueConfiguredReusableCell(using: registration, for: indexPath, item: name)
        }
    }

    func show(_ names: [String]) {
        var snapshot = NSDiffableDataSourceSnapshot<Int, String>()
        snapshot.appendSections([0])
        snapshot.appendItems(names)
        dataSource.apply(snapshot, animatingDifferences: false)
    }
}

print("\n========== 03 - Compositional Layout + Diffable ==========")

let productGrid = ProductGrid()

productGrid.show(["Shoes", "Cap", "Bag", "Watch"])

productGrid.collectionView.layoutIfNeeded()

print("Items:", productGrid.collectionView.numberOfItems(inSection: 0))    // 4

for item in 0..<3 {
    if let attributes = productGrid.collectionView.layoutAttributesForItem(at: IndexPath(item: item, section: 0)) {
        print("Item \(item):", attributes.frame)
    }
}

// Item 0: (4, 4, 152, 192)     — half width minus insets
// Item 1: (164, 4, 152, 192)
// Item 2: (4, 204, 152, 192)   — next row


//==============================================================
// MARK: - 04. Flow vs Compositional
//==============================================================
//
// Flow layout          → simple uniform grids; manual size math; one style per section
// Compositional layout → mixed sections (carousel + grid + list), fractional sizes,
//                        orthogonal scrolling, headers / badges — the modern default
//


//==============================================================
// MARK: - 05. Common Mistakes
//==============================================================
//
// ❌ Creating CellRegistration INSIDE the cell provider → crash (iOS 15+) / no reuse
// ❌ Item width math ignoring insets and spacing → wrong column count
// ❌ Nested collection views for carousels → use orthogonalScrollingBehavior instead
// ❌ Not invalidating the layout on rotation / size change (flow layout with fixed sizes)
// ❌ Same reuse bugs as tables → reset in prepareForReuse, cancel image tasks
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. UITableView vs UICollectionView?
//    → Table is a single vertical column; collection uses a separate layout for any arrangement.
//
// 2. Flow layout vs compositional layout?
//    → Flow for simple grids; compositional for mixed sections with fractional sizes.
//
// 3. Explain item, group, and section in compositional layout.
//    → Items sit in groups, groups repeat inside a section, and each section can differ.
//
// 4. How do you build a horizontal carousel inside a vertical feed?
//    → A compositional section with orthogonalScrollingBehavior — no nested collection view.
//
// 5. What is CellRegistration?
//    → A type-safe way to configure cells without string identifiers — create it once.
//
// 6. Why does a 2-column grid show only 1 column?
//    → Item width + spacing + insets exceed the collection width.
//
//==============================================================
