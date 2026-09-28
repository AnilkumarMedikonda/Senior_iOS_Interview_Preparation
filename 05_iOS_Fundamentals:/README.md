# 05_iOS_Fundamentals

How an iOS app starts, moves between states, and communicates — lifecycle, delegation, notifications, deep links, and background work. Asked in every senior iOS interview, usually with "what happens when…" questions.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_App_Lifecycle` | Five states, callback order, interruptions, termination | ✅ |
| 02 | `02_AppDelegate_SceneDelegate` | Responsibilities, window setup, cold vs warm deep links, SwiftUI App | ✅ |
| 03 | `03_ViewController_Lifecycle` | Live callbacks, push/pop order, where to put work, common mistakes | ✅ |
| 04 | `04_Delegation` | Weak delegate, data source, cell → VC, optional methods | ✅ |
| 05 | `05_NotificationCenter` | One-to-many, `userInfo`, observer removal, threading | ✅ |
| 06 | `06_Deep_Linking` | Typed routes, `URLComponents` parsing, router, pending routes | ✅ |
| 07 | `07_Universal_Links` | AASA setup, `NSUserActivity`, custom scheme comparison, gotchas | ✅ |
| 08 | `08_Background_Tasks` | `beginBackgroundTask`, `BGTaskScheduler`, background `URLSession` | ✅ |

**8 / 8 topics** ✅

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [x] 01_App_Lifecycle
- [x] 02_AppDelegate_SceneDelegate
- [x] 03_ViewController_Lifecycle
- [x] 04_Delegation
- [x] 05_NotificationCenter
- [x] 06_Deep_Linking
- [x] 07_Universal_Links
- [x] 08_Background_Tasks
