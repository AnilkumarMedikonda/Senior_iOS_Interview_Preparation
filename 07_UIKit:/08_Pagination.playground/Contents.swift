import UIKit

//==============================================================
// MARK: - Pagination
//==============================================================
//
// Load a long list in pages instead of all at once.
// App side:  trigger near the end → fetch next page → append.
// Guards:    isLoading (no duplicate calls), hasMore (stop at end).
// API side:  offset (page / limit) or cursor (after: lastID).
//


//==============================================================
// MARK: - 01. When to Load More
//==============================================================
//
// Start before the user hits the bottom → no visible wait.
// Common trigger: willDisplay / prefetchRowsAt when within N rows of the end.
//

func shouldLoadMore(displayedIndex: Int, total: Int, threshold: Int = 3) -> Bool {
    displayedIndex >= total - threshold
}

print("\n========== 01 - When to Load More ==========")

print("Row 10 of 20:", shouldLoadMore(displayedIndex: 10, total: 20))   // false

print("Row 17 of 20:", shouldLoadMore(displayedIndex: 17, total: 20))   // true — start loading

// UITableViewDelegate:
// func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
//     if shouldLoadMore(displayedIndex: indexPath.row, total: items.count) {
//         Task { await paginator.loadNextPage() }
//     }
// }


//==============================================================
// MARK: - 02. Paginator with Guards
//==============================================================

struct Page: Sendable {
    let items: [String]
    let hasMore: Bool
}

enum APIError: Error {
    case network
}

func fetchPage(_ page: Int, failOnPage: Int? = nil) async throws -> Page {
    try await Task.sleep(for: .milliseconds(100))
    if page == failOnPage { throw APIError.network }
    let items = (1...3).map { "Item \((page - 1) * 3 + $0)" }
    return Page(items: items, hasMore: page < 3)             // 3 pages total
}

@MainActor
final class Paginator {

    private(set) var items: [String] = []

    private var nextPage = 1

    private var isLoading = false

    private var hasMore = true

    var failOnPage: Int?

    func loadNextPage() async {
        guard !isLoading else {
            print("Skipped — already loading")               // guard 1: no duplicates
            return
        }
        guard hasMore else {
            print("Skipped — no more pages")                 // guard 2: end reached
            return
        }

        isLoading = true
        defer { isLoading = false }

        do {
            let page = try await fetchPage(nextPage, failOnPage: failOnPage)
            items.append(contentsOf: page.items)             // append, don't replace
            hasMore = page.hasMore
            nextPage += 1                                    // advance ONLY on success
            print("Loaded page \(nextPage - 1) → total \(items.count)")
        } catch {
            print("Page \(nextPage) failed — will retry same page")
        }
    }
}


//==============================================================
// MARK: - 03. Offset vs Cursor
//==============================================================
//
// Offset: "skip 3, take 3". If a new item is added at the top
// between requests, everything shifts → duplicates / missed items.
// Cursor: "items after ID 8" → stable, no shift.
//

let feedBeforeInsert = [10, 9, 8, 7, 6, 5]

let feedAfterInsert = [11, 10, 9, 8, 7, 6, 5]                // new post 11 arrived

func offsetPage(_ feed: [Int], offset: Int, limit: Int) -> [Int] {
    Array(feed.dropFirst(offset).prefix(limit))
}

func cursorPage(_ feed: [Int], after lastID: Int, limit: Int) -> [Int] {
    Array(feed.filter { $0 < lastID }.prefix(limit))
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 02 - Paginator with Guards ==========")

    let paginator = Paginator()

    async let first: Void = paginator.loadNextPage()
    async let duplicate: Void = paginator.loadNextPage()     // fast scroll → second call
    _ = await (first, duplicate)                             // Skipped — already loading

    paginator.failOnPage = 2

    await paginator.loadNextPage()                           // Page 2 failed

    paginator.failOnPage = nil

    await paginator.loadNextPage()                           // Loaded page 2 → total 6

    await paginator.loadNextPage()                           // Loaded page 3 → total 9

    await paginator.loadNextPage()                           // Skipped — no more pages


    print("\n========== 03 - Offset vs Cursor ==========")

    let page1 = offsetPage(feedBeforeInsert, offset: 0, limit: 3)

    print("Page 1:", page1)                                  // [10, 9, 8]

    print("Offset page 2:", offsetPage(feedAfterInsert, offset: 3, limit: 3))   // [8, 7, 6] ❌ 8 duplicated

    if let lastID = page1.last {
        print("Cursor page 2:", cursorPage(feedAfterInsert, after: lastID, limit: 3))   // [7, 6, 5] ✅
    }
}


//==============================================================
// MARK: - 04. UI Details
//==============================================================
//
// 1. Footer spinner while loading; "Retry" button on failure.
// 2. Append with insertRows or a diffable snapshot — never reloadData for a page.
// 3. Deduplicate by ID before appending (defensive, even with cursors).
// 4. Pull-to-refresh → reset: items = [], page = 1 / cursor = nil, hasMore = true.
// 5. Cancel the in-flight request when the screen goes away.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. How do you implement infinite scrolling?
//    → Trigger near the end (willDisplay / prefetching), fetch the next page, append.
//
// 2. How do you prevent duplicate page requests?
//    → An isLoading flag checked before starting a request.
//
// 3. How do you know when to stop?
//    → The API returns hasMore / next cursor; stop when there isn't one.
//
// 4. What happens to the page number when a request fails?
//    → Don't advance it — retry the same page.
//
// 5. Offset vs cursor pagination?
//    → Offset shifts when data changes (duplicates / gaps); cursor is stable.
//
// 6. How do you append a page to the table?
//    → insertRows or apply a diffable snapshot — not reloadData.
//
// 7. How does pull-to-refresh interact with pagination?
//    → Reset items, page / cursor, and hasMore, then load page 1.
//
//==============================================================
