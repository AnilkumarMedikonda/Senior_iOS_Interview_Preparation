# 08_SwiftUI

Declarative UI — views as a function of state, property wrappers for data flow, Observation, view identity, navigation, performance, and UIKit interop. Senior interviews focus on data flow ("who owns this state?") and why views re-render.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_SwiftUI_Basics` | Declarative UI, `View` protocol, `some View`, modifiers, stacks | ⬜ |
| 02 | `02_State` | `@State`, view-owned value state, source of truth | ⬜ |
| 03 | `03_Binding` | `@Binding`, `$` projected value, two-way data flow | ⬜ |
| 04 | `04_StateObject` | `@StateObject`, view-owned reference model, lifetime | ⬜ |
| 05 | `05_ObservedObject` | `@ObservedObject`, passed-in model, recreation bug | ⬜ |
| 06 | `06_Environment` | `@Environment`, `@EnvironmentObject`, dependency passing | ⬜ |
| 07 | `07_Observation_Framework` | `@Observable`, `@Bindable`, fine-grained updates (iOS 17+) | ⬜ |
| 08 | `08_View_Identity` | Structural vs explicit identity, `id()`, `ForEach` IDs, state reset | ⬜ |
| 09 | `09_NavigationStack` | `NavigationStack`, `NavigationPath`, programmatic / deep link navigation | ⬜ |
| 10 | `10_SwiftUI_Performance` | Body re-evaluation, small views, `Equatable`, lazy stacks | ⬜ |
| 11 | `11_UIKit_SwiftUI_Interop` | `UIHostingController`, `UIViewRepresentable`, `Coordinator` | ⬜ |

**0 / 11 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Live previews via `PlaygroundPage.current.setLiveView(...)` where useful
- Interview-level concepts only

## Status

- [ ] 01_SwiftUI_Basics
- [ ] 02_State
- [ ] 03_Binding
- [ ] 04_StateObject
- [ ] 05_ObservedObject
- [ ] 06_Environment
- [ ] 07_Observation_Framework
- [ ] 08_View_Identity
- [ ] 09_NavigationStack
- [ ] 10_SwiftUI_Performance
- [ ] 11_UIKit_SwiftUI_Interop
