import Foundation

//==============================================================
// MARK: - GCD (Grand Central Dispatch)
//==============================================================
//
// You submit work to queues; GCD manages the threads.
// main   → serial, UI work
// global → concurrent, system-provided, background work
// custom → your own queue (serial by default)
//


//==============================================================
// MARK: - 01. main vs global
//==============================================================

print("\n========== 01 - main vs global ==========")

DispatchQueue.global().async {

    print("1. Fetching on background")

    DispatchQueue.main.async {
        print("2. Updating UI on main")
    }
}


//==============================================================
// MARK: - 02. Quality of Service (QoS)
//==============================================================
//
// Priority hint for the system — higher QoS gets resources first.
//
// userInteractive → animations, instant UI response
// userInitiated   → user is waiting (open a document)
// default         → no specific priority
// utility         → long, visible progress (downloads)
// background      → user doesn't see it (sync, backup)
//

print("\n========== 02 - Quality of Service ==========")

DispatchQueue.global(qos: .userInitiated).async {
    print("userInitiated work")
}

DispatchQueue.global(qos: .background).async {
    print("background work")
}


//==============================================================
// MARK: - 03. asyncAfter
//==============================================================
//
// Run after a delay without blocking the thread.
//

print("\n========== 03 - asyncAfter ==========")

DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
    print("Runs after 1 second")
}


//==============================================================
// MARK: - 04. Custom Queue
//==============================================================
//
// Serial by default. Add .concurrent for a concurrent queue.
// Details → 03_Serial_vs_Concurrent
//

print("\n========== 04 - Custom Queue ==========")

let imageQueue = DispatchQueue(label: "com.app.images")

let uploadQueue = DispatchQueue(label: "com.app.uploads", attributes: .concurrent)

imageQueue.async {
    print("Serial custom queue")
}

uploadQueue.async {
    print("Concurrent custom queue")
}


//==============================================================
// MARK: - 05. DispatchGroup
//==============================================================
//
// Wait for several async tasks, then get ONE callback.
// enter() before each task, leave() when it finishes, notify at the end.
//

print("\n========== 05 - DispatchGroup ==========")

let group = DispatchGroup()

group.enter()

DispatchQueue.global().async {
    print("Profile loaded")
    group.leave()
}

group.enter()

DispatchQueue.global().async {
    print("Orders loaded")
    group.leave()
}

group.notify(queue: .main) {
    print("All loaded — refresh UI")
}

// Output: Profile / Orders (any order) → All loaded — refresh UI


//==============================================================
// MARK: - 06. DispatchWorkItem — Cancel
//==============================================================
//
// Wrap work so it can be cancelled before it runs.
// Classic use: search debounce.
//

print("\n========== 06 - DispatchWorkItem ==========")

let searchItem = DispatchWorkItem {
    print("Searching...")
}

DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: searchItem)

searchItem.cancel()

print("Search cancelled:", searchItem.isCancelled)   // true — "Searching..." never prints


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is GCD?
//    → A queue-based API: you submit work, the system manages threads.
//
// 2. main vs global queue?
//    → main = serial, UI thread. global = concurrent, shared background queues.
//
// 3. What is QoS?
//    → A priority hint — userInteractive highest, background lowest.
//
// 4. Is a custom DispatchQueue serial or concurrent?
//    → Serial by default; pass .concurrent to change it.
//
// 5. How do you wait for multiple API calls to finish?
//    → DispatchGroup: enter / leave per call, notify when all are done.
//
// 6. How do you cancel GCD work?
//    → Wrap it in a DispatchWorkItem and call cancel() before it runs.
//
//==============================================================
