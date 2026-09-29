# 12_Architecture

How to structure an iOS app so it stays testable and easy to change — who owns state, where business logic lives, and how screens navigate. Senior interviews ask you to compare these and justify your choice for a real app.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_MVC` | Model–View–Controller, Massive View Controller problem | ⬜ |
| 02 | `02_MVVM` | ViewModel, bindings (Combine / `@Observable`), testable logic | ⬜ |
| 03 | `03_Coordinator` | Navigation out of view controllers, child coordinators, MVVM-C | ⬜ |
| 04 | `04_VIPER` | View, Interactor, Presenter, Entity, Router — when it's worth it | ⬜ |
| 05 | `05_Clean_Architecture` | Layers, dependency rule, use cases, domain vs data | ⬜ |

**0 / 5 topics**

## Architecture vs Pattern vs Principle

| Term | What it is | Example |
|------|------------|---------|
| Architecture | Overall app structure | MVVM, VIPER, Clean |
| Design pattern | Reusable solution to one problem | Repository, Dependency Injection (`13_Design_Patterns`) |
| Principle | A design rule | Dependency Inversion (`14_SOLID/05_DIP`) |

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [ ] 01_MVC
- [ ] 02_MVVM
- [ ] 03_Coordinator
- [ ] 04_VIPER
- [ ] 05_Clean_Architecture
