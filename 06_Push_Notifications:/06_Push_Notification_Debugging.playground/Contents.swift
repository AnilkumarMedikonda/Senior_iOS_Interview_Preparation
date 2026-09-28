import Foundation

//==============================================================
// MARK: - Push Notification Debugging
//==============================================================
//
// Push has many moving parts: permission, capability, token,
// environment, payload, delegate. When a push "doesn't arrive",
// check them in order — most failures are configuration, not code.
//


//==============================================================
// MARK: - 01. Testing on the Simulator
//==============================================================
//
// Create payload.apns:
//
// {
//   "Simulator Target Bundle": "com.example.shop",
//   "aps": { "alert": { "title": "Test", "body": "Hello from simulator" } },
//   "deeplink": "myshop://product/42"
// }
//
// Then either:
// → Drag the file onto the running simulator
// → Terminal: xcrun simctl push booted com.example.shop payload.apns
//
// Great for testing UI + routing without a backend.
//


//==============================================================
// MARK: - 02. Testing a Real Push
//==============================================================
//
// Apple Push Notifications Console (developer.apple.com) → send to a device token.
// Or curl with a .p8 JWT over HTTP/2:
//
// Sandbox    → https://api.sandbox.push.apple.com   (debug builds from Xcode)
// Production → https://api.push.apple.com           (TestFlight / App Store)
//
// Required headers: apns-topic (bundle ID), apns-push-type (alert / background),
// authorization (bearer JWT).
//


//==============================================================
// MARK: - 03. APNs Error Responses
//==============================================================

enum APNsError: String, CaseIterable {
    case badDeviceToken = "BadDeviceToken"
    case unregistered = "Unregistered"
    case deviceTokenNotForTopic = "DeviceTokenNotForTopic"
    case topicDisallowed = "TopicDisallowed"
    case payloadTooLarge = "PayloadTooLarge"
    case expiredProviderToken = "ExpiredProviderToken"

    var fix: String {
        switch self {
        case .badDeviceToken:
            return "Sandbox token sent to production (or reverse) — match the environment"
        case .unregistered:
            return "410 — app deleted, backend should remove the token"
        case .deviceTokenNotForTopic:
            return "apns-topic doesn't match the app's bundle ID"
        case .topicDisallowed:
            return "Push capability / key not enabled for this bundle ID"
        case .payloadTooLarge:
            return "Payload over 4 KB — send an ID, fetch details in the app"
        case .expiredProviderToken:
            return "JWT older than 1 hour — regenerate it"
        }
    }
}

print("\n========== 03 - APNs Error Responses ==========")

for error in APNsError.allCases {
    print(error.rawValue, "→", error.fix)
}


//==============================================================
// MARK: - 04. "Push Not Arriving" Checklist
//==============================================================
//
// 1. Permission → notificationSettings().authorizationStatus is .authorized?
// 2. Capability → Signing & Capabilities → Push Notifications added?
// 3. Entitlement → aps-environment matches the build (development / production)?
// 4. Token → fresh token sent to backend? Correct environment?
// 5. Foreground → UNUserNotificationCenter delegate set + willPresent returns options?
// 6. Silent push → Background Modes → Remote notifications? App not force-quit?
//    Priority 5 + apns-push-type: background?
// 7. Device → Focus / Do Not Disturb, notifications disabled for the app in Settings?
// 8. Payload → valid JSON, under 4 KB, "aps" spelled correctly?
//


//==============================================================
// MARK: - 05. Logging
//==============================================================
//
// 1. Print the hex token on every launch (debug builds only).
// 2. Console.app → select device → filter "apsd" → see APNs delivery on device.
// 3. Log didFailToRegisterForRemoteNotificationsWithError — the error says why.
// 4. Notification Service Extension → runs on delivery → can log "delivered"
//    even if the user never taps.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. How do you test push notifications without a backend?
//    → A .apns file dragged onto the simulator, or xcrun simctl push.
//
// 2. A push works in debug but not in TestFlight — why?
//    → TestFlight uses production APNs; the backend is sending to the sandbox endpoint.
//
// 3. What does BadDeviceToken mean?
//    → Token and APNs environment don't match (sandbox vs production).
//
// 4. What does 410 Unregistered mean?
//    → The app was removed — delete the token on the backend.
//
// 5. A push arrives but no banner shows while the app is open — why?
//    → willPresent isn't returning presentation options, or the delegate isn't set.
//
// 6. Why might a silent push never wake the app?
//    → Throttled, app force-quit, missing Background Modes, or wrong priority / push type.
//
// 7. How do you confirm delivery if the user doesn't tap?
//    → A Notification Service Extension can log when the push is delivered.
//
//==============================================================
