# 10_Networking

Talking to servers — URLSession, Codable, a reusable API client, error handling, auth with token refresh, cancellation, async/await networking, and SSL pinning. Senior interviews usually ask you to design the networking layer and defend its trade-offs.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_URLSession` | `URLRequest`, data / download / upload tasks, configuration, caching | ⬜ |
| 02 | `02_Codable` | `Decodable` / `Encodable`, `CodingKeys`, key strategies, dates, custom decoding | ⬜ |
| 03 | `03_API_Client` | Endpoint enum, generic `request<T: Decodable>`, protocol for mocking | ⬜ |
| 04 | `04_Network_Error_Handling` | Typed `NetworkError`, HTTP status mapping, retry with backoff | ⬜ |
| 05 | `05_Authentication_And_Token_Refresh` | Bearer tokens, 401 handling, single in-flight refresh, request replay | ⬜ |
| 06 | `06_Request_Cancellation` | `Task.cancel`, cancelling on screen exit, stale search requests | ⬜ |
| 07 | `07_AsyncAwait_Networking` | `data(for:)`, parallel requests, `async let`, `TaskGroup` | ⬜ |
| 08 | `08_SSL_Pinning` | Certificate vs public key pinning, `URLSessionDelegate`, rotation risks | ⬜ |

**0 / 8 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Interview-level concepts only

## Status

- [ ] 01_URLSession
- [ ] 02_Codable
- [ ] 03_API_Client
- [ ] 04_Network_Error_Handling
- [ ] 05_Authentication_And_Token_Refresh
- [ ] 06_Request_Cancellation
- [ ] 07_AsyncAwait_Networking
- [ ] 08_SSL_Pinning
