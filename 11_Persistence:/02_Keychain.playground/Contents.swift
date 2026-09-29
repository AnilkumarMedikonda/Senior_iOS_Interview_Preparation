import Foundation
import Security

//==============================================================
// MARK: - Keychain
//==============================================================
//
// Encrypted storage for secrets: tokens, passwords, API keys.
// Managed by the system, protected by the device passcode.
// API: SecItemAdd / SecItemCopyMatching / SecItemUpdate / SecItemDelete
//
// ⚠️ A playground may lack keychain access (error -34018).
//    The code is correct — it works in a real app target.
//


//==============================================================
// MARK: - 01. Keychain vs UserDefaults
//==============================================================
//
// ┌──────────────────┬──────────────────────┬──────────────────────────────┐
// │                  │ UserDefaults         │ Keychain                     │
// ├──────────────────┼──────────────────────┼──────────────────────────────┤
// │ Encrypted        │ No — plain plist     │ Yes                          │
// │ Use for          │ Settings, flags      │ Tokens, passwords, secrets   │
// │ App deleted      │ Removed              │ Usually KEPT                 │
// │ API              │ Simple               │ C-style SecItem dictionaries │
// └──────────────────┴──────────────────────┴──────────────────────────────┘
//


//==============================================================
// MARK: - 02. Keychain Store
//==============================================================
//
// One item = class + service + account.
// Save = update if it exists, otherwise add.
//

enum KeychainError: Error {
    case unexpectedStatus(OSStatus)
}

struct KeychainStore {

    let service = "com.shop.app"

    private func baseQuery(account: String) -> [String: Any] {
        [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: service,
            kSecAttrAccount as String: account
        ]
    }

    func save(_ value: String, account: String) throws {

        let data = Data(value.utf8)

        let updateStatus = SecItemUpdate(
            baseQuery(account: account) as CFDictionary,
            [kSecValueData as String: data] as CFDictionary
        )

        if updateStatus == errSecSuccess {
            return                                                  // updated existing item
        }

        guard updateStatus == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(updateStatus)
        }

        var addQuery = baseQuery(account: account)
        addQuery[kSecValueData as String] = data
        addQuery[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly

        let addStatus = SecItemAdd(addQuery as CFDictionary, nil)

        guard addStatus == errSecSuccess else {
            throw KeychainError.unexpectedStatus(addStatus)
        }
    }

    func read(account: String) throws -> String? {

        var query = baseQuery(account: account)
        query[kSecReturnData as String] = true
        query[kSecMatchLimit as String] = kSecMatchLimitOne

        var result: AnyObject?

        let status = SecItemCopyMatching(query as CFDictionary, &result)

        if status == errSecItemNotFound {
            return nil
        }

        guard status == errSecSuccess, let data = result as? Data else {
            throw KeychainError.unexpectedStatus(status)
        }

        return String(decoding: data, as: UTF8.self)
    }

    func delete(account: String) throws {

        let status = SecItemDelete(baseQuery(account: account) as CFDictionary)

        guard status == errSecSuccess || status == errSecItemNotFound else {
            throw KeychainError.unexpectedStatus(status)
        }
    }
}


//==============================================================
// MARK: - 03. Accessibility Levels
//==============================================================
//
// WHEN the item can be read:
//
// kSecAttrAccessibleWhenUnlocked                   → only while unlocked (default)
// kSecAttrAccessibleAfterFirstUnlock               → after first unlock since boot
//                                                    (background refresh / silent push)
// …ThisDeviceOnly                                  → not in backups, not moved to a new device
//
// Tokens → AfterFirstUnlockThisDeviceOnly (works in background, stays on this device)
//


//==============================================================
// MARK: - Run
//==============================================================

func describe(_ error: Error) -> String {
    if case KeychainError.unexpectedStatus(let status) = error,
       let message = SecCopyErrorMessageString(status, nil) as String? {
        return "\(status) — \(message)"
    }
    return "\(error)"
}

let keychain = KeychainStore()

do {
    print("\n========== 02a - Save ==========")

    try keychain.save("access-token-v1", account: "accessToken")

    print("Saved")


    print("\n========== 02b - Read ==========")

    if let token = try keychain.read(account: "accessToken") {
        print("Read:", token)                                     // access-token-v1
    }


    print("\n========== 02c - Update ==========")

    try keychain.save("access-token-v2", account: "accessToken")   // same account → update

    if let token = try keychain.read(account: "accessToken") {
        print("Read after update:", token)                        // access-token-v2
    }


    print("\n========== 02d - Delete (Logout) ==========")

    try keychain.delete(account: "accessToken")

    let afterDelete = try keychain.read(account: "accessToken")

    print("After delete:", afterDelete as Any)                    // nil
} catch {
    print("Keychain error:", describe(error))
    print("(-34018 in a playground = no keychain entitlement — works in an app)")
}


//==============================================================
// MARK: - 04. Survives App Deletion
//==============================================================
//
// Keychain items usually stay after the app is deleted.
// Reinstall → old tokens appear → user looks "logged in".
//
// Fix: on first launch, clear the keychain.
//
// if !UserDefaults.standard.bool(forKey: "hasRunBefore") {   // UserDefaults IS deleted with the app
//     try? keychain.delete(account: "accessToken")
//     UserDefaults.standard.set(true, forKey: "hasRunBefore")
// }
//


//==============================================================
// MARK: - 05. Sharing & Biometrics
//==============================================================
//
// Share between your apps / extensions → kSecAttrAccessGroup (Keychain Sharing capability)
// Require Face ID / Touch ID to read → SecAccessControl with .biometryCurrentSet
//


//==============================================================
// MARK: - 06. Rules
//==============================================================
//
// ✅ Tokens, passwords, API keys → Keychain
// ✅ Wrap SecItem calls in one small store type
// ✅ Save = update, or add if not found (avoid errSecDuplicateItem)
// ✅ Delete on logout; clear on first launch after reinstall
// ✅ Pick accessibility on purpose (background access? leave the device?)
// ❌ Storing secrets in UserDefaults, plist files, or source code
// ❌ Keeping large data here — Keychain is for small secrets
//


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. Why store tokens in the Keychain instead of UserDefaults?
//    → The Keychain is encrypted and system-protected; UserDefaults is a plain plist.
//
// 2. Which APIs do you use?
//    → SecItemAdd, SecItemCopyMatching, SecItemUpdate, SecItemDelete.
//
// 3. How do you avoid errSecDuplicateItem?
//    → Try SecItemUpdate first, add only if the item isn't found.
//
// 4. What are accessibility levels?
//    → Rules for when an item can be read — e.g. only unlocked, or after first unlock.
//
// 5. Which level for a refresh token used in background tasks?
//    → AfterFirstUnlockThisDeviceOnly.
//
// 6. What happens to Keychain items when the app is deleted?
//    → They usually remain — clear them on first launch after reinstall.
//
// 7. How do you protect an item with Face ID?
//    → SecAccessControl with a biometry flag like .biometryCurrentSet.
//
//==============================================================
