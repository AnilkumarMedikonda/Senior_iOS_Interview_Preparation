# 17_Interview_Questions

Final revision — the highest-priority senior iOS interview questions from every folder, with short, spoken-style answers. Use this the night before an interview.

**Branch:** `feature/interview`

## Topics

| # | Topic | Covers | Qs | Status |
|---|-------|--------|:--:|:------:|
| 01 | `01_Swift_Questions` | Value vs reference, optionals, closures, protocols, generics, `any` vs `some`, ARC | 22 | ✅ |
| 02 | `02_iOS_Questions` | App & VC lifecycle, delegation, deep links, push, UIKit lists, Auto Layout, persistence | 20 | ✅ |
| 03 | `03_SwiftUI_Questions` | State ownership, property wrappers, `@Observable`, view identity, navigation, Combine | 19 | ✅ |
| 04 | `04_Concurrency_Questions` | GCD, async/await, Task, actors, `@MainActor`, Sendable, cancellation, race conditions | 18 | ✅ |
| 05 | `05_Networking_Questions` | URLSession, API client design, errors, token refresh, caching, SSL pinning | 18 | ✅ |
| 06 | `06_Architecture_Questions` | MVC → MVVM → MVVM-C → VIPER → Clean, design patterns, SOLID, testing | 20 | ✅ |
| 07 | `07_Performance_Questions` | Scrolling, memory, leaks, hangs, Instruments, crashes | 17 | ✅ |
| 08 | `08_Senior_Level_Questions` | Design decisions, trade-offs, production incidents, scaling a codebase | 20 | ✅ |

**8 / 8 topics** ✅ · **154 questions**

## File Format

Each folder: `Topic_Questions.txt` (plain text) + `TopicQuestions.swift` (playground with code proofs)

```
Q1. Question?

A:
Short answer — what you'd actually say in 2–3 sentences.

Follow-up:
The question the interviewer usually asks next.
```

- High-priority questions only — not everything
- Answers short enough to say out loud
- Links back to the topic folder for the details
- Playground proves the answer with a tiny runnable example (`DEBUG Q##` output)

## How to Use

1. Read the question, answer out loud **before** reading the answer
2. Mark the ones you hesitate on
3. Re-read those topic folders
4. Repeat until every answer is under 30 seconds

## Status

- [x] 01_Swift_Questions
- [x] 02_iOS_Questions
- [x] 03_SwiftUI_Questions
- [x] 04_Concurrency_Questions
- [x] 05_Networking_Questions
- [x] 06_Architecture_Questions
- [x] 07_Performance_Questions
- [x] 08_Senior_Level_Questions
