import UIKit

//==============================================================
// MARK: - AppDelegate & SceneDelegate
//==============================================================
//
// iOS 13+ split responsibilities:
// AppDelegate   → the PROCESS (launch, push, config) — one per app
// SceneDelegate → one UI instance / window — one per scene
// iPad can show multiple windows → multiple scenes, one AppDelegate.
//


//==============================================================
// MARK: - 01. Who Handles What
//==============================================================
//
// ┌─────────────────────────────────┬───────────────┬────────────────┐
// │ Event                           │ AppDelegate   │ SceneDelegate  │
// ├─────────────────────────────────┼───────────────┼────────────────┤
// │ App launch, SDK setup           │ ✅            │                │
// │ Push token / remote notification│ ✅            │                │
// │ Create window + root VC         │               │ ✅             │
// │ Foreground / background         │               │ ✅             │
// │ Deep link (URL scheme)          │               │ ✅             │
// │ Universal link                  │               │ ✅             │
// └─────────────────────────────────┴───────────────┴────────────────┘
//
// Before iOS 13 → AppDelegate did everything, including the window.
//


//==============================================================
// MARK: - 02. AppDelegate
//==============================================================

final class AppDelegate: UIResponder, UIApplicationDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        print("Configure SDKs, analytics, push registration")
        return true
    }

    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        print("Send push token to backend")
    }

    func application(
        _ application: UIApplication,
        configurationForConnecting connectingSceneSession: UISceneSession,
        options: UIScene.ConnectionOptions
    ) -> UISceneConfiguration {
        UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
}


//==============================================================
// MARK: - 03. SceneDelegate
//==============================================================

final class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(
        _ scene: UIScene,
        willConnectTo session: UISceneSession,
        options connectionOptions: UIScene.ConnectionOptions
    ) {
        guard let windowScene = scene as? UIWindowScene else { return }

        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = UIViewController()
        window.makeKeyAndVisible()
        self.window = window

        if let url = connectionOptions.urlContexts.first?.url {
            print("Cold start deep link:", url)          // app was NOT running
        }
    }

    func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) {
        if let url = URLContexts.first?.url {
            print("Warm deep link:", url)                // app already running
        }
    }

    func sceneDidBecomeActive(_ scene: UIScene) {}

    func sceneWillResignActive(_ scene: UIScene) {}

    func sceneWillEnterForeground(_ scene: UIScene) {}

    func sceneDidEnterBackground(_ scene: UIScene) {}
}


//==============================================================
// MARK: - 04. Deep Link: Cold vs Warm Start
//==============================================================
//
// Cold start (app not running) → URL arrives in willConnectTo connectionOptions
// Warm start (app running)     → URL arrives in scene(_:openURLContexts:)
// Handle BOTH, or links fail when the app was closed.
//


//==============================================================
// MARK: - 05. SwiftUI App
//==============================================================
//
// @main
// struct ShopApp: App {
//
//     @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate   // push, SDKs
//
//     @Environment(\.scenePhase) private var scenePhase                 // active / inactive / background
//
//     var body: some Scene {
//         WindowGroup {
//             ContentView()
//                 .onOpenURL { url in print(url) }                     // deep links
//         }
//         .onChange(of: scenePhase) { _, phase in print(phase) }
//     }
// }
//
// SwiftUI replaces SceneDelegate. AppDelegate is still used via the adaptor.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Why did Apple add SceneDelegate in iOS 13?
//    → To support multiple windows; each scene manages its own UI lifecycle.
//
// 2. AppDelegate vs SceneDelegate responsibilities?
//    → AppDelegate: process-level (launch, push). SceneDelegate: window and UI state.
//
// 3. Where is the window created?
//    → In scene(_:willConnectTo:options:).
//
// 4. How many AppDelegates and SceneDelegates can exist?
//    → One AppDelegate; one SceneDelegate instance per scene.
//
// 5. Where do deep links arrive on cold vs warm start?
//    → Cold: connectionOptions in willConnectTo. Warm: openURLContexts.
//
// 6. How does a SwiftUI app handle this?
//    → App struct + WindowGroup, @UIApplicationDelegateAdaptor, scenePhase, onOpenURL.
//
//==============================================================
