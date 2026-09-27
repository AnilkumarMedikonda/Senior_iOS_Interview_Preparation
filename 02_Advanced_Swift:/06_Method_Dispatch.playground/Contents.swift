import Foundation

//==============================================================
// MARK: - Method Dispatch
//==============================================================
// How Swift decides which implementation runs.
// Static → compile time | Table / Witness → runtime lookup | Message → ObjC runtime

//==============================================================
// MARK: - 01. Static Dispatch
//==============================================================
// Structs, enums, final, private → address known at compile time → can inline.

struct Car {
    func start() { print("Car") }
}

final class FinalCar {
    func start() { print("FinalCar") }
}

print("\n========== 01 - Static Dispatch ==========")
Car().start()      // Car
FinalCar().start() // FinalCar

//==============================================================
// MARK: - 02. Table Dispatch (vtable)
//==============================================================
// Overridable class methods → looked up at runtime.

class Vehicle {
    func start() { print("Vehicle") }
}

class Bike: Vehicle {
    override func start() { print("Bike") }
}

print("\n========== 02 - Table Dispatch ==========")
let vehicle: Vehicle = Bike()
vehicle.start() // Bike

//==============================================================
// MARK: - 03. Class Extension Methods Are Static
//==============================================================
// Methods declared in a class extension can't be overridden (unless @objc).

extension Vehicle {
    func stop() { print("Vehicle Stop") }
}

class Scooter: Vehicle {
    // override func stop() { }   ❌ Non-@objc extension methods cannot be overridden
}

print("\n========== 03 - Class Extension Methods Are Static ==========")
Scooter().stop() // Vehicle Stop

//==============================================================
// MARK: - 04. Witness Table
//==============================================================
// Protocol requirement → each conforming type maps it to its own implementation.
// Bus.witness: move → Bus.move() | Train.witness: move → Train.move()

protocol Transport {
    func move()
}

extension Transport {
    func move() { print("Default Transport") }
}

struct Bus: Transport {
    func move() { print("Bus") }
}

struct Train: Transport {}

print("\n========== 04 - Witness Table ==========")
let transports: [any Transport] = [Bus(), Train()]
for transport in transports {
    transport.move() // Bus | Default Transport
}

//==============================================================
// MARK: - 05. Extension-Only Method Trap
//==============================================================
// Not a requirement → no witness entry → static dispatch on the declared type.

protocol Device {}

extension Device {
    func connect() { print("Default Device") }
}

struct Phone: Device {
    func connect() { print("Phone") }
}

print("\n========== 05 - Extension-Only Method Trap ==========")
let phone = Phone()
phone.connect()          // Phone
let device: any Device = phone
device.connect()         // Default Device

//==============================================================
// MARK: - 06. Class + Protocol Witness Trap
//==============================================================
// Employee adopts Worker using the default → that becomes the witness.
// Developer's work() is a new method, not an override → witness unchanged.

protocol Worker {
    func work()
}

extension Worker {
    func work() { print("Protocol") }
}

class Employee: Worker {}

class Developer: Employee {
    func work() { print("Developer") }
}

// Fix: implement in the base class, override in the subclass.
class FixedEmployee: Worker {
    func work() { print("Employee") }
}

class FixedDeveloper: FixedEmployee {
    override func work() { print("Developer") }
}

print("\n========== 06 - Class + Protocol Witness Trap ==========")
let worker: any Worker = Developer()
worker.work()        // Protocol
let fixedWorker: any Worker = FixedDeveloper()
fixedWorker.work()   // Developer

//==============================================================
// MARK: - 07. Message Dispatch
//==============================================================
// @objc         → visible to Objective-C, Swift callers still use the vtable.
// @objc dynamic → always objc_msgSend → required for KVO and swizzling.

final class Player: NSObject {
    @objc dynamic var progress = 0.0
}

print("\n========== 07 - Message Dispatch ==========")
let player = Player()
let observation = player.observe(\.progress, options: [.new]) { _, change in
    print("KVO:", change.newValue as Any) // KVO: Optional(0.5)
}
player.progress = 0.5
observation.invalidate()

//==============================================================
// MARK: - 08. Summary
//==============================================================
//
// ┌────────────┬──────────────────────────────────┬──────────┐
// │ Dispatch   │ Used for                         │ Speed    │
// ├────────────┼──────────────────────────────────┼──────────┤
// │ Static     │ struct, enum, final, private,    │ Fastest  │
// │            │ extension methods                │ inlined  │
// │ Table      │ overridable class methods        │ Fast     │
// │ Witness    │ protocol requirements            │ Fast     │
// │ Message    │ @objc dynamic                    │ Slowest  │
// └────────────┴──────────────────────────────────┴──────────┘
//
// final / private / whole-module optimization → turn table calls into static.
//
//==============================================================

//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What dispatch types does Swift have?
// 2. Why does an extension-only protocol method ignore the conforming type?
// 3. Why does the protocol call print "Protocol" in the class witness trap? How do you fix it?
// 4. Can you override a method declared in a class extension?
// 5. @objc vs @objc dynamic — why does KVO need dynamic?
// 6. How do final and private improve performance?
//
//==============================================================
