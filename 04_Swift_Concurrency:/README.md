# 04_Swift_Concurrency

GCD and modern Swift Concurrency — queues, threads, deadlocks, race conditions, async/await, tasks, actors, and Sendable. The highest-weight topic in senior iOS interviews.

**Branch:** `feature/swift`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_Concurrency_Basics` | Main thread rule, concurrency vs parallelism, GCD vs async/await | ✅ |
| 02 | `02_GCD` | main vs global, QoS, `asyncAfter`, `DispatchGroup`, `DispatchWorkItem` | ✅ |
| 03 | `03_Serial_vs_Concurrent` | Execution order, custom queues, serial queue for shared state | ✅ |
| 04 | `04_Sync_vs_Async` | Caller blocking, output order, sync return values | ✅ |
| 05 | `05_Deadlock` | `main.sync` on main, serial self-sync, lock deadlocks | ✅ |
| 06 | `06_Race_Condition` | Shared mutable state, lost updates | ⬜ |
| 07 | `07_Thread_Safety` | Serial queue, barrier, `NSLock` | ⬜ |
| 08 | `08_Async_Await` | `async` functions, `await`, suspension points | ⬜ |
| 09 | `09_Task` | `Task { }`, `Task.detached`, `async let` | ⬜ |
| 10 | `10_TaskGroup` | Dynamic parallel work, collecting results | ⬜ |
| 11 | `11_Actors` | Data isolation, `await` on actor calls, reentrancy | ⬜ |
| 12 | `12_MainActor` | UI updates, `@MainActor` class / func, `MainActor.run` | ⬜ |
| 13 | `13_Task_Cancellation` | `cancel()`, `Task.isCancelled`, `checkCancellation()` | ⬜ |
| 14 | `14_Sendable` | Safe cross-task values, `@Sendable` closures | ⬜ |
| 15 | `15_Continuations` | Bridging callbacks to async/await | ⬜ |

**5 / 15 topics**

## File Format

- One `.swift` file per topic — concept → code → inline output
- `print("\n========== NN - Title ==========")` per section
- ✅ allowed / ❌ compile error
- Interview Questions with one-line answers at the end
- Separate Coding Practice playground (execution order, deadlock, race questions)
- Interview-level concepts only

## Status

- [x] 01_Concurrency_Basics
- [x] 02_GCD
- [x] 03_Serial_vs_Concurrent
- [x] 04_Sync_vs_Async
- [x] 05_Deadlock
- [ ] 06_Race_Condition
- [ ] 07_Thread_Safety
- [ ] 08_Async_Await
- [ ] 09_Task
- [ ] 10_TaskGroup
- [ ] 11_Actors
- [ ] 12_MainActor
- [ ] 13_Task_Cancellation
- [ ] 14_Sendable
- [ ] 15_Continuations
