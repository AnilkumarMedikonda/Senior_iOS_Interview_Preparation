import Foundation

//==============================================================
// MARK: - App Lifecycle
//==============================================================
//
// An iOS app moves through 5 states.
// The system calls lifecycle methods on each change.
// iOS 13+: UI events → SceneDelegate, process events → AppDelegate.
// (A playground can't launch an app — transitions are simulated.)
//


//==============================================================
// MARK: - 01. The Five States
//==============================================================

enum AppState: String {
    case notRunning  = "Not Running — not launched or killed"
    case inactive    = "Inactive — in foreground, not receiving events"
    case active      = "Active — in foreground, receiving events"
    case background  = "Background — not visible, can run briefly"
    case suspended   = "Suspended — in memory, NOT running code"
}

print("\n========== 01 - The Five States ==========")

for state in [AppState.notRunning, .inactive, .active, .background, .suspended] {
    print(state.rawValue)
}


//==============================================================
// MARK: - 02. Launch Flow
//==============================================================

print("\n========== 02 - Launch Flow ==========")

print("AppDelegate  → didFinishLaunchingWithOptions")   // not running → inactive

print("SceneDelegate → scene(_:willConnectTo:)")        // window + root VC

print("SceneDelegate → sceneWillEnterForeground")

print("SceneDelegate → sceneDidBecomeActive")           // inactive → active


//==============================================================
// MARK: - 03. User Goes Home
//==============================================================

print("\n========== 03 - User Goes Home ==========")

print("SceneDelegate → sceneWillResignActive")          // active → inactive

print("SceneDelegate → sceneDidEnterBackground")        // inactive → background

print("System        → suspended (no callback)")        // a few seconds later


//==============================================================
// MARK: - 04. Returning to the App
//==============================================================

print("\n========== 04 - Returning to the App ==========")

print("SceneDelegate → sceneWillEnterForeground")       // background → inactive

print("SceneDelegate → sceneDidBecomeActive")           // inactive → active


//==============================================================
// MARK: - 05. Interruptions
//==============================================================
//
// Incoming call, Control Center, Notification Center, app switcher
// → active → inactive only. App stays in the foreground.
//

print("\n========== 05 - Interruptions ==========")

print("Incoming call → sceneWillResignActive")          // pause game / video

print("Call ends     → sceneDidBecomeActive")           // resume


//==============================================================
// MARK: - 06. Termination
//==============================================================
//
// From suspended, the system can kill the app to free memory
// WITHOUT any callback. Save state when entering background,
// not in applicationWillTerminate.
//
// applicationWillTerminate → only called if the app is killed
// while running (not suspended). Don't rely on it.
//


//==============================================================
// MARK: - 07. Where to Put Work
//==============================================================
//
// ┌────────────────────────────┬──────────────────────────────────────┐
// │ Callback                   │ Do this                              │
// ├────────────────────────────┼──────────────────────────────────────┤
// │ didFinishLaunching         │ SDKs, analytics, push registration   │
// │ scene willConnectTo        │ Create window, root VC, deep link    │
// │ sceneDidBecomeActive       │ Resume timers, refresh data          │
// │ sceneWillResignActive      │ Pause game / video, stop timers      │
// │ sceneDidEnterBackground    │ Save data, release shared resources  │
// │ sceneWillEnterForeground   │ Undo background changes, refresh UI  │
// └────────────────────────────┴──────────────────────────────────────┘
//
// Keep didFinishLaunching fast — a slow launch gets the app killed by the watchdog.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What are the app states?
//    → Not running, inactive, active, background, suspended.
//
// 2. Inactive vs background?
//    → Inactive is still on screen but not receiving events; background is not visible.
//
// 3. What happens when the user presses Home?
//    → willResignActive → didEnterBackground → suspended a few seconds later.
//
// 4. What happens on an incoming call?
//    → Active → inactive only; the app stays in the foreground.
//
// 5. Where should you save user data?
//    → sceneDidEnterBackground — the app can be killed from suspended with no callback.
//
// 6. Is applicationWillTerminate always called?
//    → No. Not when the system kills a suspended app.
//
// 7. What runs in the suspended state?
//    → Nothing. The app is in memory but executes no code.
//
//==============================================================
