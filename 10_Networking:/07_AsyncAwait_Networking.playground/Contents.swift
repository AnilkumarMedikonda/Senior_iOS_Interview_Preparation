import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - async/await Networking
//==============================================================
//
// URLSession has native async APIs: data(from:), data(for:), download, upload.
// Code reads top to bottom — no nested callbacks.
//
// Sequential → when a call needs the previous result
// async let  → a FIXED set of independent calls in parallel
// TaskGroup  → a DYNAMIC number of calls in parallel
//
// Uses jsonplaceholder.typicode.com (needs internet). Console: ⇧⌘Y
//

struct User: Decodable {
    let id: Int
    let name: String
}

struct Post: Decodable {
    let id: Int
    let title: String
}

enum NetworkError: Error {
    case badStatus(Int)
}


//==============================================================
// MARK: - 01. One Generic Request
//==============================================================

func fetch<T: Decodable>(_ path: String) async throws -> T {

    guard let url = URL(string: "https://jsonplaceholder.typicode.com\(path)") else {
        throw URLError(.badURL)
    }

    let (data, response) = try await URLSession.shared.data(from: url)

    if let http = response as? HTTPURLResponse, !(200..<300).contains(http.statusCode) {
        throw NetworkError.badStatus(http.statusCode)
    }

    return try JSONDecoder().decode(T.self, from: data)
}


//==============================================================
// MARK: - 02. Sequential — When Calls Depend on Each Other
//==============================================================
//
// Need the user's id before loading their posts → must wait.
//

func loadUserThenPosts() async throws {

    let user: User = try await fetch("/users/1")

    let posts: [Post] = try await fetch("/posts?userId=\(user.id)")   // needs user.id

    print(user.name, "has", posts.count, "posts")
}


//==============================================================
// MARK: - 03. async let — Independent Calls in Parallel
//==============================================================
//
// Home screen: user, posts, and a featured post don't depend on each other.
// Start all at once → total time ≈ the slowest call, not the sum.
//

func loadHomeSequential() async throws {
    let _: User = try await fetch("/users/1")
    let _: [Post] = try await fetch("/posts?userId=1")
    let _: Post = try await fetch("/posts/1")
}

func loadHomeParallel() async throws {
    async let user: User = fetch("/users/1")
    async let posts: [Post] = fetch("/posts?userId=1")
    async let featured: Post = fetch("/posts/1")

    let (loadedUser, loadedPosts, loadedFeatured) = try await (user, posts, featured)

    print(loadedUser.name, "|", loadedPosts.count, "posts |", loadedFeatured.title)
}


//==============================================================
// MARK: - 04. TaskGroup — Dynamic Number of Calls
//==============================================================
//
// Load N posts in parallel. Results arrive in any order → keep the index.
//

func loadPosts(ids: [Int]) async throws -> [Post] {

    try await withThrowingTaskGroup(of: (Int, Post).self) { group in

        for (index, id) in ids.enumerated() {
            group.addTask {
                let post: Post = try await fetch("/posts/\(id)")
                return (index, post)
            }
        }

        var ordered = [Post?](repeating: nil, count: ids.count)

        for try await (index, post) in group {
            ordered[index] = post
        }

        return ordered.compactMap { $0 }
    }
}


//==============================================================
// MARK: - 05. Partial Failure
//==============================================================
//
// withThrowingTaskGroup → ONE failure fails everything.
// Home feed sections: show what loaded, skip what failed.
//

func loadPostsAllowingFailures(ids: [Int]) async -> [Post] {

    await withTaskGroup(of: Post?.self) { group in

        for id in ids {
            group.addTask {
                do {
                    let post: Post = try await fetch("/posts/\(id)")
                    return post
                } catch {
                    print("Post \(id) failed — others still shown")
                    return nil
                }
            }
        }

        var posts: [Post] = []

        for await post in group {
            if let post {
                posts.append(post)
            }
        }

        return posts
    }
}


//==============================================================
// MARK: - 06. ViewModel on the Main Actor
//==============================================================
//
// Network work suspends (doesn't block main); UI state updates on main.
//

@MainActor
final class HomeViewModel {

    private(set) var headline = "Loading…"

    func load() async {
        do {
            async let user: User = fetch("/users/2")
            async let post: Post = fetch("/posts/2")
            let (loadedUser, loadedPost) = try await (user, post)
            headline = "\(loadedUser.name): \(loadedPost.title)"
        } catch {
            headline = "Could not load"
        }
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    do {
        print("\n========== 02 - Sequential ==========")

        try await loadUserThenPosts()


        print("\n========== 03 - Sequential vs Parallel ==========")

        let clock = ContinuousClock()

        let sequentialTime = try await clock.measure {
            try await loadHomeSequential()
        }

        let parallelTime = try await clock.measure {
            try await loadHomeParallel()
        }

        print("Sequential:", sequentialTime)                // ≈ sum of 3 calls
        print("Parallel:  ", parallelTime)                  // ≈ slowest single call


        print("\n========== 04 - TaskGroup ==========")

        let posts = try await loadPosts(ids: [3, 1, 2])

        for post in posts {
            print(post.id, post.title)                      // original order: 3, 1, 2
        }


        print("\n========== 05 - Partial Failure ==========")

        let partial = await loadPostsAllowingFailures(ids: [1, 99999, 2])

        print("Loaded", partial.count, "of 3")              // 2 of 3


        print("\n========== 06 - ViewModel ==========")

        let viewModel = HomeViewModel()

        await viewModel.load()

        print(viewModel.headline)
    } catch {
        print("Error:", error)
    }


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 07. Rules
//==============================================================
//
// ✅ Sequential only when a call needs the previous result
// ✅ async let for a fixed set of independent calls
// ✅ TaskGroup for a dynamic list; keep an index if order matters
// ✅ withTaskGroup + do/catch per child → partial results instead of all-or-nothing
// ✅ Update UI state on @MainActor
// ✅ Wrap old callback APIs with continuations (15_Continuations)
// ❌ Two awaits in a row for independent calls → twice as slow
// ❌ Hundreds of parallel requests at once → limit concurrency (10_TaskGroup)
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. How does async/await improve networking code?
//    → Linear code, errors via throws, built-in cancellation — no callback nesting.
//
// 2. When should calls run sequentially?
//    → Only when one call needs data from the previous one.
//
// 3. How do you run three independent requests in parallel?
//    → async let each one, then await them together.
//
// 4. async let vs TaskGroup?
//    → async let for a fixed number of calls; TaskGroup for a dynamic list.
//
// 5. How do you keep order with a TaskGroup?
//    → Return the index with each result and place it.
//
// 6. How do you avoid one failed request failing the whole screen?
//    → Catch inside each child task and return nil, then show what loaded.
//
// 7. Does await block the main thread?
//    → No — it suspends and frees the thread until the response arrives.
//
//==============================================================
