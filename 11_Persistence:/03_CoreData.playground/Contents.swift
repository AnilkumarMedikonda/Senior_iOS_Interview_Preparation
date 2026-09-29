import Foundation
import CoreData
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - Core Data
//==============================================================
//
// Apple's framework for storing and querying structured app data.
// Stack:
// Model (entities)  →  NSPersistentContainer  →  NSManagedObjectContext
//                                                (create, fetch, update, delete, save)
//
// Playground: model built in code + in-memory store → runs clean every time.
// In an app you use an .xcdatamodeld file and a SQLite store.
//


//==============================================================
// MARK: - 01. Stack Setup
//==============================================================

@objc(Product)
final class Product: NSManagedObject {
    @NSManaged var id: Int64
    @NSManaged var name: String
    @NSManaged var price: Double
}

func makeModel() -> NSManagedObjectModel {

    func attribute(_ name: String, _ type: NSAttributeType) -> NSAttributeDescription {
        let attribute = NSAttributeDescription()
        attribute.name = name
        attribute.attributeType = type
        attribute.isOptional = false
        return attribute
    }

    let entity = NSEntityDescription()
    entity.name = "Product"
    entity.managedObjectClassName = NSStringFromClass(Product.self)
    entity.properties = [
        attribute("id", .integer64AttributeType),
        attribute("name", .stringAttributeType),
        attribute("price", .doubleAttributeType)
    ]

    let model = NSManagedObjectModel()
    model.entities = [entity]
    return model
}

let container = NSPersistentContainer(name: "Shop", managedObjectModel: makeModel())

let storeDescription = NSPersistentStoreDescription()

storeDescription.type = NSInMemoryStoreType                      // app: SQLite (default)

container.persistentStoreDescriptions = [storeDescription]

container.loadPersistentStores { _, error in
    if let error {
        print("Store failed:", error)
    }
}

let context = container.viewContext                              // main-thread context

context.automaticallyMergesChangesFromParent = true              // see background saves


//==============================================================
// MARK: - 02. Create & Save
//==============================================================

print("\n========== 02 - Create & Save ==========")

for (id, name, price) in [(1, "Shoes", 4999.0), (2, "Cap", 499.0), (3, "Socks", 199.0)] {
    let product = Product(context: context)
    product.id = Int64(id)
    product.name = name
    product.price = price
}

do {
    if context.hasChanges {                                       // save only when needed
        try context.save()
        print("Saved 3 products")
    }
} catch {
    print("Save failed:", error)
}


//==============================================================
// MARK: - 03. Fetch with Predicate & Sort
//==============================================================

func fetchProducts(maxPrice: Double) -> [Product] {
    let request = NSFetchRequest<Product>(entityName: "Product")
    request.predicate = NSPredicate(format: "price < %f", maxPrice)          // filter
    request.sortDescriptors = [NSSortDescriptor(key: "price", ascending: true)]   // order
    do {
        return try context.fetch(request)
    } catch {
        print("Fetch failed:", error)
        return []
    }
}

print("\n========== 03 - Fetch ==========")

for product in fetchProducts(maxPrice: 1000) {
    print(product.name, product.price)                            // Socks 199, Cap 499
}


//==============================================================
// MARK: - 04. Update & Delete
//==============================================================

print("\n========== 04 - Update & Delete ==========")

let cheap = fetchProducts(maxPrice: 1000)

if let cap = cheap.last {
    cap.price = 399                                               // update = change property + save
}

if let socks = cheap.first {
    context.delete(socks)                                         // delete + save
}

try? context.save()

for product in fetchProducts(maxPrice: 10_000) {
    print(product.name, product.price)                            // Cap 399, Shoes 4999
}


//==============================================================
// MARK: - 05. Background Context
//==============================================================
//
// Heavy work (API import) on a background context → UI stays smooth.
// ⚠️ Managed objects belong to ONE context / thread.
//    Never pass them across threads — pass NSManagedObjectID instead.
//

Task {

    print("\n========== 05 - Background Import ==========")

    await container.performBackgroundTask { backgroundContext in
        for id in 10...12 {
            let product = Product(context: backgroundContext)
            product.id = Int64(id)
            product.name = "Imported \(id)"
            product.price = 999
        }
        do {
            try backgroundContext.save()
            print("Background: saved 3 imported products")
        } catch {
            print("Background save failed:", error)
        }
    }

    do {
        let total = try context.count(for: NSFetchRequest<Product>(entityName: "Product"))
        print("Main context sees", total, "products")             // 5
    } catch {
        print("Count failed:", error)
    }


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 06. SwiftData (iOS 17+)
//==============================================================
//
// Swift-first layer on top of Core Data:
//
// @Model final class Product { var name: String; var price: Double }
// .modelContainer(for: Product.self)                 // app setup
// @Query(sort: \Product.price) var products: [Product]   // SwiftUI fetch
// modelContext.insert(product)                       // create
//
// New SwiftUI apps → SwiftData. Existing apps / iOS < 17 → Core Data.
//


//==============================================================
// MARK: - 07. Rules
//==============================================================
//
// ✅ viewContext for UI reads; background context for imports and heavy writes
// ✅ Pass NSManagedObjectID across threads, re-fetch in the other context
// ✅ automaticallyMergesChangesFromParent = true on viewContext
// ✅ Save only if context.hasChanges
// ✅ Batch delete / update (NSBatchDeleteRequest) for large data — needs SQLite store
// ✅ Lightweight migration for simple model changes (add attribute, rename with mapping)
// ❌ Using a managed object from another thread → crashes / corrupted data
// ❌ Large imports on viewContext → frozen UI
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is the Core Data stack?
//    → Managed object model, persistent container (store coordinator), and contexts.
//
// 2. What is NSManagedObjectContext?
//    → A scratchpad where you create, fetch, change, and delete objects before saving.
//
// 3. How do you do heavy work without blocking the UI?
//    → A background context (performBackgroundTask / newBackgroundContext).
//
// 4. Can you pass a managed object to another thread?
//    → No — pass its NSManagedObjectID and fetch it in that thread's context.
//
// 5. How does the UI see background changes?
//    → automaticallyMergesChangesFromParent = true on viewContext.
//
// 6. Core Data vs SwiftData?
//    → SwiftData is a Swift-first API on Core Data for iOS 17+; Core Data works on all versions.
//
// 7. Is Core Data a database?
//    → No — it's an object graph framework that usually persists to SQLite.
//
//==============================================================
