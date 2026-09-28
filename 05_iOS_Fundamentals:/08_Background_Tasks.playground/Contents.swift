import UIKit
import BackgroundTasks

//==============================================================
// MARK: - Background Tasks
//==============================================================
//
// After entering background, an app gets a few seconds, then is suspended.
// To keep working you must ask the system — and the SYSTEM decides when.
// Reference code — a playground can't run background tasks.
//


//==============================================================
// MARK: - 01. Options
//==============================================================
//
// ┌─────────────────────────────┬──────────────────┬───────────────────────────────┐
// │ API                         │ Time             │ Use for                       │
// ├─────────────────────────────┼──────────────────┼───────────────────────────────┤
// │ beginBackgroundTask         │ ~30 s            │ Finish work the user started  │
// │ BGAppRefreshTask            │ ~30 s            │ Fetch fresh content           │
// │ BGProcessingTask            │ Minutes          │ Heavy work (DB cleanup, ML)   │
// │ Background URLSession       │ Until done       │ Large downloads / uploads     │
// │ Silent push                 │ ~30 s            │ Server-triggered refresh      │
// │ Background modes            │ Continuous       │ Audio, location, VoIP only    │
// └─────────────────────────────┴──────────────────┴───────────────────────────────┘
//


//==============================================================
// MARK: - 02. beginBackgroundTask
//==============================================================
//
// Finish an upload that started just before the user left the app.
// Always end the task — or the app gets killed.
//

@MainActor
final class OrderUploader {

    private var taskID: UIBackgroundTaskIdentifier = .invalid

    func uploadOrder() {
        taskID = UIApplication.shared.beginBackgroundTask(withName: "UploadOrder") { [weak self] in
            self?.endTask()                          // time ran out
        }

        Task {
            try? await Task.sleep(for: .seconds(2))  // upload
            print("Order uploaded")
            endTask()                                // finished
        }
    }

    private func endTask() {
        guard taskID != .invalid else { return }
        UIApplication.shared.endBackgroundTask(taskID)
        taskID = .invalid
    }
}


//==============================================================
// MARK: - 03. BGTaskScheduler — App Refresh
//==============================================================
//
// Setup:
// 1. Capabilities → Background Modes → Background fetch
// 2. Info.plist → BGTaskSchedulerPermittedIdentifiers → "com.shop.refresh"
// 3. Register in didFinishLaunching (before launch finishes)
// 4. Schedule when entering background
//

@MainActor
enum RefreshScheduler {

    static let identifier = "com.shop.refresh"

    static func register() {
        BGTaskScheduler.shared.register(forTaskWithIdentifier: identifier, using: .main) { task in
            guard let refreshTask = task as? BGAppRefreshTask else { return }
            MainActor.assumeIsolated {                   // delivered on .main → safe
                handle(refreshTask)
            }
        }
    }

    static func schedule() {
        let request = BGAppRefreshTaskRequest(identifier: identifier)
        request.earliestBeginDate = Date(timeIntervalSinceNow: 15 * 60)   // hint, not a promise
        do {
            try BGTaskScheduler.shared.submit(request)
        } catch {
            print("Could not schedule:", error)
        }
    }

    static func handle(_ task: BGAppRefreshTask) {
        schedule()                                       // schedule the NEXT one

        let work = Task {                                // inherits @MainActor → task stays in one domain
            try? await Task.sleep(for: .seconds(1))      // fetch latest products
            task.setTaskCompleted(success: !Task.isCancelled)
        }

        task.expirationHandler = {
            work.cancel()                                // out of time → Task completes with false
        }
    }
}


//==============================================================
// MARK: - 04. Background URLSession
//==============================================================
//
// The system transfers the file — even if the app is suspended or killed.
//
// let config = URLSessionConfiguration.background(withIdentifier: "com.shop.downloads")
// let session = URLSession(configuration: config, delegate: self, delegateQueue: nil)
// session.downloadTask(with: url).resume()
//
// When done, iOS relaunches the app →
// application(_:handleEventsForBackgroundURLSession:completionHandler:)
//


//==============================================================
// MARK: - 05. Rules
//==============================================================
//
// 1. The system decides WHEN — based on battery, network, and how often the user opens the app.
// 2. earliestBeginDate is a minimum, not an exact time.
// 3. Always call setTaskCompleted / endBackgroundTask — or the app is penalized or killed.
// 4. Set an expirationHandler — stop work fast when time runs out.
// 5. Low Power Mode or the user force-quitting the app → tasks don't run.
// 6. Debug in LLDB:
//    e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"com.shop.refresh"]
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What happens to an app after it enters the background?
//    → A few seconds of execution, then it's suspended.
//
// 2. How do you finish a task the user started before leaving?
//    → beginBackgroundTask, then endBackgroundTask when done or expired.
//
// 3. BGAppRefreshTask vs BGProcessingTask?
//    → Refresh: short (~30 s) content updates. Processing: minutes of heavy work.
//
// 4. Can you choose exactly when a background task runs?
//    → No. earliestBeginDate is a hint — the system decides.
//
// 5. How do you download large files in the background?
//    → A background URLSession — the system continues the transfer.
//
// 6. What if you forget setTaskCompleted?
//    → The system penalizes the app and may stop scheduling its tasks.
//
// 7. Do background tasks run after the user force-quits the app?
//    → No.
//
//==============================================================
