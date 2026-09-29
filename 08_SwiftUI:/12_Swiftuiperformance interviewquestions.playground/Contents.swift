import SwiftUI

//==============================================================
// MARK: - SwiftUI Performance — Interview Questions
//==============================================================
//
// High-priority only. One-line answers — expand verbally.
//


//==============================================================
// MARK: - Rendering & body
//==============================================================
//
// Q01. When does SwiftUI re-run a view's body?
//    → When state or observed data it READS changes. Debug with Self._printChanges().
//
// Q02. Does re-running body redraw the whole screen?
//    → No. body builds a cheap description; SwiftUI diffs it and updates only what changed.
//
// Q03. Why must body stay cheap?
//    → It can run many times — sorting, formatting, or creating objects there repeats every time.
//
// Q04. What should never go inside body?
//    → Network calls, heavy processing, formatters, view model creation — use .task and the model.
//


//==============================================================
// MARK: - State & Updates
//==============================================================
//
// Q05. @Observable vs ObservableObject — performance difference?
//    → @Observable re-renders only views that read the changed property;
//      ObservableObject re-renders every observer on any @Published change.
//
// Q06. How does splitting a view into smaller views help?
//    → A child whose inputs didn't change skips its body — pass the smallest input it needs.
//
// Q07. How does state ownership affect performance?
//    → State high in the tree re-renders everything below — keep state as local as possible.
//
// Q08. What does .equatable() do?
//    → Skips a view's update when its input is equal — use when profiling shows a benefit.
//


//==============================================================
// MARK: - Identity & Lists
//==============================================================
//
// Q09. Why does view identity matter for performance?
//    → Stable identity lets SwiftUI update existing views instead of destroying and recreating them.
//
// Q10. Why are stable IDs important in ForEach / List?
//    → Correct inserts, deletes, and moves; index or random IDs cause rebuilds and wrong row state.
//
// Q11. VStack vs LazyVStack (and LazyVGrid)?
//    → VStack builds every child now; lazy containers build only what's near the screen.
//
// Q12. Is AnyView always bad?
//    → No, but it erases the view type — breaks structural identity and diffing. Use only when needed.
//


//==============================================================
// MARK: - Images & Scrolling
//==============================================================
//
// Q13. How do you optimize an image-heavy grid?
//    → LazyVGrid, stable IDs, right-sized images from the server, downsample off main, cache them.
//
// Q14. Does AsyncImage cache images?
//    → Not persistently — use an image cache (NSCache / URLCache) for scrolling lists.
//
// Q15. What makes SwiftUI scrolling slow?
//    → Heavy row bodies, large image decoding on main, too many state updates,
//      deep GeometryReader / nested layouts.
//


//==============================================================
// MARK: - Concurrency Traps
//==============================================================
//
// Q16. Does async automatically make an operation faster?
//    → No. It avoids blocking the thread; the work itself costs the same.
//
// Q17. Does @MainActor mean the code is fast?
//    → No. It only guarantees main-thread isolation — heavy sync work there still freezes the UI.
//


//==============================================================
// MARK: - Measuring
//==============================================================
//
// Q18. Which tools find SwiftUI performance problems?
//    → Instruments SwiftUI template (View Body counts), Animation Hitches, Time Profiler,
//      Allocations — plus Self._printChanges() in code.
//
// Q19. What is the right way to optimize?
//    → Reproduce, measure, fix the actual bottleneck, measure again — never guess.
//
//==============================================================
