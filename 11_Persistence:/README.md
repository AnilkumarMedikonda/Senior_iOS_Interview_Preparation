# 11_Persistence

Storing data on the device — small settings, secrets, structured data, caches, and offline support. Senior interviews focus on picking the right storage for each kind of data and keeping it consistent with the server.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_UserDefaults` | Small settings, what NOT to store, `@AppStorage`, suites | ⬜ |
| 02 | `02_Keychain` | Tokens and secrets, `SecItem` APIs, accessibility levels | ⬜ |
| 03 | `03_CoreData` | Model, context, fetch requests, background contexts, SwiftData | ⬜ |
| 04 | `04_Memory_Cache` | `NSCache`, eviction, cost limits, image caching | ⬜ |
| 05 | `05_Disk_Cache` | FileManager, caches vs documents, expiry, `URLCache` | ⬜ |
| 06 | `06_Offline_Storage` | Offline-first, local source of truth, sync, conflict handling | ⬜ |

**0 / 6 topics**

## Which Storage for What

| Data | Storage |
|------|---------|
| Settings, flags | UserDefaults |
| Tokens, passwords | Keychain |
| Large structured data | Core Data / SwiftData |
| Fast temporary objects | NSCache (memory) |
| Downloaded files, images | Disk cache (Caches folder) |

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [ ] 01_UserDefaults
- [ ] 02_Keychain
- [ ] 03_CoreData
- [ ] 04_Memory_Cache
- [ ] 05_Disk_Cache
- [ ] 06_Offline_Storage
