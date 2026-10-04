# 18 — Output Questions

"Predict the output" practice for Senior iOS interviews. 95 questions across 8 Swift topics, written as runnable playgrounds. Questions only — no answers in the files.

---

## How to Practice

1. Open a file and comment out every `// ▶️ Run` block (select → ⌘ /)
2. Read each question and **predict the output** aloud
3. Uncomment one `// ▶️ Run` block at a time and run
4. Compare, note the miss, revise that concept

Each question prints its own header:

    ========== Q01 - Title ==========

---

## Files

| # | File | Topic | Qs | Focus |
|---|------|-------|----|-------|
| 01 | `01_Closures.swift` | Closures | 13 | Capture by reference, capture lists, class vs struct capture, escaping order, @autoclosure, retain cycle |
| 02 | `02_Defer.swift` | Defer | 18 | LIFO order, scope exit, return value trick, throw, guard, lock/unlock |
| 03 | `03_HOF.swift` | Higher-Order Functions | 14 | map vs compactMap, flatMap, chaining, sorted vs sort, reduce(into:), lazy |
| 04 | `04_Protocols.swift` | Protocols | 10 | Default implementation, static vs dynamic dispatch, mutating, AnyObject + weak, associatedtype |
| 05 | `05_Any_Some.swift` | Any vs some vs any | 7 | Type casting, existentials, opaque types |
| 06 | `06_Extensions.swift` | Extensions | 9 | Computed properties, memberwise init, constrained extensions, nested types |
| 07 | `07_ARC.swift` | Memory & ARC | 11 | deinit timing, retain cycles, weak / unowned, closure cycles |
| 08 | `08_Concurrency.swift` | Concurrency | 13 | GCD order, deadlock, race condition, Task, async let, actors, cancellation, reentrancy |

---

## Top Traps

- `map` keeps optionals — `compactMap` drops them
- Extension-only protocol method → static dispatch
- Capture list freezes the reference, not the object
- `defer` runs after the return value is computed
- `main.async` runs after the current code
- `main.sync` on main → deadlock
- `async let` runs in parallel — total time = longest task
- Actor state can change across `await`

---

## Status

8 / 8 files complete · 95 questions
