# 13_Design_Patterns

The patterns that come up most in iOS interviews and real codebases — each with when to use it and when not to.
(Delegation → `05_iOS_Fundamentals/04_Delegation`)

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_Singleton` | `static let shared`, thread safety, why it hurts testing | ⬜ |
| 02 | `02_Factory` | Hide object creation, return protocols | ⬜ |
| 03 | `03_Observer` | NotificationCenter, KVO, Combine, `@Observable` | ⬜ |
| 04 | `04_Adapter` | Wrap a third-party SDK behind your own protocol | ⬜ |
| 05 | `05_Dependency_Injection` | Init / property injection, composition root, mocks | ⬜ |
| 06 | `06_Repository` | One data access point, local + remote sources | ⬜ |

**0 / 6 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [ ] 01_Singleton
- [ ] 02_Factory
- [ ] 03_Observer
- [ ] 04_Adapter
- [ ] 05_Dependency_Injection
- [ ] 06_Repository
