# 16_Unit_Testing

Writing fast, reliable unit tests for iOS code — XCTest basics, testing ViewModels, mocks and fakes, async code, and designing code so it can be tested. Senior interviews ask "how would you test this?" for almost every design answer.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_XCTest_Basics` | `XCTestCase`, `setUp` / `tearDown`, assertions, Arrange-Act-Assert, Swift Testing (`@Test`, `#expect`) | ⬜ |
| 02 | `02_Testing_ViewModel` | Loading / success / error states, injected dependencies, no UIKit | ⬜ |
| 03 | `03_Mocking` | Mock vs stub vs fake vs spy, protocol-based mocks, verifying calls | ⬜ |
| 04 | `04_Testing_Async_Code` | `async` tests, `XCTestExpectation`, Combine publishers, `@MainActor` tests | ⬜ |
| 05 | `05_Testable_Architecture` | DI, protocols, pure functions, controlling time / randomness, what not to unit test | ⬜ |

**0 / 5 topics**

Each folder: `Topic.swift` (playground that **runs real XCTest tests** via `defaultTestSuite.run()`) + `Topic_Notes.txt`.

## Test Doubles at a Glance

| Double | What it does | Example |
|--------|--------------|---------|
| Stub | Returns fixed data | API that always returns 2 products |
| Mock | Records calls so you can verify them | Analytics mock storing tracked events |
| Fake | Simple working implementation | In-memory repository instead of Core Data |
| Spy | Real behaviour + records calls | Wrapper that logs calls to a real service |

## Good Unit Test Rules (F.I.R.S.T.)

| | |
|---|---|
| **F**ast | Milliseconds — no network, disk, or sleeps |
| **I**ndependent | No shared state between tests |
| **R**epeatable | Same result every run, on every machine |
| **S**elf-validating | Pass / fail with assertions, no reading logs |
| **T**imely | Written with (or before) the code |

## Status

- [ ] 01_XCTest_Basics
- [ ] 02_Testing_ViewModel
- [ ] 03_Mocking
- [ ] 04_Testing_Async_Code
- [ ] 05_Testable_Architecture
