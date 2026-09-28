import Foundation

//==============================================================
// MARK: - TaskGroup
//==============================================================
//
// Run a DYNAMIC number of child tasks in parallel, then collect results.
// async let → fixed number known at compile time
// TaskGroup → count known only at runtime (e.g. a list of IDs)
// Children are structured: cancelled with the group, awaited before it ends.
//

func fetchImage(_ id: Int) async -> String {
    try? await Task.sleep(for: .milliseconds(Int.random(in: 50...150)))
    return "image\(id)"
}


//==============================================================
// MARK: - 01. withTaskGroup
//==============================================================
//
// Results arrive in COMPLETION order, not submission order.
//

func loadImages(_ ids: [Int]) async -> [String] {
    await withTaskGroup(of: String.self) { group in
        for id in ids {
            group.addTask { await fetchImage(id) }
        }
        var images: [String] = []
        for await image in group {
            images.append(image)
        }
        return images
    }
}


//==============================================================
// MARK: - 02. Keep the Original Order
//==============================================================
//
// Return the index with each result, then place it.
//

func loadImagesInOrder(_ ids: [Int]) async -> [String] {
    await withTaskGroup(of: (Int, String).self) { group in
        for (index, id) in ids.enumerated() {
            group.addTask { (index, await fetchImage(id)) }
        }
        var images = Array(repeating: "", count: ids.count)
        for await (index, image) in group {
            images[index] = image
        }
        return images
    }
}


//==============================================================
// MARK: - 03. withThrowingTaskGroup
//==============================================================
//
// First error → group throws, remaining children are cancelled.
//

enum ImageError: Error {
    case failed(Int)
}

func fetchOrFail(_ id: Int) async throws -> String {
    try await Task.sleep(for: .milliseconds(50))
    if id == 3 { throw ImageError.failed(id) }
    return "image\(id)"
}

func loadAllOrFail(_ ids: [Int]) async throws -> [String] {
    try await withThrowingTaskGroup(of: String.self) { group in
        for id in ids {
            group.addTask { try await fetchOrFail(id) }
        }
        var images: [String] = []
        for try await image in group {
            images.append(image)
        }
        return images
    }
}


//==============================================================
// MARK: - 04. Limit Concurrency
//==============================================================
//
// 100 downloads at once can overload network / memory.
// Start N, add a new task each time one finishes.
//

func loadLimited(_ ids: [Int], maxConcurrent: Int) async -> Int {
    await withTaskGroup(of: String.self) { group in
        var next = 0
        var done = 0
        for _ in 0..<min(maxConcurrent, ids.count) {
            let id = ids[next]
            group.addTask { await fetchImage(id) }
            next += 1
        }
        for await _ in group {
            done += 1
            if next < ids.count {
                let id = ids[next]
                group.addTask { await fetchImage(id) }
                next += 1
            }
        }
        return done
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 01 - withTaskGroup ==========")

    print(await loadImages([1, 2, 3, 4]))            // any order


    print("\n========== 02 - Keep the Original Order ==========")

    print(await loadImagesInOrder([1, 2, 3, 4]))     // [image1, image2, image3, image4]


    print("\n========== 03 - withThrowingTaskGroup ==========")

    do {
        _ = try await loadAllOrFail([1, 2, 3, 4])
    } catch {
        print("Group failed:", error)                // failed(3)
    }


    print("\n========== 04 - Limit Concurrency ==========")

    let count = await loadLimited(Array(1...10), maxConcurrent: 3)

    print("Downloaded:", count)                      // 10 — max 3 at a time
}


//==============================================================
// MARK: - 05. async let vs TaskGroup
//==============================================================
//
// ┌───────────────┬──────────────────────────┬──────────────────────────┐
// │               │ async let                │ TaskGroup                │
// ├───────────────┼──────────────────────────┼──────────────────────────┤
// │ Task count    │ Fixed, compile time      │ Dynamic, runtime         │
// │ Result types  │ Can differ               │ Same type for all        │
// │ Use for       │ Profile + orders + cart  │ List of images / IDs     │
// └───────────────┴──────────────────────────┴──────────────────────────┘
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a TaskGroup?
//    → Runs a dynamic number of child tasks in parallel and collects results.
//
// 2. async let vs TaskGroup?
//    → async let for a fixed set of calls; TaskGroup when the count is dynamic.
//
// 3. In what order do TaskGroup results arrive?
//    → Completion order. Return an index to rebuild the original order.
//
// 4. What happens when one child throws in withThrowingTaskGroup?
//    → The group throws and the remaining children are cancelled.
//
// 5. How do you limit concurrency in a TaskGroup?
//    → Start N tasks, add one more each time a task finishes.
//
// 6. Can a child task outlive the group?
//    → No. The group waits for all children before returning.
//
//==============================================================
