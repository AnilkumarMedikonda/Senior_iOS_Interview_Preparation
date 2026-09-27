# 02_Advanced_Swift

Protocols, generics, opaque and existential types, property wrappers, error handling, and method dispatch — the Swift internals senior interviews dig into.

**Branch:** `feature/swift`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_Protocols_And_POP` | Default implementations, `mutating`, `@objc optional`, constrained extensions, DI | ✅ |
| 02 | `02_Any_vs_Some` | `Any`, `some P` (opaque), `any P` (existential), primary associated types, type erasure | ✅ |
| 03 | `03_Generics` | Constraints, `where`, same-type constraint, generic decoding, generics vs `any` | ✅ |
| 04 | `04_Property_Wrappers` | `wrappedValue`, `projectedValue`, `@UserDefault`, `@State` / `@Published` | ✅ |
| 05 | `05_Error_Handling` | `LocalizedError`, `Result`, `rethrows`, `defer`, typed throws | ✅ |
| 06 | `06_Method_Dispatch` | Static, table, witness, message dispatch, witness traps, `final` | ✅ |

**6 / 6 topics** ✅

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions at the end
- Separate Coding Practice playground for core topics
- Interview-level concepts only

## Status

- [x] 01_Protocols_And_POP
- [x] 02_Any_vs_Some
- [x] 03_Generics
- [x] 04_Property_Wrappers
- [x] 05_Error_Handling
- [x] 06_Method_Dispatch
