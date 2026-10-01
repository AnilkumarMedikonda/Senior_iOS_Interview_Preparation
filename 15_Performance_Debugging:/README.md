# 15_Performance_Debugging

High-level only — the tools and workflow to find slow screens, leaks, hangs, and crashes in a real app. Senior interviews ask "how would you investigate…?" and expect a calm, step-by-step answer, not a list of buzzwords.

**Branch:** `feature/ios`

## Topics

| # | Topic | Key Concepts | Status |
|---|-------|--------------|:------:|
| 01 | `01_Instruments_Overview` | Time Profiler, Allocations, Leaks, Animation Hitches, SwiftUI instrument — which tool for which problem | ✅ |
| 02 | `02_Memory_Leaks_And_Hangs` | Retain cycles, Memory Graph Debugger, main-thread hangs, watchdog | ✅ |
| 03 | `03_Crash_Debugging` | Crash logs, symbolication, common crash types, Xcode Organizer, Crashlytics | ✅ |

**3 / 3 topics** ✅

Each folder: `Topic.swift` (small runnable demo) + `Topic_Notes.txt` (tools + investigation steps).

## Which Tool for Which Problem?

| Symptom | Tool |
|---------|------|
| Slow screen / high CPU | Time Profiler |
| Janky scrolling | Animation Hitches, Time Profiler |
| Memory keeps growing | Allocations, Memory Graph Debugger |
| Object never deallocates | Leaks, Memory Graph, `deinit` log |
| UI freezes | Hangs instrument, main-thread check |
| Crash in production | Xcode Organizer, Crashlytics, symbolicated log |
| SwiftUI re-renders too much | SwiftUI instrument, `Self._printChanges()` |

## Investigation Flow

```
Reproduce → Measure (Instruments) → Find the real bottleneck → Fix → Measure again
```

> Never guess — measure first, on a real device, in a Release build.

## Status

- [x] 01_Instruments_Overview
- [x] 02_Memory_Leaks_And_Hangs
- [x] 03_Crash_Debugging
