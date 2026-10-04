import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - 08_SENIOR_LEVEL_QUESTIONS — PLAYGROUND NOTES
// ============================================================

/*
 Senior questions test JUDGEMENT.
 Answer with: context → options → decision → trade-off → result.

 Code proofs show the building blocks behind the answers.
*/


// ============================================================
// MARK: - Q01. Designing a Feature End to End
// ============================================================

/*
 Q: How do you design a new feature end to end?

 Answer:
 Requirements → API contract → screen states → architecture
 → tests → feature flag → analytics + monitoring.
*/

enum ScreenState {
    case loading
    case loaded([String])
    case empty
    case failed(String)
    case offline([String])
}

let plannedStates: [ScreenState] = [.loading, .loaded(["A"]), .empty, .failed("x"), .offline(["cached"])]

print("DEBUG Q01 - states designed up front:", plannedStates.count)


// ============================================================
// MARK: - Q02. Technical Decisions
// ============================================================

/*
 Q: How do you make technical decisions?

 Answer:
 2–3 options, compare on clear criteria, prefer simple +
 reversible, write a short decision record.
*/

struct Option {
    let name: String
    let complexity: Int                                      // lower is better (1–5)
    let risk: Int                                            // lower is better (1–5)
    let testability: Int                                     // higher is better (1–5)

    var score: Int { testability * 2 - complexity - risk }
}

let options = [
    Option(name: "MVVM-C", complexity: 2, risk: 2, testability: 4),
    Option(name: "VIPER", complexity: 5, risk: 3, testability: 5),
    Option(name: "MVC", complexity: 1, risk: 3, testability: 1)
]

if let best = options.max(by: { $0.score < $1.score }) {
    print("DEBUG Q02 - chosen:", best.name, "(score \(best.score))")
}


// ============================================================
// MARK: - Q03. Image Loader Design
// ============================================================

/*
 Q: Design an image loading system.

 Answer:
 Memory (NSCache) → disk → network, dedupe in-flight
 requests in an actor, downsample off main, cancel on reuse.
*/

actor ImageLoader {

    private var memory: [String: String] = [:]               // NSCache in a real app

    private var inFlight: [String: Task<String, Never>] = [:]

    private(set) var networkCalls = 0

    func image(for url: String) async -> String {
        if let cached = memory[url] {
            return cached                                    // 1. memory hit
        }
        if let running = inFlight[url] {
            return await running.value                       // 2. join in-flight request
        }
        networkCalls += 1
        let task = Task {
            try? await Task.sleep(for: .milliseconds(50))    // 3. network + downsample
            return "decoded(\(url))"
        }
        inFlight[url] = task
        let image = await task.value
        memory[url] = image
        inFlight[url] = nil
        return image
    }
}


// ============================================================
// MARK: - Q04. Paginated Offline Feed
// ============================================================

/*
 Q: Design a paginated feed that works offline.

 Answer:
 Local DB = source of truth, cursor paging, guard duplicate
 loads, stop when no more pages, outbox for offline actions.
*/

final class FeedPaginator {

    private(set) var items: [String] = []

    private(set) var isLoading = false

    private(set) var hasMore = true

    private var nextCursor: Int? = 0

    func loadNextPage() {
        guard !isLoading, hasMore, let cursor = nextCursor else {
            print("DEBUG Q04 - skipped (loading or no more pages)")
            return
        }
        isLoading = true
        let page = (cursor..<min(cursor + 3, 7)).map { "Post \($0)" }   // fake API: 7 posts total
        items += page
        nextCursor = cursor + 3 < 7 ? cursor + 3 : nil
        hasMore = nextCursor != nil
        isLoading = false
    }
}

let feed = FeedPaginator()

feed.loadNextPage()

feed.loadNextPage()

feed.loadNextPage()

feed.loadNextPage()                                          // no more pages

print("DEBUG Q04 - loaded:", feed.items.count, "posts | hasMore:", feed.hasMore)


// ============================================================
// MARK: - Q05. Modularization Boundary
// ============================================================

/*
 Q: Why / how modularize?

 Answer:
 Faster builds, clear boundaries, team independence.
 Core modules + feature modules that depend only on Core
 PROTOCOLS — never on each other.
*/

// "Core" module exposes a protocol
protocol ProductDetailRouting {
    func showProductDetail(id: Int)
}

// "Search" feature knows only the protocol — not the ProductDetail module
struct SearchFeature {

    let router: ProductDetailRouting

    func userTappedResult(id: Int) {
        router.showProductDetail(id: id)
    }
}

// App target wires features together
struct AppRouter: ProductDetailRouting {
    func showProductDetail(id: Int) {
        print("DEBUG Q05 - app router opens ProductDetail module for", id)
    }
}

SearchFeature(router: AppRouter()).userTappedResult(id: 42)


// ============================================================
// MARK: - Q06–Q08. Migrations + Strangler Pattern
// ============================================================

/*
 Q6: UIKit → SwiftUI?   → incrementally, hosting + representable.
 Q7: async / Swift 6?   → bridge, convert bottom-up, actors, @MainActor.
 Q8: Refactor legacy?   → tests first, protocol in front,
                          new impl behind it, switch with a flag.
*/

protocol CartPricing {
    func total(for prices: [Double]) -> Double
}

struct LegacyCartPricing: CartPricing {                       // old, untouchable code
    func total(for prices: [Double]) -> Double {
        var sum = 0.0
        for price in prices { sum += price }
        return sum
    }
}

struct NewCartPricing: CartPricing {                          // rewritten
    func total(for prices: [Double]) -> Double {
        prices.reduce(0, +)
    }
}

let useNewPricing = true                                     // feature flag

let pricing: CartPricing = useNewPricing ? NewCartPricing() : LegacyCartPricing()

let sample = [499.0, 1500.0]

print("DEBUG Q08 - same result old/new:", LegacyCartPricing().total(for: sample) == pricing.total(for: sample))


// ============================================================
// MARK: - Q09–Q10. Feature Flags + Kill Switch
// ============================================================

/*
 Q9: Crash spike after release?
 → Scope it, pause phased rollout, kill the flag, hotfix,
   blameless postmortem.

 Q10: Flags + phased rollout?
 → Deploy ≠ release; small % first; kill switch.
*/

protocol FeatureFlags {
    func isEnabled(_ flag: String) -> Bool
}

final class RemoteFlags: FeatureFlags {

    private var values: [String: Bool] = ["newCheckout": true]

    func isEnabled(_ flag: String) -> Bool {
        if let value = values[flag] {
            return value
        }
        return false                                         // unknown flag = off
    }

    func remoteUpdate(_ flag: String, to value: Bool) {      // from remote config
        values[flag] = value
    }
}

let flags = RemoteFlags()

print("DEBUG Q09 - newCheckout before incident:", flags.isEnabled("newCheckout"))

flags.remoteUpdate("newCheckout", to: false)                 // kill switch — no app release

print("DEBUG Q09 - newCheckout after kill switch:", flags.isEnabled("newCheckout"))


// ============================================================
// MARK: - Q11. Monitoring
// ============================================================

/*
 Q: What do you monitor?

 Answer:
 Crash-free users, hangs, launch time, memory kills, API
 errors + latency, business funnels.
*/

let crashFreeUsers = 99.62

print("DEBUG Q11 - crash-free users:", crashFreeUsers, crashFreeUsers >= 99.5 ? "✅ healthy" : "⚠️ investigate")


// ============================================================
// MARK: - Q12. Backward-Compatible APIs + Force Update
// ============================================================

/*
 Q: API changes vs old app versions?

 Answer:
 Add fields (never remove / rename), decode new ones as
 optional, versioned endpoints for breaking changes,
 minimum-version force update.
*/

struct ProductV2: Decodable {
    let id: Int
    let name: String
    let badge: String?                                       // new field → optional
}

let oldServerJSON = Data(#"{"id": 1, "name": "Shoes"}"#.utf8)

if let product = try? JSONDecoder().decode(ProductV2.self, from: oldServerJSON) {
    print("DEBUG Q12 - decodes without new field:", product.name, product.badge as Any)
}

func needsForceUpdate(current: String, minimum: String) -> Bool {
    current.compare(minimum, options: .numeric) == .orderedAscending
}

print("DEBUG Q12 - 5.1.0 vs min 5.2.0 → force update:", needsForceUpdate(current: "5.1.0", minimum: "5.2.0"))

print("DEBUG Q12 - 5.10.0 vs min 5.2.0 → force update:", needsForceUpdate(current: "5.10.0", minimum: "5.2.0"))


// ============================================================
// MARK: - Q13–Q16. Quality
// ============================================================

/*
 Q13: Code review → correctness, edge cases, threading,
      memory, readability, tests, architecture fit.
 Q14: Testing strategy → pyramid + snapshots + CI on every PR.
 Q15: Security → Keychain, HTTPS, no hard-coded secrets,
      pinning, minimal logs, server-side validation.
 Q16: Accessibility / localization → Dynamic Type, VoiceOver,
      contrast, 44 pt targets, localized + locale formatting.
*/

let price = 4999.0

let indiaFormatter = NumberFormatter()

indiaFormatter.numberStyle = .currency

indiaFormatter.locale = Locale(identifier: "en_IN")

let usFormatter = NumberFormatter()

usFormatter.numberStyle = .currency

usFormatter.locale = Locale(identifier: "en_US")

print("DEBUG Q16 - locale-aware:", indiaFormatter.string(from: NSNumber(value: price)) as Any, "|", usFormatter.string(from: NSNumber(value: price)) as Any)


// ============================================================
// MARK: - Q17–Q20. Leadership & Behaviour
// ============================================================

/*
 Q17: Disagreement → understand, compare on criteria / data /
      prototype, decide, disagree-and-commit, revisit.
 Q18: Raise the team → patterns, reviews, pairing, talks, docs.
 Q19: Unclear + tight deadline → key questions, smallest
      valuable scope, risks visible, increments.
 Q20: Senior = own end to end, conscious trade-offs,
      production thinking, lift the team, clear communication.

 Answer format (STAR):
 Situation → Task → Action → Result (with numbers)
*/

print("DEBUG Q17 - answer with STAR: Situation → Task → Action → Result")


// ============================================================
// MARK: - Run Async Proof (Q03)
// ============================================================

Task {

    let loader = ImageLoader()

    async let first = loader.image(for: "shoe.jpg")
    async let second = loader.image(for: "shoe.jpg")         // same URL at the same time
    _ = await (first, second)

    _ = await loader.image(for: "shoe.jpg")                  // memory hit

    print("DEBUG Q03 - network calls for 3 requests:", await loader.networkCalls)   // 1

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - Final Mental Model
// ============================================================

/*

   Design      → states, contract, architecture, tests, flags, metrics
   Decide      → options → criteria → simple + reversible → record it
   Scale       → modules on protocols, incremental migrations
   Production  → flags, phased rollout, monitoring, postmortems
   Quality     → reviews, test pyramid, security, accessibility
   Leadership  → listen, data, commit, mentor, communicate


 Senior One-Liner:

 "I own features from requirements to production — clear
  architecture, tests, feature flags and monitoring — make
  trade-offs explicit, and raise the quality of the team and
  codebase around me."
*/
