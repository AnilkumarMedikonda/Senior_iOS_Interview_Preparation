# 08_SwiftUI

Declarative UI — views as a function of state, property wrappers for data flow, Observation, view identity, navigation, performance, and UIKit interop. Senior interviews focus on data flow ("who owns this state?") and why views re-render.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_SwiftUI_Basics` | Declarative model, cheap view structs, modifier order, conditional views | ✅ |
| 02 | `02_State` | `@State`, survival on recreation, initial value trap, `_printChanges` | ✅ |
| 03 | `03_Binding` | Parent-child editing, struct property bindings, custom bindings | ✅ |
| 04 | `04_StateObject` | View-owned ViewModel, lifetime, parameter trap + `.id()` fix | ✅ |
| 05 | `05_ObservedObject` | Recreation bug, shared model, manual `objectWillChange` | ✅ |
| 06 | `06_Environment` | System values, custom keys, `@EnvironmentObject`, when to use | ✅ |
| 07 | `07_Observation_Framework` | `@Observable` fine-grained updates vs ObservableObject, `@Bindable` | ✅ |
| 08 | `08_View_Identity` | Structural vs explicit identity, `.id()` reset, ForEach index bug | ✅ |
| 09 | `09_NavigationStack` | Typed routes, Router, programmatic navigation, deep link path | ✅ |
| 10 | `10_SwiftUI_Performance` | Cheap body, view splitting, lazy stacks, 19 interview questions | ✅ |
| 11 | `11_UIKit_SwiftUI_Interop` | `UIViewRepresentable`, Coordinator, `UIHostingController` | ✅ |

**11 / 11 topics** ✅

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Live previews via `PlaygroundPage.current.setLiveView(...)` where useful
- Interview-level concepts only

## Status

- [x] 01_SwiftUI_Basics
- [x] 02_State
- [x] 03_Binding
- [x] 04_StateObject
- [x] 05_ObservedObject
- [x] 06_Environment
- [x] 07_Observation_Framework
- [x] 08_View_Identity
- [x] 09_NavigationStack
- [x] 10_SwiftUI_Performance
- [x] 11_UIKit_SwiftUI_Interop
