# 03_Memory_ARC

Automatic Reference Counting — how Swift manages memory, how retain cycles happen, and how to find and fix leaks. The most-asked memory topic in senior iOS interviews.

**Branch:** `feature/swift`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_ARC_Basics` | Reference counting, scope, value types, ARC can't break cycles | ✅ |
| 02 | `02_Strong_References` | Ownership, collections, closures keep objects alive | ✅ |
| 03 | `03_Weak_References` | `weak var`, auto-nil, must be Optional, weak delegates | ✅ |
| 04 | `04_Unowned_References` | `unowned`, crash risk, weak vs unowned | ✅ |
| 05 | `05_Retain_Cycles` | Parent–child, delegate, indirect cycles, finding leaks | ✅ |
| 06 | `06_Closure_Retain_Cycles` | `self → closure → self`, escaping ≠ leak, real-world sources | ✅ |
| 07 | `07_Capture_Lists` | `[weak self]`, `[unowned self]`, value capture, `[self]` trap | ✅ |
| 08 | `08_Weak_Self` | `guard let self` vs `self?`, when it's needed | ✅ |
| 09 | `09_Deinit` | `deinit` order, cleanup, leak verification | ✅ |
| 10 | `10_Escaping_vs_NonEscaping` | Memory view — cycle risk, delayed deinit | ✅ |

**10 / 10 topics** ✅

## Coding Practice

| File | Questions |
|------|-----------|
| `ARC_CodingPractice` | Q01–Q21 — strong, weak, unowned, cycles, deinit order |
| `ARC_Closures_CodingPractice` | Q01–Q10 — closures and memory |
| `EscapingVsNonEscaping_CodingPractice` | Q01–Q08 — escaping order and deinit timing |

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- `deinit` prints to prove objects are freed
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Separate Coding Practice playgrounds (predict the output)
- Interview-level concepts only

## Status

- [x] 01_ARC_Basics
- [x] 02_Strong_References
- [x] 03_Weak_References
- [x] 04_Unowned_References
- [x] 05_Retain_Cycles
- [x] 06_Closure_Retain_Cycles
- [x] 07_Capture_Lists
- [x] 08_Weak_Self
- [x] 09_Deinit
- [x] 10_Escaping_vs_NonEscaping
