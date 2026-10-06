import UIKit
import PlaygroundSupport

// ============================================================
// MARK: - COORDINATOR (Navigation Pattern)
// ============================================================

/*
 Coordinator = a class that owns NAVIGATION.
 ViewControllers never push/present other screens themselves.

 SceneDelegate
      │
      ▼
 AppCoordinator ──────────────┐
      │                       │
      ▼                       ▼
 AuthCoordinator        HomeCoordinator
      │                       │
      ▼                       ▼
 LoginVC                HomeVC → ProfileVC

 VC says "this happened" → Coordinator decides "go here".
*/


// ============================================================
// MARK: - 1. Coordinator Protocol
// ============================================================

protocol Coordinator: AnyObject {

    var navigationController: UINavigationController { get }

    var childCoordinators: [Coordinator] { get set }

    func start()
}

extension Coordinator {

    func addChild(_ child: Coordinator) {
        childCoordinators.append(child)
    }

    func removeChild(_ child: Coordinator) {
        childCoordinators.removeAll { $0 === child }
    }
}


// ============================================================
// MARK: - 2. Base ViewController (title + deinit log)
// ============================================================

class BaseViewController: UIViewController {

    init(title: String) {
        super.init(nibName: nil, bundle: nil)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) not used")
    }
}


// ============================================================
// MARK: - 3. ViewControllers (only send events via closures)
// ============================================================

/*
 VCs DON'T know about other VCs or coordinators.
 They expose closures → coordinator fills them in.
*/

final class LoginViewController: BaseViewController {

    var onLoginSuccess: ((String) -> Void)?

    init() {
        super.init(title: "Login")
    }

    required init?(coder: NSCoder) { fatalError() }

    func simulateLoginTap() {
        print("👆 Login tapped")
        onLoginSuccess?("Anil")
    }
}

final class HomeViewController: BaseViewController {

    var onProfileTap: (() -> Void)?

    var onLogoutTap: (() -> Void)?

    private let userName: String

    init(userName: String) {
        self.userName = userName
        super.init(title: "Home")
    }

    required init?(coder: NSCoder) { fatalError() }

    func simulateProfileTap() {
        print("👆 Profile tapped")
        onProfileTap?()
    }

    func simulateLogoutTap() {
        print("👆 Logout tapped")
        onLogoutTap?()
    }
}

final class ProfileViewController: BaseViewController {

    let userName: String

    init(userName: String) {
        self.userName = userName
        super.init(title: "Profile(\(userName))")
    }

    required init?(coder: NSCoder) { fatalError() }
}


// ============================================================
// MARK: - 4. Child Coordinator — Auth Flow
// ============================================================

final class AuthCoordinator: Coordinator {

    let navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []

    var onFinish: ((String) -> Void)?                       // tell parent "login done"

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        let vc = LoginViewController()

        vc.onLoginSuccess = { [weak self] name in            // ✅ weak → no retain cycle
            self?.onFinish?(name)
        }

        navigationController.setViewControllers([vc], animated: false)
    }

    deinit {
        print("♻️ AuthCoordinator deinit")
    }
}


// ============================================================
// MARK: - 5. Child Coordinator — Home Flow
// ============================================================

final class HomeCoordinator: Coordinator {

    let navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []

    var onFinish: (() -> Void)?                             // tell parent "logged out"

    private let userName: String

    init(navigationController: UINavigationController, userName: String) {
        self.navigationController = navigationController
        self.userName = userName
    }

    func start() {
        let vc = HomeViewController(userName: userName)

        vc.onProfileTap = { [weak self] in
            self?.showProfile()
        }

        vc.onLogoutTap = { [weak self] in
            self?.onFinish?()
        }

        navigationController.setViewControllers([vc], animated: false)   // replace stack
    }

    func showProfile() {
        let vc = ProfileViewController(userName: userName)                // pass data
        navigationController.pushViewController(vc, animated: false)
    }

    deinit {
        print("♻️ HomeCoordinator deinit")
    }
}


// ============================================================
// MARK: - 6. App Coordinator (Root — decides which flow)
// ============================================================

final class AppCoordinator: Coordinator {

    let navigationController: UINavigationController

    var childCoordinators: [Coordinator] = []

    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }

    func start() {
        showAuth()
    }

    private func showAuth() {
        let auth = AuthCoordinator(navigationController: navigationController)

        auth.onFinish = { [weak self, weak auth] name in
            guard let self, let auth else { return }
            self.removeChild(auth)                           // ✅ free finished flow
            self.showHome(userName: name)
        }

        addChild(auth)                                       // ✅ keep it alive
        auth.start()
    }

    private func showHome(userName: String) {
        let home = HomeCoordinator(navigationController: navigationController,
                                   userName: userName)

        home.onFinish = { [weak self, weak home] in
            guard let self, let home else { return }
            self.removeChild(home)
            self.showAuth()
        }

        addChild(home)
        home.start()
    }

    // Deep link: jump straight to a screen
    func handleDeepLink(_ path: String) {
        guard path == "profile",
              let home = childCoordinators.first(where: { $0 is HomeCoordinator }) as? HomeCoordinator
        else {
            print("🔗 Deep link ignored (not logged in)")
            return
        }
        print("🔗 Deep link → profile")
        home.showProfile()
    }
}


// ============================================================
// MARK: - 7. SceneDelegate Setup (real app)
// ============================================================

/*
 final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

     var window: UIWindow?
     var appCoordinator: AppCoordinator?              // ✅ STRONG — else deallocated

     func scene(_ scene: UIScene,
                willConnectTo session: UISceneSession,
                options connectionOptions: UIScene.ConnectionOptions) {

         guard let windowScene = scene as? UIWindowScene else { return }

         let nav = UINavigationController()
         appCoordinator = AppCoordinator(navigationController: nav)
         appCoordinator?.start()

         window = UIWindow(windowScene: windowScene)
         window?.rootViewController = nav
         window?.makeKeyAndVisible()
     }
 }
*/


// ============================================================
// MARK: - Helpers
// ============================================================

let nav = UINavigationController()

PlaygroundPage.current.liveView = nav

func printStack(_ label: String) {
    let stack = nav.viewControllers.compactMap { $0.title }.joined(separator: " → ")
    print("📚 \(label): [\(stack)]")
}


// ============================================================
// MARK: - Run
// ============================================================

let appCoordinator = AppCoordinator(navigationController: nav)

print("\n========== 01 - Start (Auth Flow) ==========")

appCoordinator.start()

printStack("Stack")

print("Children:", appCoordinator.childCoordinators.map { type(of: $0) })

print("\n========== 02 - Deep Link Before Login ==========")

appCoordinator.handleDeepLink("profile")

print("\n========== 03 - Login → Home Flow ==========")

(nav.topViewController as? LoginViewController)?.simulateLoginTap()

printStack("Stack")

print("Children:", appCoordinator.childCoordinators.map { type(of: $0) })

print("\n========== 04 - Home → Profile (Push + Data) ==========")

(nav.topViewController as? HomeViewController)?.simulateProfileTap()

printStack("Stack")

print("\n========== 05 - Back Button (Pop) ==========")

nav.popViewController(animated: false)

printStack("Stack")

print("\n========== 06 - Deep Link After Login ==========")

appCoordinator.handleDeepLink("profile")

printStack("Stack")

nav.popViewController(animated: false)

print("\n========== 07 - Logout → Back to Auth ==========")

(nav.topViewController as? HomeViewController)?.simulateLogoutTap()

printStack("Stack")

print("Children:", appCoordinator.childCoordinators.map { type(of: $0) })

print("\n========== Done ==========")


// ============================================================
// MARK: - 8. Two Ways VC → Coordinator
// ============================================================

/*
 A) Closures (used above) ✅ recommended
    vc.onLoginSuccess = { [weak self] name in ... }
    → VC knows NOTHING about coordinators. Most reusable.

 B) weak coordinator reference
    final class LoginVC: UIViewController {
        weak var coordinator: AuthCoordinator?
        func loginTapped() { coordinator?.finishLogin() }
    }
    → Simple, but VC is tied to one coordinator type.
*/


// ============================================================
// MARK: - 9. Pitfalls
// ============================================================

/*
 ❌ AppCoordinator not stored strongly in SceneDelegate → deallocated, nothing works
 ❌ Child coordinator not added to childCoordinators → deallocated immediately
 ❌ Child never removed after finishing → memory leak
 ❌ Strong self in VC closures → retain cycle (VC ↔ Coordinator) → use [weak self]
 ❌ VC still calls pushViewController itself → defeats the pattern
 ❌ One giant AppCoordinator for every screen → split into child coordinators
 ❌ Back button (system pop) not handled → child coordinator stays alive
    → fix with UINavigationControllerDelegate didShow, check popped VC
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is a Coordinator?
     → An object that owns navigation flow; VCs only report events.

 Q2. Why use it?
     → VCs become independent & reusable, navigation is in one place,
       flows are easy to change and test.

 Q3. What are child coordinators?
     → Sub-flows (Auth, Home, Checkout) owned by a parent coordinator,
       stored in childCoordinators and removed when finished.

 Q4. How does the VC talk to the coordinator?
     → Closures (preferred) or a weak coordinator reference / delegate.

 Q5. Why weak?
     → Coordinator holds nav → nav holds VC → VC holds closure.
       Strong self in closure = retain cycle.

 Q6. Who owns the root coordinator?
     → SceneDelegate (or AppDelegate), as a strong property.

 Q7. How do you pass data between screens?
     → Coordinator creates the next VC and injects data via init
       (e.g. ProfileViewController(userName:)).

 Q8. Coordinator + MVVM?
     → MVVM-C: ViewModel exposes events, Coordinator handles navigation.

 Q9. How to handle the system back button?
     → UINavigationControllerDelegate navigationController(_:didShow:animated:)
       → if the popped VC belonged to a child, removeChild.
*/
