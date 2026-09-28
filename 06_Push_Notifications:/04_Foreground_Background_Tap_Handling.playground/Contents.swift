import UIKit
import UserNotifications

//==============================================================
// MARK: - Foreground, Background & Tap Handling
//==============================================================
//
// UNUserNotificationCenterDelegate decides what happens when a push arrives.
// willPresent → push arrives while the app is in the FOREGROUND
// didReceive  → user TAPS the notification (any app state)
// Delegate callbacks are reference code; the tap routing below runs.
//


//==============================================================
// MARK: - 01. Who Gets Called
//==============================================================
//
// ┌────────────────────────────┬──────────────────────────────────────────┐
// │ App state when push arrives│ What happens                             │
// ├────────────────────────────┼──────────────────────────────────────────┤
// │ Foreground                 │ willPresent — hidden unless you return   │
// │                            │ presentation options                     │
// │ Background, user taps      │ didReceive                               │
// │ Killed, user taps          │ App launches → didReceive                │
// │                            │ (only if delegate set in didFinishLaunch)│
// │ Silent push (any state)    │ didReceiveRemoteNotification + fetch     │
// └────────────────────────────┴──────────────────────────────────────────┘
//


//==============================================================
// MARK: - 02. Delegate Setup
//==============================================================
//
// Set the delegate in didFinishLaunching — BEFORE launch finishes.
// Set it later → a tap that cold-launched the app is lost.
//
// func application(_ application: UIApplication,
//                  didFinishLaunchingWithOptions ...) -> Bool {
//     UNUserNotificationCenter.current().delegate = pushHandler
//     return true
// }
//


//==============================================================
// MARK: - 03. Foreground — willPresent
//==============================================================
//
// By default iOS does NOT show a banner while your app is open.
// Return options to show it — or return [] to suppress it
// (e.g. a chat message for the chat the user is already viewing).
//

final class PushHandler: NSObject, UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        [.banner, .sound, .badge]
    }


//==============================================================
// MARK: - 04. Tap — didReceive
//==============================================================
//
// Read the payload, route to the screen.
// actionIdentifier tells you HOW the user interacted.
//

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse
    ) async {
        let userInfo = response.notification.request.content.userInfo

        switch response.actionIdentifier {
        case UNNotificationDefaultActionIdentifier:
            handleTap(userInfo: userInfo)                // tapped the notification
        case "ADD_TO_CART":
            print("Add to cart without opening the app")  // custom action button
        case UNNotificationDismissActionIdentifier:
            print("User dismissed")                       // needs .customDismissAction category
        default:
            break
        }
    }

    func handleTap(userInfo: [AnyHashable: Any]) {
        if let productID = userInfo["productID"] as? Int {
            print("Open ProductDetail(id: \(productID))")
        } else {
            print("No route → open Home")
        }
    }
}


//==============================================================
// MARK: - 05. Silent Push
//==============================================================
//
// Handled in the AppDelegate, not the notification center delegate.
// Always call the completion handler — within ~30 s.
//
// func application(_ application: UIApplication,
//                  didReceiveRemoteNotification userInfo: [AnyHashable: Any],
//                  fetchCompletionHandler completionHandler:
//                      @escaping (UIBackgroundFetchResult) -> Void) {
//     refreshData { changed in
//         completionHandler(changed ? .newData : .noData)
//     }
// }
//


//==============================================================
// MARK: - Run
//==============================================================

print("\n========== 04 - Tap Routing ==========")

let pushHandler = PushHandler()

pushHandler.handleTap(userInfo: ["aps": ["alert": "Price drop"], "productID": 42])   // Open ProductDetail(id: 42)

pushHandler.handleTap(userInfo: ["aps": ["alert": "Welcome back"]])                 // No route → open Home


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What happens when a push arrives while the app is in the foreground?
//    → willPresent is called; nothing shows unless you return presentation options.
//
// 2. Which method handles a notification tap?
//    → userNotificationCenter(_:didReceive:), in any app state.
//
// 3. Why set the delegate in didFinishLaunching?
//    → If the tap launched the app, a delegate set later misses the event.
//
// 4. How do you suppress a banner in the foreground?
//    → Return [] from willPresent (e.g. user is already on that chat).
//
// 5. How do you handle a silent push?
//    → didReceiveRemoteNotification:fetchCompletionHandler: — always call the handler.
//
// 6. What is actionIdentifier?
//    → Which interaction happened: default tap, dismiss, or a custom action button.
//
// 7. What happens when a user taps a push and the app was killed?
//    → The app launches, then didReceive is delivered to the delegate.
//
//==============================================================
