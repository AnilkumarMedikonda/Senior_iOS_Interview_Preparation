# 03_Memory_ARC

Automatic Reference Counting — how Swift manages memory, how retain cycles happen, and how to find and fix leaks. The most-asked memory topic in senior iOS interviews.

**Branch:** `feature/swift`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_ARC_Basics` | Reference counting, when objects are freed, value vs reference types | ⬜ |
| 02 | `02_Strong_References` | Default ownership, retain count increase | ⬜ |
| 03 | `03_Weak_References` | `weak var`, auto-nil, must be Optional, delegates | ⬜ |
| 04 | `04_Unowned_References` | `unowned`, no nil, crash risk, weak vs unowned | ⬜ |
| 05 | `05_Retain_Cycles` | Class ↔ class cycles, parent–child, delegate cycles | ⬜ |
| 06 | `06_Closure_Retain_Cycles` | `self → closure → self`, stored closures, escaping ≠ leak | ⬜ |
| 07 | `07_Capture_Lists` | `[weak self]`, `[unowned self]`, `[value]` capture | ⬜ |
| 08 | `08_Weak_Self` | `guard let self`, when `[weak self]` is / isn't needed | ⬜ |
| 09 | `09_Deinit` | `deinit` timing, leak verification, Memory Graph Debugger | ⬜ |

**0 / 9 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- `deinit` prints to prove objects are freed
- ✅ allowed / ❌ compile error
- Interview Questions at the end
- Separate Coding Practice playground (retain cycle output questions)
- Interview-level concepts only

## Status

- [ ] 01_ARC_Basics
- [ ] 02_Strong_References
- [ ] 03_Weak_References
- [ ] 04_Unowned_References
- [ ] 05_Retain_Cycles
- [ ] 06_Closure_Retain_Cycles
- [ ] 07_Capture_Lists
- [ ] 08_Weak_Self
- [ ] 09_Deinit
