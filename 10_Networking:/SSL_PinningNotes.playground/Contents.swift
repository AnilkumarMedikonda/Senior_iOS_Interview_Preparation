import Foundation

// MARK: - 01. What is SSL Pinning?

/*
 SSL Pinning is an additional security mechanism used
 to ensure that the app communicates with the expected server.

 Normal HTTPS:

 App
   ↓
 HTTPS / TLS
   ↓
 Server Certificate Validation
   ↓
 Server

 With SSL Pinning:

 App
   ↓
 HTTPS / TLS
   ↓
 Normal Certificate Validation
   ↓
 Pinning Check
   ↓
 Expected Certificate / Public Key?
   ↓
 Yes → Allow
 No  → Reject
*/

// MARK: - 02. HTTPS vs SSL Pinning

/*
 HTTPS/TLS:

 - Encrypts data between App and Server.
 - Protects data in transit.
 - Validates the server certificate using the system
   trust mechanism.

 SSL Pinning:

 - Adds an additional trust check.
 - The app expects a specific certificate or public key.
 - Connection is rejected if the expected pin does not match.

 Important:

 SSL Pinning does NOT replace HTTPS.
 It works on top of HTTPS/TLS.
*/

// MARK: - 03. TLS

/*
 TLS = Transport Layer Security.

 TLS provides:

 1. Encryption
 2. Server authentication
 3. Data integrity

 HTTPS = HTTP + TLS
*/

// MARK: - 04. Server Certificate

/*
 A server presents a digital certificate during the TLS
 handshake.

 Example:

 App
   ↓
 HTTPS Request
   ↓
 TLS Handshake
   ↓
 Server sends Certificate
   ↓
 iOS validates certificate
*/

// MARK: - 05. Normal Certificate Validation

/*
 iOS normally validates the server certificate using
 the system trust chain.

 Simplified:

 Server Certificate
       ↓
 Certificate Authority
       ↓
 Trusted Root
       ↓
 Valid?
   ↙       ↘
 Yes       No
  ↓         ↓
Allow     Reject
*/

// MARK: - 06. What Does Pinning Add?

/*
 With pinning, the app also has an expected value.

 Example:

 App contains:
 Expected Certificate / Public Key

 Server provides:
 Actual Certificate / Public Key

 Compare:

 Expected == Actual
       ↓
     Allow

 Expected != Actual
       ↓
     Reject
*/

// MARK: - 07. Certificate Pinning

/*
 Certificate Pinning means the app pins a specific
 server certificate.

 Concept:

 App
  ↓
 Expected Certificate
  ↓
 Compare with server certificate
  ↓
 Match → Allow
*/

// MARK: - 08. Public Key Pinning

/*
 Instead of pinning the complete certificate,
 the app can pin the server's public key.

 Concept:

 Server Certificate
       ↓
   Public Key
       ↓
     Compare
       ↓
     Match → Allow

 Public-key pinning can provide more flexibility when
 certificates are renewed but the underlying key remains
 unchanged, depending on the pinning strategy.
*/

// MARK: - 09. Certificate Pinning vs Public Key Pinning

/*
 Certificate Pinning:

 App pins:
 Complete certificate

 Public Key Pinning:

 App pins:
 Public key / key representation

 Main difference:

 Certificate pinning is tied more directly to a specific
 certificate.

 Public-key pinning can survive some certificate renewals
 when the pinned key remains the same.
*/

// MARK: - 10. URLSessionDelegate

/*
 URLSessionDelegate can participate in TLS authentication
 challenges.

 Important API:

 urlSession(_:didReceive:completionHandler:)

 (async version: urlSession(_:didReceive:) async)

 The delegate can inspect the authentication challenge
 and decide how to handle server trust.

 No-code option (iOS 14+):

 Info.plist → NSAppTransportSecurity → NSPinnedDomains
 → the system enforces the pins for every URLSession request.
*/

// MARK: - 11. URLAuthenticationChallenge

/*
 URLAuthenticationChallenge provides authentication
 information during the connection.

 For server trust:

 challenge.protectionSpace.authenticationMethod

 can indicate:

 NSURLAuthenticationMethodServerTrust
*/

// MARK: - 12. Server Trust

/*
 Server Trust represents whether the app trusts the
 server's identity during the TLS connection.

 Normal system validation should generally be preserved.

 Pinning adds an application-specific check on top of
 the normal trust evaluation.
*/

// MARK: - 13. Pinning Flow

/*
 App
  ↓
 HTTPS Request
  ↓
 TLS Handshake
  ↓
 Server Certificate
  ↓
 System Trust Evaluation
  ↓
 Pinning Validation
  ↓
 ┌───────────────┐
 │ Pin Matches?  │
 └───────┬───────┘
    Yes  │  No
     ↓       ↓
   Allow   Reject
*/

// MARK: - 14. Certificate Rotation

/*
 Important production problem:

 Certificates expire and are renewed.

 Example:

 App pins Certificate A.

 Server replaces:

 Certificate A → Certificate B

 If the app only trusts Certificate A:

 App → Server
       ↓
 Certificate B
       ↓
 Pin mismatch
       ↓
 Connection rejected

 Therefore pinning requires a certificate/key rotation
 strategy.
*/

// MARK: - 15. Multiple Pins

/*
 An app can support multiple valid pins.

 Example:

 Current Certificate → Pin A
 Backup Certificate  → Pin B

 Server can move from A to B without immediately
 breaking older app versions, depending on the
 deployment strategy.

 Extra safety:

 Remote kill switch (feature flag) to turn pinning off
 in an emergency without an app update.
*/

// MARK: - 16. What Happens When Pinning Fails?

/*
 Pin mismatch:

 Expected Pin
      ≠
 Server Pin

        ↓

 Reject the connection.

 The API request should not continue with the
 untrusted server.
*/

// MARK: - 17. SSL Pinning Is Not Encryption

/*
 SSL Pinning does NOT encrypt data by itself.

 TLS provides encryption.

 Pinning provides an additional server trust restriction.

 Remember:

 TLS       → Secure communication
 Pinning   → Additional server identity check
*/

// MARK: - 18. SSL Pinning Is Not Authentication

/*
 SSL Pinning verifies the server identity.

 It does NOT authenticate the user.

 User authentication can use:

 - Access Tokens
 - OAuth
 - JWT
 - Session credentials

 Different concepts:

 TLS/Pinning    → Is this the expected server?
 Authentication → Is this the expected user?
*/

// MARK: - 19. When Is Pinning Useful?

/*
 Pinning may be considered for applications handling
 sensitive communications where stronger control over
 server trust is required.

 Examples can include:

 - Financial applications
 - Enterprise applications
 - Highly sensitive APIs

 The decision should consider operational complexity,
 certificate rotation, and recovery strategy.
*/

// MARK: - 20. Important Limitation

/*
 Pinning is not automatically "more secure" in every
 situation.

 Incorrect pinning can cause:

 - API outages
 - App connectivity failures
 - Certificate rotation problems
 - Older app versions becoming unable to connect

 It also blocks debugging proxies (Charles, Proxyman)
 → allow them only in debug builds.

 Therefore pinning needs careful lifecycle management.
*/

// MARK: - 21. Senior Architecture

/*
 Networking Layer

 View
   ↓
 ViewModel
   ↓
 Repository
   ↓
 APIClient
   ↓
 URLSession
   ↓
 URLSessionDelegate
   ↓
 TLS / Server Trust
   ↓
 Pinning Validation
   ↓
 Server
*/

// MARK: - 22. Senior Interview Questions

/*
 Q1. What is SSL Pinning?

 A:
 An additional server-trust mechanism where the app
 verifies the server certificate or public key against
 a known expected value.

 Q2. Does SSL Pinning replace HTTPS?

 A:
 No. Pinning works in addition to HTTPS/TLS.

 Q3. Certificate Pinning vs Public Key Pinning?

 A:
 Certificate pinning validates a specific certificate.

 Public-key pinning validates the expected public key
 associated with the server identity.

 Q4. Where can SSL Pinning be implemented in iOS?

 A:
 URLSessionDelegate can handle server trust
 authentication challenges.

 Q5. What happens if the certificate changes?

 A:
 The pin can fail unless the app has a valid rotation
 or backup-pin strategy.

 Q6. What is the biggest operational risk?

 A:
 Incorrect pin management can break connectivity for
 released app versions.

 Q7. Does SSL Pinning authenticate the user?

 A:
 No. It validates the server identity.

 Q8. Does SSL Pinning encrypt network traffic?

 A:
 No. TLS provides encryption.

 Q9. What does HTTPS provide?

 A:
 Encryption, integrity, and server authentication
 through TLS.

*/

// MARK: - 23. Senior One-Liners

/*
 HTTPS
 → HTTP protected by TLS.

 TLS
 → Encrypts and protects communication.

 Certificate
 → Digital identity presented by the server.

 SSL Pinning
 → Additional check against an expected certificate/key.

 Certificate Pinning
 → Pin a specific certificate.

 Public Key Pinning
 → Pin the server's public key.

 URLSessionDelegate
 → Can participate in server-trust challenges.

 Pin Rotation
 → Strategy for changing certificates/keys without
    breaking clients.
*/
