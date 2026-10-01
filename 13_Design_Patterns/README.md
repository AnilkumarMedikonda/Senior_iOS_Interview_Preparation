# 13_Design_Patterns

The patterns that come up most in iOS interviews and real codebases — each with a runnable playground and plain-text notes.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_Singleton` | `static let shared` + `private init`, Swift 6 safety, class vs struct, injectable singleton | ✅ |
| 02 | `02_Factory` | Return protocols, environment factories, screen factory, mock factory | ✅ |
| 03 | `03_Observer` | Weak observer list, NotificationCenter, KVO, Combine | ✅ |
| 04 | `04_Adapter` | Wrap third-party SDKs, swap vendors, callback → async | ✅ |
| 05 | `05_Dependency_Injection` | Init / default / property / method injection, composition root | ✅ |
| 06 | `06_Repository` | Cache-first data access, offline fallback, mock repository | ✅ |
| 07 | `07_Delegate` | Weak delegate, returning values, optional methods, leak demo | ✅ |
| 08 | `08_NotificationCenter` | Typed payloads, selector vs block observers, Combine, async | ✅ |
| 09 | `09_Coordinator` | Parent/child coordinators, finish + remove child, deep links | ✅ |

**9 / 9 topics** ✅

Each folder: `Pattern.swift` (runnable playground) + `Pattern_Notes.txt` (concept notes).

## Which Pattern When?

| Need | Pattern |
|------|---------|
| One shared instance | Singleton |
| Hide which concrete type gets created | Factory |
| Many objects react to one change | Observer / NotificationCenter |
| One object reacts and can answer back | Delegate |
| Fit a third-party / legacy API to your protocol | Adapter |
| Pass dependencies in for testing | Dependency Injection |
| One access point for API + cache + DB | Repository |
| Navigation out of view controllers | Coordinator |

## Status

- [x] 01_Singleton
- [x] 02_Factory
- [x] 03_Observer
- [x] 04_Adapter
- [x] 05_Dependency_Injection
- [x] 06_Repository
- [x] 07_Delegate
- [x] 08_NotificationCenter
- [x] 09_Coordinator
