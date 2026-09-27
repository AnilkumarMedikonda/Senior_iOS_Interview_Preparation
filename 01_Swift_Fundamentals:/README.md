# 01_Swift — Language, Memory & Concurrency

Core Swift for senior iOS interviews: language fundamentals, advanced Swift, memory management with ARC, Swift Concurrency, and Combine.

**Branch:** `feature/swift`

## Folders

| # | Folder | Topics | Count | Done | Hours |
|---|--------|--------|------:|-----:|------:|
| 01 | `01_Swift_Fundamentals` | Basics, Value vs Reference Types, Enums, Optionals, Properties, Closures, Higher-Order Functions, Initialization, Access Control | 9 | 5 | 6 (with 02) |
| 02 | `02_Advanced_Swift` | Protocols & POP, Any vs Some, Generics, Property Wrappers, Error Handling, Method Dispatch | 6 | 0 | — |
| 03 | `03_Memory_ARC` | ARC Basics, Strong / Weak / Unowned, Retain Cycles, Closure Retain Cycles, Capture Lists, Weak Self, Deinit | 9 | 0 | 6 |
| 04 | `04_Swift_Concurrency` | Basics, GCD, Serial vs Concurrent, Sync vs Async, Deadlock, Race Condition, Thread Safety, async/await, Task, TaskGroup, Actors, MainActor, Cancellation, Sendable, Continuations | 15 | 0 | 10 |
| 05 | `05_Combine` | Basics, Publishers & Subscribers, Operators, Combine vs async/await | 4 | 0 | 1.5 |

**Total:** 5 / 43 topics · ~23.5 hours

## File Format

- One `.swift` file per topic
- Short sections: concept → code → inline output
- `print("\n========== NN - Title ==========")` before each section's output
- ✅ allowed / ❌ compile error
- Interview Questions list at the end
- Output Questions for core topics (Closures, ARC, Concurrency)
- Interview-level concepts only — no long notes

## Per-Topic Cycle

Build working code → Explain aloud (recorded) → Answer the interview questions → Review

## House Rules

- Every topic folder has runnable code, not just notes
- Answers in interview voice, 60–90 seconds each
- Commit messages: one line only
- Merge `feature/swift` → `main` when a folder is done

## Status

- [ ] 01_Swift_Fundamentals — 5 / 9 (Basics, Value vs Reference, Enums, Optionals, Properties)
- [ ] 02_Advanced_Swift
- [ ] 03_Memory_ARC
- [ ] 04_Swift_Concurrency
- [ ] 05_Combine
