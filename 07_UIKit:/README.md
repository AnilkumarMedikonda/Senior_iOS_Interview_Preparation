# 07_UIKit

Building and tuning UIKit screens — views, Auto Layout, lists, cell reuse, pagination, and rendering performance. Senior interviews go beyond "how do I make a table" into reuse bugs, layout passes, and smooth scrolling.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_UIView_UIViewController` | View hierarchy, responder chain, child view controllers | ⬜ |
| 02 | `02_Auto_Layout` | Anchors, `translatesAutoresizingMaskIntoConstraints`, priorities, conflicts | ⬜ |
| 03 | `03_Content_Hugging_Compression` | Intrinsic content size, hugging vs compression resistance | ⬜ |
| 04 | `04_UITableView` | Data source / delegate, diffable data source | ⬜ |
| 05 | `05_Cell_Reuse` | `dequeueReusableCell`, `prepareForReuse`, stale image bug | ⬜ |
| 06 | `06_UICollectionView` | Flow layout, compositional layout, diffable data source | ⬜ |
| 07 | `07_Dynamic_Cell_Height` | Self-sizing cells, `automaticDimension`, estimated height | ⬜ |
| 08 | `08_Pagination` | Load more near the end, prefetching, duplicate request guard | ⬜ |
| 09 | `09_UI_Performance` | Main thread work, image decoding, offscreen rendering, dropped frames | ⬜ |
| 10 | `10_Frame_vs_Bounds` | Superview vs own coordinate space, transforms | ⬜ |
| 11 | `11_Layout_Cycle` | `setNeedsLayout`, `layoutIfNeeded`, `layoutSubviews`, update constraints pass | ⬜ |

**0 / 11 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [ ] 01_UIView_UIViewController
- [ ] 02_Auto_Layout
- [ ] 03_Content_Hugging_Compression
- [ ] 04_UITableView
- [ ] 05_Cell_Reuse
- [ ] 06_UICollectionView
- [ ] 07_Dynamic_Cell_Height
- [ ] 08_Pagination
- [ ] 09_UI_Performance
- [ ] 10_Frame_vs_Bounds
- [ ] 11_Layout_Cycle
