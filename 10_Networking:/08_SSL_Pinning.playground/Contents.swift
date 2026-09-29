import Foundation
import CryptoKit
import PlaygroundSupport

PlaygroundPage.current.needsIndefiniteExecution = true

//==============================================================
// MARK: - SSL Pinning
//==============================================================
//
// Normal HTTPS trusts ANY certificate signed by a trusted CA.
// Pinning adds: "and it must be MY server's key".
//
// Protects against man-in-the-middle attacks using a mis-issued
// certificate or a user-installed proxy certificate (Charles, mitmproxy).
//
// Uses jsonplaceholder.typicode.com (needs internet). Console: ⇧⌘Y
//


//==============================================================
// MARK: - 01. Certificate vs Public Key Pinning
//==============================================================
//
// ┌────────────────────┬──────────────────────────────┬──────────────────────────────┐
// │                    │ Certificate pinning          │ Public key pinning ✅         │
// ├────────────────────┼──────────────────────────────┼──────────────────────────────┤
// │ Pins               │ The whole certificate        │ Hash of the certificate's key│
// │ Cert renewed       │ Breaks — app update needed   │ Still works if key is reused │
// │ Maintenance        │ High                         │ Lower                        │
// └────────────────────┴──────────────────────────────┴──────────────────────────────┘
//


//==============================================================
// MARK: - 02. Pinning Delegate
//==============================================================
//
// 1. Run normal TLS validation first (never skip it)
// 2. Take the server's leaf certificate → public key → SHA-256
// 3. Allow only if the hash is in the pinned set
//

final class PinningDelegate: NSObject, URLSessionDelegate, @unchecked Sendable {

    private let pinnedHashes: Set<String>

    private(set) var lastSeenHash = ""

    init(pinnedHashes: Set<String>) {
        self.pinnedHashes = pinnedHashes
    }

    func urlSession(_ session: URLSession, didReceive challenge: URLAuthenticationChallenge) async -> (URLSession.AuthChallengeDisposition, URLCredential?) {

        guard challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust,
              let trust = challenge.protectionSpace.serverTrust else {
            return (.performDefaultHandling, nil)
        }

        guard SecTrustEvaluateWithError(trust, nil) else {         // 1. normal TLS check
            print("❌ Normal certificate validation failed")
            return (.cancelAuthenticationChallenge, nil)
        }

        guard let chain = SecTrustCopyCertificateChain(trust) as? [SecCertificate],
              let leaf = chain.first,
              let key = SecCertificateCopyKey(leaf),
              let keyData = SecKeyCopyExternalRepresentation(key, nil) as Data? else {
            return (.cancelAuthenticationChallenge, nil)
        }

        let hash = Data(SHA256.hash(data: keyData)).base64EncodedString()   // 2. hash the key

        lastSeenHash = hash

        if pinnedHashes.contains(hash) {                                   // 3. compare
            print("✅ Pin matched")
            return (.useCredential, URLCredential(trust: trust))
        }

        print("❌ Pin mismatch — blocked. Server key hash:", hash)
        return (.cancelAuthenticationChallenge, nil)
    }
}


//==============================================================
// MARK: - 03. Making a Pinned Request
//==============================================================

func pinnedRequest(pins: Set<String>) async -> String {

    guard let url = URL(string: "https://jsonplaceholder.typicode.com/posts/1") else { return "" }

    let delegate = PinningDelegate(pinnedHashes: pins)

    let session = URLSession(configuration: .ephemeral, delegate: delegate, delegateQueue: nil)

    defer { session.finishTasksAndInvalidate() }                   // release the delegate

    do {
        let (_, response) = try await session.data(from: url)
        if let http = response as? HTTPURLResponse {
            print("Request allowed — status", http.statusCode)
        }
    } catch {
        print("Request blocked —", (error as? URLError)?.code == .cancelled ? "cancelled by pinning" : "\(error)")
    }

    return delegate.lastSeenHash
}


//==============================================================
// MARK: - Run
//==============================================================

Task {

    print("\n========== 03a - Wrong Pin → Blocked ==========")

    let realHash = await pinnedRequest(pins: ["FAKE-HASH="])        // simulates an attacker's cert


    print("\n========== 03b - Correct Pin → Allowed ==========")

    _ = await pinnedRequest(pins: [realHash, "BACKUP-KEY-HASH="])   // current + backup pin


    print("\n========== Done ==========")

    PlaygroundPage.current.finishExecution()
}


//==============================================================
// MARK: - 04. No-Code Option: Info.plist (iOS 14+)
//==============================================================
//
// NSAppTransportSecurity → NSPinnedDomains → your domain →
// NSPinnedLeafIdentities / NSPinnedCAIdentities → SPKI-SHA256-BASE64 hashes
//
// The system enforces it for every URLSession request — no delegate needed.
//


//==============================================================
// MARK: - 05. Rotation Risks
//==============================================================
//
// If the server's key changes and the app doesn't know the new hash,
// EVERY request fails → the app is broken until users update.
//
// ✅ Pin at least 2 keys: current + backup (next key the server will use)
// ✅ Coordinate key rotation with the backend team before it happens
// ✅ Leaf pin = strictest; intermediate / CA pin = fewer breaks, less strict
// ✅ Remote kill switch (feature flag) to disable pinning in an emergency
//


//==============================================================
// MARK: - 06. When to Use It
//==============================================================
//
// ✅ Banking, payments, health, high-value accounts
// ⚠️ Adds maintenance + blocks debugging proxies (Charles) — allow them in debug builds only
// ❌ Never skip normal validation (always SecTrustEvaluateWithError first)
// ❌ Never return .useCredential without checking — that disables TLS security
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is SSL pinning?
//    → Accepting only your server's specific certificate or key, not any CA-trusted one.
//
// 2. What attack does it prevent?
//    → Man-in-the-middle with a mis-issued or user-installed certificate.
//
// 3. Certificate vs public key pinning?
//    → Certificate pinning breaks on every renewal; key pinning survives if the key is reused.
//
// 4. How do you implement it?
//    → URLSessionDelegate server-trust challenge: validate, hash the key, compare to pinned hashes.
//      Or NSPinnedDomains in Info.plist (iOS 14+).
//
// 5. What is the biggest risk?
//    → Key rotation — a wrong pin blocks every request until an app update.
//
// 6. How do you reduce that risk?
//    → Pin a backup key, coordinate rotation, and keep a remote kill switch.
//
// 7. Does pinning replace normal certificate validation?
//    → No — always run normal TLS validation first, then check the pin.
//
//==============================================================
