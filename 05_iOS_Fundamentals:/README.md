# 05_iOS_Fundamentals

How an iOS app starts, moves between states, and communicates — lifecycle, delegation, notifications, deep links, and background work. Asked in every senior iOS interview, usually with "what happens when…" questions.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_App_Lifecycle` | Not running → inactive → active → background → suspended | ⬜ |
| 02 | `02_AppDelegate_SceneDelegate` | App-level vs UI-level events, multi-window, iOS 13+ split | ⬜ |
| 03 | `03_ViewController_Lifecycle` | `viewDidLoad` → `viewWillAppear` → `viewDidAppear`, layout calls | ⬜ |
| 04 | `04_Delegation` | Protocol + `weak` delegate, one-to-one communication | ⬜ |
| 05 | `05_NotificationCenter` | One-to-many broadcast, observers, removal, delegate vs notification | ⬜ |
| 06 | `06_Deep_Linking` | Custom URL schemes, parsing, routing to screens | ⬜ |
| 07 | `07_Universal_Links` | `apple-app-site-association`, associated domains, fallback to web | ⬜ |
| 08 | `08_Background_Tasks` | `BGTaskScheduler`, background fetch, time limits | ⬜ |

**0 / 8 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [ ] 01_App_Lifecycle
- [ ] 02_AppDelegate_SceneDelegate
- [ ] 03_ViewController_Lifecycle
- [ ] 04_Delegation
- [ ] 05_NotificationCenter
- [ ] 06_Deep_Linking
- [ ] 07_Universal_Links
- [ ] 08_Background_Tasks
