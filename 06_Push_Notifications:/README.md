# 06_Push_Notifications

How push notifications reach an iOS app — APNs, permission, device tokens, handling in every app state, and routing from a tap to the right screen. Common in senior interviews, often as "walk me through what happens when a push arrives."

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_APNs_Basics` | Server → APNs → device flow, payload structure, alert vs silent push | ⬜ |
| 02 | `02_Permission_And_Registration` | `requestAuthorization`, provisional, `registerForRemoteNotifications` | ⬜ |
| 03 | `03_Device_Token` | Token format, sending to backend, when it changes | ⬜ |
| 04 | `04_Foreground_Background_Tap_Handling` | `willPresent`, `didReceive`, app killed vs background | ⬜ |
| 05 | `05_Deep_Link_From_Notification` | Payload → Route, cold start tap, reuse deep link router | ⬜ |
| 06 | `06_Push_Notification_Debugging` | Simulator `.apns` files, sandbox vs production, common failures | ⬜ |

**0 / 6 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [ ] 01_APNs_Basics
- [ ] 02_Permission_And_Registration
- [ ] 03_Device_Token
- [ ] 04_Foreground_Background_Tap_Handling
- [ ] 05_Deep_Link_From_Notification
- [ ] 06_Push_Notification_Debugging
