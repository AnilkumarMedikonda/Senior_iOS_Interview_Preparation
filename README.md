# 📱 Senior iOS Interview Preparation

Structured preparation for **Senior iOS Engineer** interviews — covering Swift internals, iOS frameworks, architecture, concurrency, networking, performance, and real-world engineering problems.

Built alongside a full-time job, in public.

> **Goal:** Not just to read concepts, but to implement them, explain them clearly, and defend the trade-offs under interview questioning.

📅 **Started:** September 26, 2026

---

## 📏 House Rules

* **Every topic ends with working code.** If a session ends with only notes, the session isn't complete.
* **Explain it aloud.** Swift and system-design rounds are verbal. Understanding the concept is not enough — I should be able to explain it clearly.
* **One Playground per topic.** Examples are organized as focused blocks: concept → code → output → trade-off.
* **Write the interview answer down.** Relevant questions are added to `17_Interview_Questions/` on the same day.
* **Name the trade-off.** Every topic should explain when and why I would *not* use the approach.

---

## 🎯 Core Focus Areas

The preparation emphasizes the areas that require strong senior-level understanding:

1. **Memory & ARC** — retain cycles, capture lists, weak/unowned references, memory leaks
2. **Swift Concurrency** — GCD, async/await, tasks, actors, race conditions, `@MainActor`, `Sendable`
3. **Networking** — URLSession, error handling, authentication, token refresh, cancellation
4. **Swift & Advanced Swift** — protocols, generics, closures, property wrappers, dispatch
5. **UIKit & SwiftUI** — lifecycle, state management, navigation, performance, interoperability
6. **Architecture** — MVVM, Clean Architecture, Coordinator, Repository, Dependency Injection
7. **Performance & Debugging** — Instruments, memory, scrolling, main-thread performance, crashes

---

## 📊 Progress

| #  | Area                    | Topics | Status |
| -- | ----------------------- | -----: | :----: |
| 01 | Swift Fundamentals      |      8 |    ⬜   |
| 02 | Advanced Swift          |      6 |    ⬜   |
| 03 | Memory & ARC            |      9 |    ⬜   |
| 04 | Swift Concurrency       |     15 |    ⬜   |
| 05 | iOS Fundamentals        |      8 |    ⬜   |
| 06 | Push Notifications      |      6 |    ⬜   |
| 07 | UIKit                   |     11 |    ⬜   |
| 08 | SwiftUI                 |     11 |    ⬜   |
| 09 | Combine                 |      4 |    ⬜   |
| 10 | Networking              |      8 |    ⬜   |
| 11 | Persistence             |      6 |    ⬜   |
| 12 | Architecture            |      6 |    ⬜   |
| 13 | SOLID Principles        |      5 |    ⬜   |
| 14 | Performance & Debugging |      5 |    ⬜   |
| 15 | Coding Practice         |      4 |    ⬜   |
| 16 | Unit Testing            |      5 |    ⬜   |
| 17 | Interview Questions     |      8 |    ⬜   |
| 18 | Behavioural             |      4 |    ⬜   |
| 19 | Mock Interviews         |      4 |    ⬜   |

**0 / 133 topics**

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
│   └── 08_Initialization
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
│   └── 09_Deinit
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
│   └── 15_Continuations
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
│   └── 06_Push_Notification_Debugging
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
├── 12_Architecture/
│   ├── 01_MVC
│   ├── 02_MVVM
│   ├── 03_Clean_Architecture
│   ├── 04_Coordinator
│   ├── 05_Repository
│   └── 06_Dependency_Injection
│
├── 13_SOLID_Principles/
│   ├── 01_SRP_Single_Responsibility
│   ├── 02_OCP_Open_Closed
│   ├── 03_LSP_Liskov_Substitution
│   ├── 04_ISP_Interface_Segregation
│   └── 05_DIP_Dependency_Inversion
│
├── 14_Performance_Debugging/
│   ├── 01_Performance_Basics
│   ├── 02_Instruments
│   ├── 03_Memory_And_Leaks
│   ├── 04_Main_Thread_And_Scrolling_Performance
│   └── 05_Crash_Debugging
│
├── 15_Coding_Practice/
│   ├── 01_LRU_Cache
│   ├── 02_Debounce
│   ├── 03_API_Client
│   └── 04_Token_Refresh
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
├── 18_Behavioural/
│   ├── 01_Feature_Owned_End_To_End
│   ├── 02_Production_Bug
│   ├── 03_Technical_Disagreement
│   └── 04_Unfamiliar_Codebase
│
└── 19_Mock_Interviews/
    ├── 01_Swift_Mock
    ├── 02_Concurrency_Mock
    ├── 03_Architecture_Mock
    └── 04_Full_Senior_iOS_Mock
```

Each topic folder contains:

* `README.md` — concepts, explanations, interview notes, and trade-offs
* `.playground` — runnable Swift examples

---

## 🏗️ Companion Repository

System design is maintained separately as a dedicated repository containing architecture notes, design decisions, diagrams, and real-world mobile system-design problems.

**[iOS_System_Design](https://github.com/AnilkumarMedikonda/iOS_System_Design)**

Key topics include:

* Image Loading & Caching
* Offline-First Architecture
* Pagination
* Deep Linking
* Authentication
* Push Notifications
* Networking Architecture
* Data Synchronization

---

## 🚀 Related Repositories

| Repository                                                                                             | Description                                                  |
| ------------------------------------------------------------------------------------------------------ | ------------------------------------------------------------ |
| **[DSA-Logic-and-Interview-Prep](https://github.com/AnilkumarMedikonda/DSA-Logic-and-Interview-Prep)** | DSA problems, patterns, and interview preparation            |
| **[iOS-Architecture-Patterns](https://github.com/AnilkumarMedikonda/iOS-Architecture-Patterns)**       | Swift, UIKit, and SwiftUI architecture patterns              |
| **[iOS_System_Design](https://github.com/AnilkumarMedikonda/iOS_System_Design)**                       | iOS system design, architecture, scalability, and trade-offs |

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

