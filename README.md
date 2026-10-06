# 📱 Senior iOS Interview Preparation

Structured preparation for **Senior iOS Engineer** interviews — covering Swift internals, iOS frameworks, architecture, concurrency, networking, performance, and real-world engineering problems.

Built alongside a full-time job, in public.

> **Goal:** Not just to read concepts, but to implement them, explain them clearly, and defend the trade-offs under interview questioning.

📅 **Started:** September 26, 2026

---

## 📏 House Rules

* **Every topic ends with working code.** If a session ends with only notes, the session isn't complete.
* **Explain it aloud.** Swift and system-design rounds are verbal. Understanding the concept is not enough — I should be able to explain it clearly.
* **One Swift file per topic.** Short sections: concept → code → inline output. Compile-time traps marked ❌. Only interview-level concepts, no long notes.
* **Write the interview answer down.** Relevant questions are added to `17_Interview_Questions/` on the same day.
* **Name the trade-off.** Every topic should explain when and why I would *not* use the approach.

---

## 🌿 Branches

`main` · `feature/swift` · `feature/ios` · `feature/interview` — feature branches merge into `main` when a folder is done.

---

## 🎯 Core Focus Areas

The preparation emphasizes the areas that require strong senior-level understanding:

1. **Memory & ARC** — retain cycles, capture lists, weak/unowned references, memory leaks
2. **Swift Concurrency** — GCD, async/await, tasks, actors, race conditions, `@MainActor`, `Sendable`
3. **Networking** — URLSession, error handling, authentication, token refresh, cancellation
4. **Swift & Advanced Swift** — protocols, generics, closures, property wrappers, dispatch
5. **UIKit & SwiftUI** — lifecycle, state management, navigation, performance, interoperability
6. **Architecture & Patterns** — MVVM, Coordinator, VIPER, Clean Architecture, Modular, TCA, DI, Repository
7. **Performance & Debugging** — Instruments, memory, scrolling, main-thread performance, crashes

---

## 📊 Progress

| #  | Area                    | Topics | Done | Status |
| -- | ----------------------- | -----: | ---: | :----: |
| 01 | Swift Fundamentals      |      9 |    9 |   ✅   |
| 02 | Advanced Swift          |      6 |    6 |   ✅   |
| 03 | Memory & ARC            |     10 |   10 |   ✅   |
| 04 | Swift Concurrency       |     15 |   15 |   ✅   |
| 05 | iOS Fundamentals        |      8 |    8 |   ✅   |
| 06 | Push Notifications      |      6 |    6 |   ✅   |
| 07 | UIKit                   |     11 |   11 |   ✅   |
| 08 | SwiftUI                 |     11 |   11 |   ✅   |
| 09 | Combine                 |      4 |    4 |   ✅   |
| 10 | Networking              |      8 |    8 |   ✅   |
| 11 | Persistence             |      6 |    6 |   ✅   |
| 12 | Architecture            |      5 |    5 |   ✅   |
| 13 | Design Patterns         |      9 |    9 |   ✅   |
| 14 | SOLID Principles        |      5 |    5 |   ✅   |
| 15 | Performance & Debugging |      3 |    3 |   ✅   |
| 16 | Unit Testing            |      5 |    5 |   ✅   |
| 17 | Interview Questions     |      8 |    8 |   ✅   |
| 18 | Output Questions        |      8 |    8 |   ✅   |

**129 / 129 topics** ✅ · 154 interview questions · 95 output questions · ⬜ Not started · 🟡 In progress · ✅ Done

---

## 📂 Repository Structure

```text
Senior_iOS_Interview_Preparation/
│
├── README.md
│
├── 01_Swift_Fundamentals/
│   ├── 01_Swift_Basics
│   ├── 02_Value_vs_Reference_Types
│   ├── 03_Enums
│   ├── 04_Optionals
│   ├── 05_Properties
│   ├── 06_Closures
│   ├── 07_Higher_Order_Functions
│   ├── 08_Initialization
│   └── 09_Access_Control
│
├── 02_Advanced_Swift/
│   ├── 01_Protocols_And_POP
│   ├── 02_Any_vs_Some
│   ├── 03_Generics
│   ├── 04_Property_Wrappers
│   ├── 05_Error_Handling
│   └── 06_Method_Dispatch
│
├── 03_Memory_ARC/
│   ├── 01_ARC_Basics
│   ├── 02_Strong_References
│   ├── 03_Weak_References
│   ├── 04_Unowned_References
│   ├── 05_Retain_Cycles
│   ├── 06_Closure_Retain_Cycles
│   ├── 07_Capture_Lists
│   ├── 08_Weak_Self
│   ├── 09_Deinit
│   └── 10_Escaping_vs_NonEscaping
│
├── 04_Swift_Concurrency/
│   ├── 01_Concurrency_Basics
│   ├── 02_GCD
│   ├── 03_Serial_vs_Concurrent
│   ├── 04_Sync_vs_Async
│   ├── 05_Deadlock
│   ├── 06_Race_Condition
│   ├── 07_Thread_Safety
│   ├── 08_Async_Await
│   ├── 09_Task
│   ├── 10_TaskGroup
│   ├── 11_Actors
│   ├── 12_MainActor
│   ├── 13_Task_Cancellation
│   ├── 14_Sendable
│   ├── 15_Continuations
│   └── 16_Concurrency_Output_Questions
│
├── 05_iOS_Fundamentals/
│   ├── 01_App_Lifecycle
│   ├── 02_AppDelegate_SceneDelegate
│   ├── 03_ViewController_Lifecycle
│   ├── 04_Delegation
│   ├── 05_NotificationCenter
│   ├── 06_Deep_Linking
│   ├── 07_Universal_Links
│   └── 08_Background_Tasks
│
├── 06_Push_Notifications/
│   ├── 01_APNs_Basics
│   ├── 02_Permission_And_Registration
│   ├── 03_Device_Token
│   ├── 04_Foreground_Background_Tap_Handling
│   ├── 05_Deep_Link_From_Notification
│   ├── 06_Push_Notification_Debugging
│   └── 07_Push_Notification_Flow
│
├── 07_UIKit/
│   ├── 01_UIView_UIViewController
│   ├── 02_Auto_Layout
│   ├── 03_Content_Hugging_Compression
│   ├── 04_UITableView
│   ├── 05_Cell_Reuse
│   ├── 06_UICollectionView
│   ├── 07_Dynamic_Cell_Height
│   ├── 08_Pagination
│   ├── 09_UI_Performance
│   ├── 10_Frame_vs_Bounds
│   └── 11_Layout_Cycle
│
├── 08_SwiftUI/
│   ├── 01_SwiftUI_Basics
│   ├── 02_State
│   ├── 03_Binding
│   ├── 04_StateObject
│   ├── 05_ObservedObject
│   ├── 06_Environment
│   ├── 07_Observation_Framework
│   ├── 08_View_Identity
│   ├── 09_NavigationStack
│   ├── 10_SwiftUI_Performance
│   └── 11_UIKit_SwiftUI_Interop
│
├── 09_Combine/
│   ├── 01_Combine_Basics
│   ├── 02_Publishers_And_Subscribers
│   ├── 03_Operators
│   └── 04_Combine_vs_AsyncAwait
│
├── 10_Networking/
│   ├── 01_URLSession
│   ├── 02_Codable
│   ├── 03_API_Client
│   ├── 04_Network_Error_Handling
│   ├── 05_Authentication_And_Token_Refresh
│   ├── 06_Request_Cancellation
│   ├── 07_AsyncAwait_Networking
│   └── 08_SSL_Pinning
│
├── 11_Persistence/
│   ├── 01_UserDefaults
│   ├── 02_Keychain
│   ├── 03_CoreData
│   ├── 04_Memory_Cache
│   ├── 05_Disk_Cache
│   └── 06_Offline_Storage
│
├── ├── 12_Architecture/
│   ├── 01_MVC
│   ├── 02_MVVM
│   ├── 03_Coordinator
│   ├── 04_VIPER
│   ├── 05_Clean_Architecture
│   ├── 06_MVVM_Clean
│   ├── 07_Modular_Architecture
│   └── 08_TCA_Modern_SwiftUI
│
├── 13_Design_Patterns/
│   ├── 01_Singleton
│   ├── 02_Factory
│   ├── 03_Observer
│   ├── 04_Adapter
│   ├── 05_Dependency_Injection
│   ├── 06_Repository
│   ├── 07_Delegate
│   ├── 08_NotificationCenter
│   └── 09_Coordinator
│
├── 14_SOLID_Principles/
│   ├── 01_SRP_Single_Responsibility
│   ├── 02_OCP_Open_Closed
│   ├── 03_LSP_Liskov_Substitution
│   ├── 04_ISP_Interface_Segregation
│   └── 05_DIP_Dependency_Inversion
│
├── 15_Performance_Debugging/
│   ├── 01_Instruments_Overview
│   ├── 02_Memory_Leaks_And_Hangs
│   └── 03_Crash_Debugging
│
├── 16_Unit_Testing/
│   ├── 01_XCTest_Basics
│   ├── 02_Testing_ViewModel
│   ├── 03_Mocking
│   ├── 04_Testing_Async_Code
│   └── 05_Testable_Architecture
│
├── 17_Interview_Questions/
│   ├── 01_Swift_Questions
│   ├── 02_iOS_Questions
│   ├── 03_SwiftUI_Questions
│   ├── 04_Concurrency_Questions
│   ├── 05_Networking_Questions
│   ├── 06_Architecture_Questions
│   ├── 07_Performance_Questions
│   └── 08_Senior_Level_Questions
│
└── 18_Output_Questions/
    ├── 01_Closures.swift
    ├── 02_Defer.swift
    ├── 03_HOF.swift
    ├── 04_Protocols.swift
    ├── 05_Any_Some.swift
    ├── 06_Extensions.swift
    ├── 07_ARC.swift
    └── 08_Concurrency.swift
```

Each topic folder contains:

* `<Topic>.swift` — runnable examples with inline output, interview-level notes, and an Interview Questions list with one-line answers
* `<Topic>_Notes.txt` — plain-text concept notes for quick revision (Design Patterns, SOLID, Performance, Unit Testing, and selected Networking topics)
* XCTest playgrounds (`16_Unit_Testing`) run real tests with `defaultTestSuite.run()`

Each `17_Interview_Questions` folder contains:

* `<Topic>_Questions.txt` — question → short spoken answer → usual follow-up
* `<Topic>Questions.swift` — the same questions with tiny runnable code proofs (`DEBUG Q##`)

`18_Output_Questions` contains:

* One predict-the-output playground per topic — 95 questions across closures, defer, higher-order functions, protocols, Any/some, extensions, ARC, and concurrency
* Each question prints a `Q##` header and ends with a `// ▶️ Run` block — comment it out, predict, then run

---

## 🏗️ Companion Repository

System design is maintained separately as a dedicated repository containing architecture notes, design decisions, diagrams, SwiftUI demo apps, and real-world mobile system-design problems.

**[Senior_iOS_System_Design](https://github.com/AnilkumarMedikonda/Senior_iOS_System_Design)**

Key topics include:

* Networking Layer
* Image Loading & Caching
* Offline-First & Sync
* Pagination & Search
* Deep Linking
* Authentication
* E-Commerce App
* Chat App

---

## 🚀 Related Repositories

| Repository | Description |
| ---------- | ----------- |
| **[Top_DSA_Interview_Questions](https://github.com/AnilkumarMedikonda/Top_DSA_Interview_Questions)** | 85 curated DSA interview questions in Swift, 9 pattern phases |
| **[DSA-Logic-and-Interview-Prep](https://github.com/AnilkumarMedikonda/DSA-Logic-and-Interview-Prep)** | DSA problems, patterns, and interview preparation |
| **[iOS-Architecture-Patterns](https://github.com/AnilkumarMedikonda/iOS-Architecture-Patterns)** | Swift, UIKit, and SwiftUI architecture patterns |

---

## 👨‍💻 Author

**Medikonda Anil Kumar**

Senior iOS Engineer

* **GitHub:** [AnilkumarMedikonda](https://github.com/AnilkumarMedikonda)
* **LinkedIn:** [Anil Kumar](https://www.linkedin.com/in/anil-kumar-118524283/)
* **Email:** [anil.medikonda.ios@gmail.com](mailto:anil.medikonda.ios@gmail.com)

---

## 📄 License

MIT License.

All notes and implementations are written for educational and interview-preparation purposes.
