import Foundation
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

// ============================================================
// MARK: - ADAPTER PATTERN
// ============================================================

/*
 Adapter = converts one interface into the interface your app expects.

 App code
    ↓ talks to
 Your protocol (AnalyticsService)
    ↓ implemented by
 Adapter  ──translates──→  Third-party SDK / legacy API

 Like a travel plug adapter: the socket doesn't change,
 the plug doesn't change — the adapter sits in between.
*/


// ============================================================
// MARK: - 1. Third-Party SDKs (you can't change these)
// ============================================================

// Pretend these come from Firebase / Mixpanel — different method names and shapes.

final class FirebaseSDK {
    func logEvent(_ name: String, parameters: [String: Any]?) {
        print("🔥 Firebase.logEvent(\(name), \(parameters as Any))")
    }
}

final class MixpanelSDK {
    func track(eventName: String, properties: [String: String]) {
        print("📈 Mixpanel.track(\(eventName), \(properties))")
    }
}


// ============================================================
// MARK: - 2. Your App's Interface
// ============================================================

// App code only knows THIS — never the SDKs directly.
protocol AnalyticsService {
    func track(event: String, properties: [String: String])
}


// ============================================================
// MARK: - 3. Adapters
// ============================================================

final class FirebaseAnalyticsAdapter: AnalyticsService {

    private let sdk = FirebaseSDK()                          // wraps the SDK

    func track(event: String, properties: [String: String]) {
        let firebaseName = event.lowercased().replacingOccurrences(of: " ", with: "_")
        sdk.logEvent(firebaseName, parameters: properties)  // translate the call
    }
}

final class MixpanelAnalyticsAdapter: AnalyticsService {

    private let sdk = MixpanelSDK()

    func track(event: String, properties: [String: String]) {
        sdk.track(eventName: event, properties: properties)
    }
}


// ============================================================
// MARK: - 4. App Code — Unchanged When the Provider Changes
// ============================================================

final class CheckoutViewModel {

    private let analytics: AnalyticsService                  // depends on YOUR protocol

    init(analytics: AnalyticsService) {
        self.analytics = analytics
    }

    func purchaseCompleted(total: Int) {
        analytics.track(event: "Purchase Completed", properties: ["total": "\(total)"])
    }
}

print("\n========== 04 - Swap Providers ==========")

CheckoutViewModel(analytics: FirebaseAnalyticsAdapter()).purchaseCompleted(total: 4999)

CheckoutViewModel(analytics: MixpanelAnalyticsAdapter()).purchaseCompleted(total: 4999)

// Switching vendor = change ONE line where the adapter is created.


// ============================================================
// MARK: - 5. Adapter for Tests
// ============================================================

final class MockAnalytics: AnalyticsService {

    private(set) var events: [String] = []

    func track(event: String, properties: [String: String]) {
        events.append(event)
    }
}

print("\n========== 05 - Mock ==========")

let mockAnalytics = MockAnalytics()

CheckoutViewModel(analytics: mockAnalytics).purchaseCompleted(total: 100)

print("Mock recorded:", mockAnalytics.events)               // ["Purchase Completed"]


// ============================================================
// MARK: - 6. Legacy Callback API → async Adapter
// ============================================================

/*
 Old code uses completion handlers; new code uses async/await.
 Adapter wraps the old API so new code never sees callbacks.
*/

final class LegacyLocationService {                          // can't / don't want to rewrite
    func fetchCity(completion: @escaping (String) -> Void) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            completion("Hyderabad")
        }
    }
}

protocol LocationProviding {
    func currentCity() async -> String
}

final class LocationAdapter: LocationProviding {

    private let legacy = LegacyLocationService()

    func currentCity() async -> String {
        await withCheckedContinuation { continuation in
            legacy.fetchCity { city in
                continuation.resume(returning: city)         // callback → async
            }
        }
    }
}

Task {

    print("\n========== 06 - Callback → async ==========")

    let city = await LocationAdapter().currentCity()

    print("City:", city)                                     // Hyderabad


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


// ============================================================
// MARK: - 7. Adapters You Already Use in iOS
// ============================================================

/*
 UIViewRepresentable        → adapts a UIKit view for SwiftUI
 UIHostingController        → adapts a SwiftUI view for UIKit
 withCheckedContinuation    → adapts callbacks to async/await
 DTO → Domain mapping       → adapts the API's shape to your model
*/


// ============================================================
// MARK: - 8. Adapter vs Facade vs Decorator
// ============================================================

/*
 ┌────────────┬─────────────────────────────────────────────────┐
 │ Adapter    │ Changes the INTERFACE so it fits what you expect │
 │ Facade     │ SIMPLIFIES a complex subsystem behind one API    │
 │ Decorator  │ ADDS behaviour, keeps the same interface         │
 └────────────┴─────────────────────────────────────────────────┘
*/


// ============================================================
// MARK: - Interview Questions
// ============================================================

/*
 Q1. What is the Adapter pattern?
     → A wrapper that converts one interface into the one your code expects.

 Q2. Why wrap a third-party SDK?
     → App code depends on your protocol, so you can swap or mock the SDK easily.

 Q3. How does Adapter help testing?
     → Tests inject a mock that conforms to the same protocol.

 Q4. Give iOS examples of adapters.
     → UIViewRepresentable, UIHostingController, continuations, DTO mapping.

 Q5. Adapter vs Facade?
     → Adapter makes interfaces compatible; Facade simplifies a complex system.

 Q6. Adapter vs Decorator?
     → Adapter changes the interface; Decorator keeps it and adds behaviour.
*/
