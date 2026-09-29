# 09_Combine

Apple's reactive framework — values over time as publishers, transformed with operators, received by subscribers. Still common in existing codebases and SwiftUI view models; interviews focus on the pipeline, memory (`AnyCancellable`), threading, and how it compares to async/await.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_Combine_Basics` | Pipeline, failure ends stream, `AnyCancellable` storage, Future vs Deferred, sink retain cycle | ✅ |
| 02 | `02_Publishers_And_Subscribers` | `Just`, `PassthroughSubject`, `CurrentValueSubject`, `@Published`, `sink`, `assign` | ⬜ |
| 03 | `03_Operators` | `map`, `filter`, `debounce`, `removeDuplicates`, `combineLatest`, `flatMap`, `receive(on:)` | ⬜ |
| 04 | `04_Combine_vs_AsyncAwait` | Streams vs single values, `AsyncSequence`, `.values`, when to use which | ⬜ |

**1 / 4 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [x] 01_Combine_Basics
- [ ] 02_Publishers_And_Subscribers
- [ ] 03_Operators
- [ ] 04_Combine_vs_AsyncAwait
