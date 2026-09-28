# 06_Push_Notifications

How push notifications reach an iOS app — APNs, permission, device tokens, handling in every app state, and routing from a tap to the right screen. Common in senior interviews, often as "walk me through what happens when a push arrives."

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_APNs_Basics` | Push flow, payload decoding, alert vs silent push, `.p8` vs `.p12` | ✅ |
| 02 | `02_Permission_And_Registration` | `requestAuthorization`, provisional, status check, Settings fallback | ✅ |
| 03 | `03_Device_Token` | Data → hex, backend registration, token changes, 410 Unregistered | ✅ |
| 04 | `04_Foreground_Background_Tap_Handling` | `willPresent`, `didReceive`, action buttons, silent push | ✅ |
| 05 | `05_Deep_Link_From_Notification` | Payload → Route, cold start pending route, shared router | ✅ |
| 06 | `06_Push_Notification_Debugging` | Simulator `.apns`, APNs errors, "not arriving" checklist | ✅ |

**6 / 6 topics** ✅

## Flow Chart

| # | File | Contents |
|---|------|----------|
| 07 | `07_Push_Notification_Flow` | Registration sequence, delivery decision tree, 6 runnable scenarios |

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [x] 01_APNs_Basics
- [x] 02_Permission_And_Registration
- [x] 03_Device_Token
- [x] 04_Foreground_Background_Tap_Handling
- [x] 05_Deep_Link_From_Notification
- [x] 06_Push_Notification_Debugging
- [x] 07_Push_Notification_Flow
