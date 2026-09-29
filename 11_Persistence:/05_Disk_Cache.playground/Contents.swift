import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - Memory Cache
//==============================================================
//
// Keep recently used data in RAM → instant reuse, no network / disk.
// Lost when the app is killed; the system can purge it under memory pressure.
//
// NSCache → Apple's in-memory cache:
// thread-safe, evicts automatically, supports count and cost limits.
//


//==============================================================
// MARK: - 01. NSCache Basics
//==============================================================
//
// Keys and values must be classes → NSString, NSNumber, or a wrapper.
//

final class ProductBox {
    let name: String
    init(name: String) {
        self.name = name
    }
}

print("\n========== 01 - NSCache Basics ==========")

let productCache = NSCache<NSString, ProductBox>()

productCache.setObject(ProductBox(name: "Shoes"), forKey: "product-1")

if let cached = productCache.object(forKey: "product-1") {
    print("Hit:", cached.name)                                     // Hit: Shoes
}

if productCache.object(forKey: "product-2") == nil {
    print("Miss: product-2 → load from network")
}


//==============================================================
// MARK: - 02. Count Limit
//==============================================================
//
// Max number of items. Extra items push older ones out.
// ⚠️ Eviction order is NOT guaranteed — never rely on a value being there.
//

print("\n========== 02 - Count Limit ==========")

let recentCache = NSCache<NSString, ProductBox>()

recentCache.countLimit = 2

for id in 1...3 {
    recentCache.setObject(ProductBox(name: "Item \(id)"), forKey: "item-\(id)" as NSString)
}

for id in 1...3 {
    let exists = recentCache.object(forKey: "item-\(id)" as NSString) != nil
    print("item-\(id):", exists ? "cached" : "evicted")           // usually item-1 evicted
}


//==============================================================
// MARK: - 03. Cost Limit — Image Cache
//==============================================================
//
// Limit by SIZE, not count. Cost = bytes of the decoded image.
// 50 small icons and 2 huge photos shouldn't count the same.
//

final class ImageBox {
    let bytes: Int
    init(bytes: Int) {
        self.bytes = bytes
    }
}

print("\n========== 03 - Cost Limit ==========")

let imageCache = NSCache<NSString, ImageBox>()

imageCache.totalCostLimit = 50 * 1024 * 1024                        // ~50 MB

let photo = ImageBox(bytes: 36 * 1024 * 1024)                      // 3000×3000 decoded ≈ 36 MB

imageCache.setObject(photo, forKey: "hero-photo", cost: photo.bytes)

print("Cost limit: 50 MB | stored photo cost:", photo.bytes / 1_048_576, "MB")

// Adding more images past 50 MB → NSCache evicts some automatically.


//==============================================================
// MARK: - 04. Generic Cache with Expiry
//==============================================================
//
// Swift-friendly wrapper: any Hashable key, any value, time-to-live.
//

final class Cache<Key: Hashable, Value> {

    private final class WrappedKey: NSObject {
        let key: Key
        init(_ key: Key) { self.key = key }
        override var hash: Int { key.hashValue }
        override func isEqual(_ object: Any?) -> Bool {
            guard let other = object as? WrappedKey else { return false }
            return other.key == key
        }
    }

    private final class Entry {
        let value: Value
        let expiresAt: Date
        init(value: Value, expiresAt: Date) {
            self.value = value
            self.expiresAt = expiresAt
        }
    }

    private let storage = NSCache<WrappedKey, Entry>()

    private let lifetime: TimeInterval

    init(lifetime: TimeInterval) {
        self.lifetime = lifetime
    }

    func insert(_ value: Value, for key: Key) {
        storage.setObject(Entry(value: value, expiresAt: Date().addingTimeInterval(lifetime)), forKey: WrappedKey(key))
    }

    func value(for key: Key) -> Value? {
        guard let entry = storage.object(forKey: WrappedKey(key)) else { return nil }
        guard entry.expiresAt > Date() else {
            storage.removeObject(forKey: WrappedKey(key))           // expired → remove
            return nil
        }
        return entry.value
    }
}


//==============================================================
// MARK: - 05. Cache-Aside Pattern
//==============================================================
//
// 1. Check cache → hit: return
// 2. Miss: load from network → store in cache → return
//

@MainActor
final class ProductRepository {

    private let cache = Cache<Int, String>(lifetime: 0.5)          // short TTL for the demo

    func product(id: Int) async -> String {
        if let cached = cache.value(for: id) {
            print("Cache hit → \(cached)")
            return cached
        }
        try? await Task.sleep(for: .milliseconds(100))              // fake network
        let product = "Product \(id)"
        cache.insert(product, for: id)
        print("Network → \(product) (now cached)")
        return product
    }
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 05 - Cache-Aside ==========")

    let repository = ProductRepository()

    _ = await repository.product(id: 7)                            // Network
    _ = await repository.product(id: 7)                            // Cache hit

    try? await Task.sleep(for: .milliseconds(600))                 // wait past TTL

    _ = await repository.product(id: 7)                            // Network again — expired


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 06. NSCache vs Dictionary
//==============================================================
//
// ┌──────────────────────┬────────────────────────┬────────────────────────┐
// │                      │ NSCache                │ Dictionary             │
// ├──────────────────────┼────────────────────────┼────────────────────────┤
// │ Thread-safe          │ Yes                    │ No                     │
// │ Memory pressure      │ Evicts automatically   │ Grows until app killed │
// │ Limits               │ countLimit, cost       │ None                   │
// │ Keys / values        │ Classes (AnyObject)    │ Any Hashable / any     │
// │ Guaranteed to keep   │ No                     │ Yes                    │
// └──────────────────────┴────────────────────────┴────────────────────────┘
//
// Need strict LRU order? Build one → 15_Coding_Practice/01_LRU_Cache
//


//==============================================================
// MARK: - 07. Rules
//==============================================================
//
// ✅ NSCache for images and API responses reused on screen
// ✅ Use cost = decoded bytes for images; set totalCostLimit
// ✅ Always handle a miss — cached data can disappear any time
// ✅ Add expiry (TTL) for data that goes stale (prices, stock)
// ✅ Pair with a disk cache for data that should survive relaunch (05_Disk_Cache)
// ❌ Dictionary as an image cache → memory grows until the app is killed
// ❌ Treating the cache as the source of truth
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is NSCache?
//    → A thread-safe in-memory key–value cache that evicts under memory pressure.
//
// 2. NSCache vs Dictionary?
//    → NSCache is thread-safe, has limits, and auto-evicts; a Dictionary keeps growing.
//
// 3. countLimit vs totalCostLimit?
//    → countLimit caps the number of items; totalCostLimit caps total size by cost.
//
// 4. What cost should an image have?
//    → Its decoded size in bytes (width × height × 4).
//
// 5. Is NSCache eviction LRU?
//    → Not guaranteed — always handle a miss.
//
// 6. How do you handle stale data?
//    → Store an expiry date with each entry and ignore expired ones.
//
// 7. Memory cache vs disk cache?
//    → Memory is fastest but lost on relaunch; disk survives relaunch but is slower.
//
//==============================================================
