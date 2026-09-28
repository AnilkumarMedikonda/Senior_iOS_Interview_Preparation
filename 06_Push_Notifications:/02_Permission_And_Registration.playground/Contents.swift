import UIKit
import UserNotifications

//==============================================================
// MARK: - Permission & Registration
//==============================================================
//
// Two SEPARATE steps:
// 1. Permission   → requestAuthorization → can we SHOW alerts, sounds, badges?
// 2. Registration → registerForRemoteNotifications → get a device token from APNs
//
// Registration works even if permission is denied (silent pushes still arrive).
// Reference code — a playground can't show the permission prompt.
//


//==============================================================
// MARK: - 01. Request Permission + Register
//==============================================================

@MainActor
final class PushManager {

    func requestPermission() async {
        let center = UNUserNotificationCenter.current()
        do {
            let granted = try await center.requestAuthorization(options: [.alert, .sound, .badge])
            print("Permission granted:", granted)
            if granted {
                UIApplication.shared.registerForRemoteNotifications()   // → token callback in AppDelegate
            }
        } catch {
            print("Permission error:", error)
        }
    }


//==============================================================
// MARK: - 02. Check Current Status
//==============================================================
//
// Check before asking — the system prompt appears only ONCE.
//

    func checkStatus() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        switch settings.authorizationStatus {
        case .notDetermined:
            print("Never asked → safe to show the prompt")
        case .authorized:
            print("Allowed → register for the token")
        case .denied:
            print("Denied → prompt won't show again, send user to Settings")
        case .provisional:
            print("Provisional → quiet delivery to Notification Center")
        case .ephemeral:
            print("Ephemeral → App Clip, temporary permission")
        @unknown default:
            print("Future status")
        }
    }


//==============================================================
// MARK: - 03. Provisional Authorization
//==============================================================
//
// No prompt. Notifications go quietly to Notification Center.
// User decides to "Keep" or "Turn Off" from the notification itself.
//

    func requestProvisional() async {
        let options: UNAuthorizationOptions = [.alert, .sound, .badge, .provisional]
        _ = try? await UNUserNotificationCenter.current().requestAuthorization(options: options)
    }


//==============================================================
// MARK: - 04. Denied → Open Settings
//==============================================================
//
// After a denial the system never shows the prompt again.
// Only the user can change it — send them to the app's notification settings.
//

    func openNotificationSettings() {
        if let url = URL(string: UIApplication.openNotificationSettingsURLString) {
            UIApplication.shared.open(url)       // iOS 16+ — opens straight to Notifications
        }
    }
}


//==============================================================
// MARK: - 05. Registration Callbacks (AppDelegate)
//==============================================================
//
// func application(_ application: UIApplication,
//                  didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
//     // ✅ send token to backend → 03_Device_Token
// }
//
// func application(_ application: UIApplication,
//                  didFailToRegisterForRemoteNotificationsWithError error: Error) {
//     // ❌ simulator without push support, missing Push capability, no network
// }
//
// Requirements: Signing & Capabilities → Push Notifications.
// Silent push also needs → Background Modes → Remote notifications.
//


//==============================================================
// MARK: - 06. When to Ask
//==============================================================
//
// ❌ On first launch, before the user knows the app → high denial rate
// ✅ After a meaningful moment ("Notify me when this is back in stock")
// ✅ Pre-permission screen first — your own UI explaining the value,
//    then trigger the system prompt only if the user taps "Allow"
//
// You only get ONE system prompt — don't waste it.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Permission vs registration?
//    → Permission controls showing alerts; registration gets the device token. They're separate.
//
// 2. Can you get a device token if the user denies permission?
//    → Yes. Registration still works — silent pushes can arrive, alerts can't.
//
// 3. Can you show the permission prompt again after a denial?
//    → No. Only the user can re-enable it in Settings.
//
// 4. What is provisional authorization?
//    → No prompt; notifications arrive quietly in Notification Center until the user decides.
//
// 5. How do you check the current permission?
//    → UNUserNotificationCenter.notificationSettings().authorizationStatus.
//
// 6. When should you ask for permission?
//    → At a meaningful moment, after a pre-permission screen — not on first launch.
//
// 7. Why would registration fail?
//    → Missing Push capability, unsupported simulator, or no network.
//
//==============================================================
