import UIKit
import PlaygroundSupport

//==============================================================
// MARK: - ViewController Lifecycle
//==============================================================
//
// init → loadView → viewDidLoad → viewWillAppear
//      → viewWillLayoutSubviews → viewDidLayoutSubviews → viewDidAppear
//      → viewWillDisappear → viewDidDisappear → deinit
//
// viewDidLoad runs ONCE. Appear / disappear run EVERY time.
// Always call super.
//


//==============================================================
// MARK: - 01. Live Lifecycle
//==============================================================
//
// Setting liveView puts the VC on screen → real callbacks fire.
//

final class ProductViewController: UIViewController {

    override func loadView() {
        super.loadView()
        print("1. loadView — create the view (only if not using storyboard)")
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        print("2. viewDidLoad — one-time setup, bounds NOT final")
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("3. viewWillAppear — refresh data, every time")
    }

    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        print("4. viewWillLayoutSubviews")
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        print("5. viewDidLayoutSubviews — bounds final, adjust frames")
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        print("6. viewDidAppear — start animations, analytics")
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        print("7. viewWillDisappear — save, stop timers")
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        print("8. viewDidDisappear")
    }

    deinit {
        print("9. deinit — VC freed")
    }
}

print("\n========== 01 - Live Lifecycle ==========")

PlaygroundPage.current.liveView = ProductViewController()


//==============================================================
// MARK: - 02. Push A → B
//==============================================================
//
// B viewDidLoad
// A viewWillDisappear
// B viewWillAppear
// A viewDidDisappear
// B viewDidAppear
//
// Pop B → A: A does NOT call viewDidLoad again — only viewWillAppear / viewDidAppear.
//


//==============================================================
// MARK: - 03. Where to Put Work
//==============================================================
//
// ┌──────────────────────────┬───────────────────────────────────────────┐
// │ Method                   │ Do this                                   │
// ├──────────────────────────┼───────────────────────────────────────────┤
// │ viewDidLoad              │ Add subviews, constraints, bind ViewModel │
// │ viewWillAppear           │ Refresh data, update nav bar              │
// │ viewDidLayoutSubviews    │ Frame-based layout, corner radius         │
// │ viewDidAppear            │ Start animations, analytics, video        │
// │ viewWillDisappear        │ Save input, stop timers / observers       │
// │ deinit                   │ Verify no leak (print)                    │
// └──────────────────────────┴───────────────────────────────────────────┘
//


//==============================================================
// MARK: - 04. Common Mistakes
//==============================================================
//
// ❌ Reading view.frame in viewDidLoad — size isn't final yet
// ❌ Heavy work in viewWillAppear — runs on every appearance, delays the transition
// ❌ Forgetting super — breaks UIKit internals
// ❌ One-time setup in viewWillAppear — duplicates subviews / observers
// ❌ deinit never prints after pop — retain cycle (see 03_Memory_ARC)
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is the ViewController lifecycle order?
//    → loadView, viewDidLoad, viewWillAppear, layout calls, viewDidAppear, then disappear.
//
// 2. viewDidLoad vs viewWillAppear?
//    → viewDidLoad once for setup; viewWillAppear every time the screen shows.
//
// 3. Why are frames wrong in viewDidLoad?
//    → Layout hasn't run — use viewDidLayoutSubviews for final sizes.
//
// 4. What is the order when pushing A → B?
//    → B didLoad, A willDisappear, B willAppear, A didDisappear, B didAppear.
//
// 5. Is viewDidLoad called again when popping back?
//    → No. Only viewWillAppear and viewDidAppear.
//
// 6. When would you override loadView?
//    → To set a fully custom root view in code, without calling super.
//
// 7. How do you know a VC was freed after pop?
//    → deinit prints; if not, check the Memory Graph for a retain cycle.
//
//==============================================================
