# 10_Networking

Talking to servers — URLSession, Codable, a reusable API client, error handling, auth with token refresh, cancellation, async/await networking, and SSL pinning. Senior interviews usually ask you to design the networking layer and defend its trade-offs.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_URLSession` | `URLRequest`, data / download / upload tasks, configuration, caching | ✅ |
| 02 | `02_Codable` | `Decodable` / `Encodable`, `CodingKeys`, key strategies, dates, custom decoding | ✅ |
| 03 | `03_API_Client` | Endpoint enum, generic `send<T: Decodable>`, protocol for mocking | ✅ |
| 04 | `04_Network_Error_Handling` | Typed `NetworkError`, HTTP status mapping, retry with backoff | ✅ |
| 05 | `05_Authentication_And_Token_Refresh` | Bearer tokens, 401 handling, single in-flight refresh, request replay | ✅ |
| 06 | `06_Request_Cancellation` | `Task.cancel`, cancelling on screen exit, stale search requests | ✅ |
| 07 | `07_AsyncAwait_Networking` | Sequential vs parallel, `async let`, `TaskGroup`, partial failure | ✅ |
| 08 | `08_SSL_Pinning` | Certificate vs public key pinning, `URLSessionDelegate`, rotation risks | ✅ |

**8 / 8 topics** ✅

## Concept Notes

| Topic | File |
|-------|------|
| 01 | `URLSession_Notes.swift` |
| 08 | `SSLPinning_Notes.swift` |

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [x] 01_URLSession
- [x] 02_Codable
- [x] 03_API_Client
- [x] 04_Network_Error_Handling
- [x] 05_Authentication_And_Token_Refresh
- [x] 06_Request_Cancellation
- [x] 07_AsyncAwait_Networking
- [x] 08_SSL_Pinning
