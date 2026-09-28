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
| 06 | `06_Race_Condition` | Lost updates, check-then-act, collection crashes, Thread Sanitizer | ✅ |
| 07 | `07_Thread_Safety` | Serial queue, barrier, `NSLock`, atomic check-then-act | ✅ |
| 08 | `08_Async_Await` | `async throws`, sequential awaits, `Task` bridging, suspension points | ✅ |
| 09 | `09_Task` | `Task { }`, `Task.detached`, `async let`, structured vs unstructured | ✅ |
| 10 | `10_TaskGroup` | Dynamic parallel work, ordered results, throwing groups, concurrency limit | ✅ |
| 11 | `11_Actors` | Isolation, `nonisolated`, reentrancy bug + in-flight Task fix | ✅ |
| 12 | `12_MainActor` | `@MainActor` ViewModel, `MainActor.run`, heavy work off main | ✅ |
| 13 | `13_Task_Cancellation` | Cooperative cancel, `checkCancellation()`, search debounce | ✅ |
| 14 | `14_Sendable` | Value types, final classes, actors, `@unchecked`, Swift 6 errors | ✅ |
| 15 | `15_Continuations` | Checked / throwing continuations, resume once, delegate bridging | ✅ |

**15 / 15 topics** ✅

## Coding Practice

| # | File | Questions |
|---|------|-----------|
| 16 | `Concurrency_OutputQuestions` | Q01–Q20 — queue order, deadlock, group, barrier, semaphore, Task, actor, TaskGroup |

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
- [x] 06_Race_Condition
- [x] 07_Thread_Safety
- [x] 08_Async_Await
- [x] 09_Task
- [x] 10_TaskGroup
- [x] 11_Actors
- [x] 12_MainActor
- [x] 13_Task_Cancellation
- [x] 14_Sendable
- [x] 15_Continuations
- [x] 16_Concurrency_Output_Questions
