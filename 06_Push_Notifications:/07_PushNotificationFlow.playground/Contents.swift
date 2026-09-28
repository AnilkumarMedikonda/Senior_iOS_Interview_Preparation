import Foundation

//==============================================================
// MARK: - Push Notification Flow
//==============================================================
//
// Full flow as a runnable simulation.
// Section 01 = getting the token. Section 02 = handling a push.
// Each scenario prints the exact path a real push takes.
//


//==============================================================
// MARK: - 01. Registration Flow
//==============================================================
//
//   App                 iOS                 APNs              Backend
//    │ requestAuthorization │                  │                   │
//    │────────────────────▶│                  │                   │
//    │◀──── granted ───────│                  │                   │
//    │ registerForRemote   │                  │                   │
//    │────────────────────▶│── register ─────▶│                   │
//    │                     │◀──── token ──────│                   │
//    │◀── didRegister(Data)│                  │                   │
//    │ Data → hex string   │                  │                   │
//    │──────────────────── POST /devices { token } ──────────────▶│
//

func simulateRegistration() {
    let steps = [
        "App      → requestAuthorization(.alert, .sound, .badge)",
        "iOS      → user taps Allow → granted",
        "App      → registerForRemoteNotifications()",
        "iOS      → registers with APNs",
        "APNs     → returns device token",
        "App      → didRegisterForRemoteNotificationsWithDeviceToken(Data)",
        "App      → Data → hex string",
        "App      → POST /devices { token, environment, userID }"
    ]
    for (index, step) in steps.enumerated() {
        print("\(index + 1). \(step)")
    }
}

print("\n========== 01 - Registration Flow ==========")

simulateRegistration()


//==============================================================
// MARK: - 02. Delivery & Handling Flow
//==============================================================
//
//              Backend ──payload + token──▶ APNs ──▶ Device
//                                                      │
//                                         ┌────────────┴────────────┐
//                                   Silent push?                 Alert push
//                                         │                         │
//                           didReceiveRemoteNotification      App state?
//                             fetch data, call handler     ┌────────┴─────────┐
//                                                    Foreground      Background / Killed
//                                                        │                  │
//                                                   willPresent      iOS shows banner
//                                                  ┌─────┴─────┐            │
//                                           [.banner]        []             │
//                                           shown       suppressed          │
//                                                  └─────┬──────────────────┘
//                                                   User taps?
//                                                        │ yes
//                                                   didReceive
//                                                        │
//                                          userInfo["deeplink"] → Route
//                                                        │
//                                                  App ready?
//                                             ┌──────────┴──────────┐
//                                            yes                    no
//                                         navigate         save pending route
//                                                            → navigate when ready
//

enum AppState {
    case foreground, background, killed
}

enum PushType {
    case alert, silent
}

func simulatePush(type: PushType, state: AppState, userTaps: Bool, suppressInForeground: Bool = false) {

    print("Backend  → sends payload + token to APNs")

    print("APNs     → delivers to device")

    if type == .silent {
        print("iOS      → didReceiveRemoteNotification(fetchCompletionHandler:)")
        print("App      → fetch data (~30 s), call completionHandler(.newData)")
        print("Result   → user sees nothing")
        return
    }

    switch state {
    case .foreground:
        print("iOS      → willPresent (app is open)")
        if suppressInForeground {
            print("App      → returns [] → no banner")
            print("Result   → suppressed")
            return
        }
        print("App      → returns [.banner, .sound] → banner shown")
    case .background:
        print("iOS      → shows banner (app in background)")
    case .killed:
        print("iOS      → shows banner (app not running)")
    }

    guard userTaps else {
        print("Result   → stays in Notification Center")
        return
    }

    if state == .killed {
        print("iOS      → launches app → didFinishLaunching sets delegate")
    }

    print("iOS      → didReceive(response)")

    print("App      → userInfo[\"deeplink\"] → Route.product(42)")

    if state == .killed {
        print("App      → UI not ready → save pending route")
        print("App      → root screen ready → navigate to ProductDetail(42)")
    } else {
        print("App      → navigate to ProductDetail(42)")
    }
}


//==============================================================
// MARK: - 03. Scenarios
//==============================================================

print("\n========== 03a - Foreground, Shown ==========")

simulatePush(type: .alert, state: .foreground, userTaps: true)

print("\n========== 03b - Foreground, Suppressed ==========")

simulatePush(type: .alert, state: .foreground, userTaps: false, suppressInForeground: true)

print("\n========== 03c - Background, User Taps ==========")

simulatePush(type: .alert, state: .background, userTaps: true)

print("\n========== 03d - Killed, User Taps (Cold Start) ==========")

simulatePush(type: .alert, state: .killed, userTaps: true)

print("\n========== 03e - Background, No Tap ==========")

simulatePush(type: .alert, state: .background, userTaps: false)

print("\n========== 03f - Silent Push ==========")

simulatePush(type: .silent, state: .background, userTaps: false)


//==============================================================
// MARK: - 04. Key Rules
//==============================================================
//
// Permission      → prompt shows ONCE — ask at a meaningful moment
// Token           → register every launch, upload only if changed
// Environment     → sandbox token ↔ sandbox APNs, production ↔ production
// Foreground      → no banner unless willPresent returns options
// Delegate        → set in didFinishLaunching or cold-start taps are lost
// Silent push     → throttled, not guaranteed, no wake after force-quit
// Cold start tap  → save pending route, navigate when ready
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Walk through the full push flow.
//    → App gets a token from APNs, sends it to the backend; backend sends payload + token
//      to APNs; APNs delivers; willPresent / didReceive handle it; deep link routes.
//
// 2. What changes when the app is killed and the user taps?
//    → The app launches first, then didReceive — navigation waits for a pending route.
//
// 3. What decides if a banner shows while the app is open?
//    → The options returned from willPresent.
//
// 4. How is a silent push handled differently?
//    → No UI — didReceiveRemoteNotification wakes the app to fetch data.
//
//==============================================================
