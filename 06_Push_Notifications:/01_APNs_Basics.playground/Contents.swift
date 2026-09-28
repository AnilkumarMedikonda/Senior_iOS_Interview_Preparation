import Foundation

//==============================================================
// MARK: - APNs Basics
//==============================================================
//
// APNs = Apple Push Notification service.
// Your server never talks to the device directly — it sends to APNs,
// and APNs delivers to the device.
//


//==============================================================
// MARK: - 01. The Flow
//==============================================================
//
// 1. App asks permission + registers → iOS gets a device token from APNs
// 2. App sends the token to YOUR backend
// 3. Backend sends payload + token to APNs (HTTP/2, auth key)
// 4. APNs delivers to the device
// 5. iOS shows it / wakes the app
//
//   App ──token──▶ Backend ──payload + token──▶ APNs ──▶ Device
//


//==============================================================
// MARK: - 02. Payload Structure
//==============================================================
//
// JSON with an "aps" dictionary (Apple's keys) + your own custom keys.
// Max size: 4 KB.
//

struct PushPayload: Decodable {
    let aps: APS
    let productID: Int?                          // custom key — outside "aps"
}

struct APS: Decodable {
    let alert: Alert?
    let badge: Int?
    let sound: String?
    let contentAvailable: Int?

    enum CodingKeys: String, CodingKey {
        case alert, badge, sound
        case contentAvailable = "content-available"
    }
}

struct Alert: Decodable {
    let title: String
    let body: String
}

print("\n========== 02 - Payload Structure ==========")

let alertJSON = Data("""
{
  "aps": {
    "alert": { "title": "Price Drop", "body": "Running shoes now 20% off" },
    "badge": 1,
    "sound": "default"
  },
  "productID": 42
}
""".utf8)

do {
    let payload = try JSONDecoder().decode(PushPayload.self, from: alertJSON)
    if let alert = payload.aps.alert {
        print("Title:", alert.title)             // Price Drop
        print("Body:", alert.body)               // Running shoes now 20% off
    }
    if let badge = payload.aps.badge {
        print("Badge:", badge)                   // 1
    }
    if let productID = payload.productID {
        print("Product:", productID)             // 42
    }
} catch {
    print("Decode failed:", error)
}


//==============================================================
// MARK: - 03. Alert Push vs Silent Push
//==============================================================
//
// Silent push = "content-available": 1, no alert, no sound.
// Wakes the app in the background to fetch data — user sees nothing.
//

print("\n========== 03 - Alert vs Silent Push ==========")

let silentJSON = Data("""
{
  "aps": { "content-available": 1 },
  "productID": 42
}
""".utf8)

do {
    let payload = try JSONDecoder().decode(PushPayload.self, from: silentJSON)
    if payload.aps.alert == nil, payload.aps.contentAvailable == 1 {
        print("Silent push → refresh product in background")
    }
} catch {
    print("Decode failed:", error)
}

// ┌─────────────────┬─────────────────────────┬──────────────────────────────┐
// │                 │ Alert push              │ Silent push                  │
// ├─────────────────┼─────────────────────────┼──────────────────────────────┤
// │ User sees       │ Banner, sound, badge    │ Nothing                      │
// │ Key             │ "alert"                 │ "content-available": 1       │
// │ Needs permission│ Yes                     │ No (Background Modes only)   │
// │ Delivery        │ Reliable                │ Throttled, not guaranteed    │
// │ App runs        │ Only if user taps       │ ~30 s in background          │
// └─────────────────┴─────────────────────────┴──────────────────────────────┘
//
// Silent pushes don't wake an app the user force-quit.
//


//==============================================================
// MARK: - 04. Key Facts
//==============================================================
//
// 1. Payload limit: 4 KB.
// 2. Auth: token-based (.p8 key, never expires, all apps) — preferred
//    over certificate-based (.p12, expires yearly, one app).
// 3. Environments: sandbox (debug builds) vs production (TestFlight / App Store).
//    A sandbox token sent to production → "BadDeviceToken".
// 4. Priority 10 = immediate, 5 = power-friendly (required for silent push).
// 5. apns-collapse-id → newer push replaces older one (e.g. live score).
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is APNs?
//    → Apple's service that delivers push notifications from your server to devices.
//
// 2. Walk through the push flow.
//    → App gets a token, sends it to the backend, backend sends payload + token to APNs, APNs delivers.
//
// 3. What is in a push payload?
//    → An "aps" dictionary (alert, badge, sound, content-available) plus custom keys. Max 4 KB.
//
// 4. Alert vs silent push?
//    → Alert shows UI; silent has content-available: 1 and wakes the app to fetch data.
//
// 5. Is a silent push guaranteed to arrive?
//    → No. The system throttles it and skips force-quit apps.
//
// 6. .p8 key vs .p12 certificate?
//    → .p8 never expires and works for all apps; .p12 expires yearly and is per app.
//
// 7. Why would a token fail with BadDeviceToken?
//    → Sandbox token sent to the production APNs endpoint, or vice versa.
//
//==============================================================
