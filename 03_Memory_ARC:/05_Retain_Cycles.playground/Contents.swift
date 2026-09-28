import Foundation

//==============================================================
// MARK: - Retain Cycles
//==============================================================
//
// Retain cycle = objects hold each other strongly.
// Their counts never reach 0 → deinit never runs → memory leak.
// Fix: make ONE side weak or unowned (usually the back-reference).
// Closure cycles → 06_Closure_Retain_Cycles
//


//==============================================================
// MARK: - 01. Parent ↔ Child Cycle
//==============================================================

final class Folder {

    var files: [File] = []

    deinit {
        print("Folder deinit")
    }
}

final class File {

    var folder: Folder?              // ❌ strong back-reference

    deinit {
        print("File deinit")
    }
}

print("\n========== 01 - Parent ↔ Child Cycle ==========")

var folder: Folder? = Folder()

var file: File? = File()

folder?.files.append(file!)

file?.folder = folder

folder = nil

file = nil

// No deinit printed — leaked


//==============================================================
// MARK: - 02. Fix with weak
//==============================================================
//
// Parent owns child (strong). Child points back (weak).
//

final class SafeFolder {

    var files: [SafeFile] = []

    deinit {
        print("SafeFolder deinit")
    }
}

final class SafeFile {

    weak var folder: SafeFolder?     // ✅ weak back-reference

    deinit {
        print("SafeFile deinit")
    }
}

print("\n========== 02 - Fix with weak ==========")

var safeFolder: SafeFolder? = SafeFolder()

var safeFile: SafeFile? = SafeFile()

safeFolder?.files.append(safeFile!)

safeFile?.folder = safeFolder

safeFolder = nil                     // SafeFolder deinit

safeFile = nil                       // SafeFile deinit


//==============================================================
// MARK: - 03. Strong Delegate Cycle
//==============================================================
//
// Screen owns Service. Service holds Screen as a STRONG delegate → cycle.
// Fix: weak var delegate + AnyObject protocol.
//

protocol ServiceDelegate: AnyObject {

    func didLoad()
}

final class Service {

    var delegate: ServiceDelegate?   // ❌ should be weak

    deinit {
        print("Service deinit")
    }
}

final class Screen: ServiceDelegate {

    let service = Service()

    init() {
        service.delegate = self
    }

    func didLoad() {}

    deinit {
        print("Screen deinit")
    }
}

print("\n========== 03 - Strong Delegate Cycle ==========")

var screen: Screen? = Screen()

screen = nil

// No deinit printed — leaked. Fix: weak var delegate


//==============================================================
// MARK: - 04. Indirect Cycle (A → B → C → A)
//==============================================================
//
// Cycles can span 3+ objects — harder to spot in code reviews.
//

final class NodeA {

    var next: NodeB?

    deinit {
        print("NodeA deinit")
    }
}

final class NodeB {

    var next: NodeC?

    deinit {
        print("NodeB deinit")
    }
}

final class NodeC {

    var next: NodeA?                 // ❌ closes the loop

    deinit {
        print("NodeC deinit")
    }
}

print("\n========== 04 - Indirect Cycle ==========")

var nodeA: NodeA? = NodeA()

nodeA?.next = NodeB()

nodeA?.next?.next = NodeC()

nodeA?.next?.next?.next = nodeA

nodeA = nil

// No deinit printed — all three leaked


//==============================================================
// MARK: - 05. How to Find Leaks
//==============================================================
//
// 1. deinit prints — quick check that screens are freed after dismiss.
//
// 2. Xcode Memory Graph Debugger — shows objects still alive
//    and the reference path keeping them there.
//
// 3. Instruments → Leaks — flags leaked memory while the app runs.
//
// Common sources: strong delegates, parent ↔ child back-references,
// closures capturing self, timers, NotificationCenter block observers.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a retain cycle?
//    → Objects hold each other strongly, so counts never reach 0 and they leak.
//
// 2. How do you break a retain cycle?
//    → Make one side weak or unowned — usually the back-reference.
//
// 3. Why does a strong delegate cause a leak?
//    → The owner holds the child, and the child holds the owner back strongly.
//
// 4. Which side should be weak in a parent–child relationship?
//    → The child's reference to the parent.
//
// 5. How do you find retain cycles in a real app?
//    → deinit prints, Memory Graph Debugger, Instruments Leaks.
//
// 6. What are common causes of retain cycles in iOS?
//    → Strong delegates, back-references, closures capturing self, timers.
//
//==============================================================
