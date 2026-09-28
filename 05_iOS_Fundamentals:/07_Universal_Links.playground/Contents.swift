import Foundation

//==============================================================
// MARK: - Universal Links
//==============================================================
//
// A normal https link that opens the app if installed,
// or the website if not.
// https://shop.example.com/product/42 → ProductDetail(42) in app
// Apple verifies the app owns the domain → secure, unique.
//


//==============================================================
// MARK: - 01. Setup
//==============================================================
//
// 1. Host the AASA file (no extension, served over https, no redirects):
//    https://shop.example.com/.well-known/apple-app-site-association
//
//    {
//      "applinks": {
//        "details": [
//          {
//            "appIDs": ["TEAMID.com.example.shop"],
//            "components": [
//              { "/": "/product/*" },
//              { "/": "/category/*" }
//            ]
//          }
//        ]
//      }
//    }
//
// 2. Xcode → Signing & Capabilities → Associated Domains:
//    applinks:shop.example.com
//
// 3. Handle the incoming NSUserActivity (below).
//


//==============================================================
// MARK: - 02. Parsing the https URL
//==============================================================
//
// Map to the same Route enum as custom-scheme deep links →
// one router for both.
//

enum Route: Equatable {
    case product(id: Int)
    case category(name: String)
    case unknown
}

func parseUniversalLink(_ url: URL) -> Route {
    guard url.scheme == "https", url.host == "shop.example.com" else {
        return .unknown
    }

    let parts = url.pathComponents.filter { $0 != "/" }

    if parts.count == 2, parts[0] == "product", let id = Int(parts[1]) {
        return .product(id: id)
    }

    if parts.count == 2, parts[0] == "category" {
        return .category(name: parts[1])
    }

    return .unknown
}


//==============================================================
// MARK: - 03. Handling NSUserActivity
//==============================================================
//
// Universal Links arrive as NSUserActivity, not openURLContexts.
//
// Warm start → scene(_:continue userActivity:)
// Cold start → connectionOptions.userActivities in willConnectTo
// SwiftUI    → .onOpenURL { url in } (also receives Universal Links)
//

func handle(_ userActivity: NSUserActivity) -> Route {
    guard userActivity.activityType == NSUserActivityTypeBrowsingWeb,
          let url = userActivity.webpageURL else {
        return .unknown
    }
    return parseUniversalLink(url)
}

print("\n========== 03 - Handling NSUserActivity ==========")

let activity = NSUserActivity(activityType: NSUserActivityTypeBrowsingWeb)

activity.webpageURL = URL(string: "https://shop.example.com/product/42")

print(handle(activity))                                   // product(id: 42)

activity.webpageURL = URL(string: "https://shop.example.com/category/running")

print(handle(activity))                                   // category(name: "running")

activity.webpageURL = URL(string: "https://evil.example.com/product/42")

print(handle(activity))                                   // unknown — wrong domain


//==============================================================
// MARK: - 04. Universal Links vs Custom Schemes
//==============================================================
//
// ┌───────────────────┬───────────────────────────┬──────────────────────┐
// │                   │ Universal Link            │ Custom Scheme        │
// ├───────────────────┼───────────────────────────┼──────────────────────┤
// │ Format            │ https://shop.example.com  │ myshop://            │
// │ App not installed │ Opens the website         │ Error / nothing      │
// │ Ownership         │ Verified via AASA         │ Any app can claim it │
// │ Prompt            │ None — opens directly     │ "Open in app?" alert │
// │ Setup             │ Server file + entitlement │ Info.plist only      │
// │ Arrives as        │ NSUserActivity            │ URL                  │
// └───────────────────┴───────────────────────────┴──────────────────────┘
//
// Marketing, email, and shared links → Universal Links.
//


//==============================================================
// MARK: - 05. Common Gotchas
//==============================================================
//
// 1. Typed / pasted into Safari's address bar → opens the website, not the app.
// 2. Tapping a link on the SAME domain in Safari → stays in Safari.
// 3. User long-presses → "Open in Safari" → iOS remembers and stops opening the app.
// 4. AASA is cached by Apple's CDN → changes take time to apply.
// 5. AASA must be served directly over https — no redirects.
// 6. Test by tapping the link in Notes or Messages, not Safari's URL bar.
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is a Universal Link?
//    → An https link that opens the app if installed, otherwise the website.
//
// 2. How do you set one up?
//    → Host the AASA file, add the Associated Domains entitlement, handle NSUserActivity.
//
// 3. What is the AASA file?
//    → A JSON file on your domain listing which app IDs and paths can open the app.
//
// 4. Where do Universal Links arrive in the app?
//    → As NSUserActivity — scene(_:continue:) warm, connectionOptions.userActivities cold.
//
// 5. Universal Links vs custom URL schemes?
//    → Universal Links are verified, unique, and fall back to web; schemes are neither.
//
// 6. Why might a Universal Link open Safari instead of the app?
//    → Typed in the URL bar, same-domain tap, user chose Safari, or AASA not updated yet.
//
//==============================================================
