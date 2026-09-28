import Foundation

//==============================================================
// MARK: - Device Token
//==============================================================
//
// Device token = APNs address for THIS app on THIS device.
// Arrives as raw Data in didRegisterForRemoteNotificationsWithDeviceToken.
// Backend needs it as a hex string to send pushes.
//


//==============================================================
// MARK: - 01. Data → Hex String
//==============================================================
//
// ❌ String(data: token, encoding: .utf8) → nil — it's binary, not text
// ❌ token.description → "32 bytes" on iOS 13+ (old hack broke)
// ✅ Convert each byte to 2 hex characters
//

func hexString(from token: Data) -> String {
    token.map { String(format: "%02x", $0) }.joined()
}

print("\n========== 01 - Data → Hex String ==========")

let fakeToken = Data([0x1a, 0x2b, 0x3c, 0x4d, 0xde, 0xad, 0xbe, 0xef])

print("utf8:", String(data: fakeToken, encoding: .utf8) as Any)   // nil ❌

print("description:", fakeToken.description)                       // 8 bytes ❌

print("hex:", hexString(from: fakeToken))                          // 1a2b3c4ddeadbeef ✅


//==============================================================
// MARK: - 02. Sending to the Backend
//==============================================================
//
// Send more than the token — the backend needs context.
//

struct TokenRegistration: Encodable {
    let token: String
    let platform: String
    let environment: String                  // sandbox or production
    let bundleID: String
    let userID: String?                      // nil when logged out
}

print("\n========== 02 - Sending to the Backend ==========")

let registration = TokenRegistration(
    token: hexString(from: fakeToken),
    platform: "ios",
    environment: "sandbox",
    bundleID: "com.example.shop",
    userID: "user_42"
)

let encoder = JSONEncoder()

encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

if let body = try? encoder.encode(registration), let json = String(data: body, encoding: .utf8) {
    print(json)                              // POST /devices
}


//==============================================================
// MARK: - 03. When the Token Changes
//==============================================================
//
// Token can change: app reinstall, restore from backup, new device,
// sometimes after an OS update.
// → Call registerForRemoteNotifications on EVERY launch.
// → Send to backend only if it changed.
//

final class TokenStore {

    private var lastSentToken: String?

    func didReceive(_ token: String) {
        if token == lastSentToken {
            print("Same token → skip upload")
            return
        }
        lastSentToken = token
        print("New token → upload:", token)
    }
}

print("\n========== 03 - When the Token Changes ==========")

let tokenStore = TokenStore()

tokenStore.didReceive("aaa111")              // New token → upload

tokenStore.didReceive("aaa111")              // Same token → skip upload

tokenStore.didReceive("bbb222")              // New token → upload (reinstall)


//==============================================================
// MARK: - 04. Token Lifecycle Rules
//==============================================================
//
// 1. Never hardcode the length — Apple says tokens are variable size.
// 2. Sandbox tokens (debug) ≠ production tokens (TestFlight / App Store).
//    Mismatch → APNs returns "BadDeviceToken".
// 3. APNs returns 410 "Unregistered" → app deleted → backend removes the token.
// 4. Logout → tell backend to unlink the token from the user
//    (or the next user gets the previous user's pushes).
// 5. Firebase (FCM) wraps the APNs token in its own FCM token —
//    send the FCM token to your backend instead.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a device token?
//    → The APNs address for one app on one device, used by the backend to send pushes.
//
// 2. How do you convert the token to a string?
//    → Map each byte to "%02x" and join — not String(data:encoding:).
//
// 3. When does the token change?
//    → Reinstall, restore from backup, new device, sometimes OS updates.
//
// 4. How often should you register for remote notifications?
//    → Every launch; upload to the backend only if the token changed.
//
// 5. What does a 410 Unregistered response mean?
//    → The app was removed — the backend should delete that token.
//
// 6. What should happen to the token on logout?
//    → Unlink it from the user on the backend so they stop receiving that account's pushes.
//
// 7. Why would a valid token get BadDeviceToken?
//    → Sandbox token sent to production APNs, or the reverse.
//
//==============================================================
