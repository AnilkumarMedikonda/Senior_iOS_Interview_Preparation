# 07_UIKit

Building and tuning UIKit screens — views, Auto Layout, lists, cell reuse, pagination, and rendering performance. Senior interviews go beyond "how do I make a table" into reuse bugs, layout passes, and smooth scrolling.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_UIView_UIViewController` | View hierarchy, responder chain, child view controllers | ✅ |
| 02 | `02_Auto_Layout` | Anchors, priorities, layout switching, conflict debugging | ✅ |
| 03 | `03_Content_Hugging_Compression` | Intrinsic size, name/price row demo, custom intrinsic size | ✅ |
| 04 | `04_UITableView` | Data source / delegate, safe row inserts, diffable data source | ✅ |
| 05 | `05_Cell_Reuse` | Reuse proof, `prepareForReuse`, stale async image fix | ✅ |
| 06 | `06_UICollectionView` | Flow grid, compositional layout, `CellRegistration` | ✅ |
| 07 | `07_Dynamic_Cell_Height` | Self-sizing cells, broken chain demo, runtime resizing | ✅ |
| 08 | `08_Pagination` | Load-more trigger, loading guards, retry, offset vs cursor | ✅ |
| 09 | `09_UI_Performance` | Frame budget, image memory, offscreen rendering, Instruments | ✅ |
| 10 | `10_Frame_vs_Bounds` | Rotation, scroll offset, center resizing, coordinate conversion | ✅ |
| 11 | `11_Layout_Cycle` | `setNeedsLayout` batching, triggers, constraint animation | ✅ |

**11 / 11 topics** ✅

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [x] 01_UIView_UIViewController
- [x] 02_Auto_Layout
- [x] 03_Content_Hugging_Compression
- [x] 04_UITableView
- [x] 05_Cell_Reuse
- [x] 06_UICollectionView
- [x] 07_Dynamic_Cell_Height
- [x] 08_Pagination
- [x] 09_UI_Performance
- [x] 10_Frame_vs_Bounds
- [x] 11_Layout_Cycle
