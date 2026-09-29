# 11_Persistence

Storing data on the device — small settings, secrets, structured data, in-memory and disk caches, and offline-first sync. Senior interviews ask "where would you store X, and why?" and how the app behaves with no network.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_UserDefaults` | Settings, missing-key trap, `Codable` values, typed wrapper, what NOT to store | ✅ |
| 02 | `02_Keychain` | `SecItem` store, accessibility levels, reinstall cleanup, biometrics | ✅ |
| 03 | `03_CoreData` | Stack, fetch / update / delete, background import, `NSManagedObjectID`, SwiftData | ✅ |
| 04 | `04_Memory_Cache` | `NSCache` count & cost limits, generic TTL cache, cache-aside | ✅ |
| 05 | `05_Disk_Cache` | Caches vs Documents, hashed file names, expiry, size trimming, two-level cache | ✅ |
| 06 | `06_Offline_Storage` | Local-first reads, outbox sync queue, idempotency, conflict resolution | ✅ |

**6 / 6 topics** ✅

## Where to Store What

| Data | Store |
|------|-------|
| Settings, flags, small values | UserDefaults |
| Tokens, passwords, secrets | Keychain |
| Structured / queryable app data | Core Data / SwiftData |
| Images and responses for this session | NSCache (memory) |
| Re-downloadable files | Caches directory (disk) |
| User-created files | Documents directory |

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [x] 01_UserDefaults
- [x] 02_Keychain
- [x] 03_CoreData
- [x] 04_Memory_Cache
- [x] 05_Disk_Cache
- [x] 06_Offline_Storage
