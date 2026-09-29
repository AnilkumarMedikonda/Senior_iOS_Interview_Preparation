import Foundation

//==============================================================
// MARK: - Codable
//==============================================================
//
// Codable = Decodable + Encodable
// Decodable → JSON Data  → Swift model   (JSONDecoder)
// Encodable → Swift model → JSON Data    (JSONEncoder)
//
// Runs offline — JSON is written as strings.
//

func json(_ text: String) -> Data {
    Data(text.utf8)
}


//==============================================================
// MARK: - 01. Decode JSON → Model
//==============================================================

struct Product: Codable {
    let id: Int
    let name: String
    let price: Double
}

print("\n========== 01 - Decode ==========")

do {
    let data = json(#"{"id": 1, "name": "Shoes", "price": 49.99}"#)

    let product = try JSONDecoder().decode(Product.self, from: data)

    print(product.name, product.price)                    // Shoes 49.99
} catch {
    print("Error:", error)
}


//==============================================================
// MARK: - 02. Encode Model → JSON
//==============================================================

print("\n========== 02 - Encode ==========")

do {
    let encoder = JSONEncoder()

    encoder.outputFormatting = [.prettyPrinted, .sortedKeys]

    let data = try encoder.encode(Product(id: 2, name: "Cap", price: 9.99))

    print(String(decoding: data, as: UTF8.self))
} catch {
    print("Error:", error)
}


//==============================================================
// MARK: - 03. Different Key Names
//==============================================================
//
// API sends snake_case, Swift uses camelCase.
// Option A: keyDecodingStrategy = .convertFromSnakeCase (all keys)
// Option B: CodingKeys (rename specific keys)
//

struct User: Codable {
    let firstName: String
    let isPremium: Bool
}

struct Order: Codable {
    let orderID: Int
    let total: Double

    enum CodingKeys: String, CodingKey {
        case orderID = "order_number"                     // different name entirely
        case total
    }
}

print("\n========== 03 - Different Key Names ==========")

do {
    let decoder = JSONDecoder()

    decoder.keyDecodingStrategy = .convertFromSnakeCase

    let user = try decoder.decode(User.self, from: json(#"{"first_name": "Anil", "is_premium": true}"#))

    print(user.firstName, user.isPremium)                 // Anil true

    let order = try JSONDecoder().decode(Order.self, from: json(#"{"order_number": 501, "total": 99.5}"#))

    print(order.orderID, order.total)                     // 501 99.5
} catch {
    print("Error:", error)
}


//==============================================================
// MARK: - 04. Optional vs Required Keys
//==============================================================
//
// Optional property → missing key or null = nil ✅
// Required property → missing key = WHOLE decode fails ❌
//

struct Profile: Codable {
    let name: String
    let bio: String?
}

print("\n========== 04 - Optional vs Required ==========")

do {
    let profile = try JSONDecoder().decode(Profile.self, from: json(#"{"name": "Anil"}"#))

    print("Bio:", profile.bio as Any)                     // nil — fine

    _ = try JSONDecoder().decode(Profile.self, from: json(#"{"bio": "iOS dev"}"#))
} catch {
    print("Missing name → decode failed")                 // required key missing
}


//==============================================================
// MARK: - 05. Nested JSON & Arrays
//==============================================================
//
// Match the JSON shape with nested structs.
// Common API shape: { "data": [ ... ], "page": 1 }
//

struct Seller: Codable {
    let name: String
}

struct Listing: Codable {
    let title: String
    let seller: Seller                                    // nested object
}

struct ListingResponse: Codable {
    let data: [Listing]                                   // array
    let page: Int
}

print("\n========== 05 - Nested & Arrays ==========")

do {
    let data = json("""
    {
      "page": 1,
      "data": [
        { "title": "Shoes", "seller": { "name": "Skechers" } },
        { "title": "Cap",   "seller": { "name": "Nike" } }
      ]
    }
    """)

    let response = try JSONDecoder().decode(ListingResponse.self, from: data)

    for listing in response.data {
        print(listing.title, "by", listing.seller.name)   // Shoes by Skechers, Cap by Nike
    }
} catch {
    print("Error:", error)
}


//==============================================================
// MARK: - 06. Dates
//==============================================================
//
// Tell the decoder the date format — default expects a number.
// .iso8601 → "2026-09-29T10:30:00Z"
//

struct Delivery: Codable {
    let expectedAt: Date
}

print("\n========== 06 - Dates ==========")

do {
    let decoder = JSONDecoder()

    decoder.dateDecodingStrategy = .iso8601

    let delivery = try decoder.decode(Delivery.self, from: json(#"{"expectedAt": "2026-09-29T10:30:00Z"}"#))

    print("Expected:", delivery.expectedAt)
} catch {
    print("Error:", error)
}


//==============================================================
// MARK: - 07. Custom Decoding
//==============================================================
//
// Write init(from:) when the JSON doesn't match your model:
// price sent as a String, a key that should have a default value.
//

struct CartItem: Decodable {
    let name: String
    let price: Double
    let quantity: Int

    enum CodingKeys: String, CodingKey {
        case name, price, quantity
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        name = try container.decode(String.self, forKey: .name)

        let priceText = try container.decode(String.self, forKey: .price)       // "49.99"
        guard let parsedPrice = Double(priceText) else {
            throw DecodingError.dataCorruptedError(forKey: .price, in: container, debugDescription: "Bad price")
        }
        price = parsedPrice

        if let decodedQuantity = try container.decodeIfPresent(Int.self, forKey: .quantity) {
            quantity = decodedQuantity
        } else {
            quantity = 1                                  // default when missing
        }
    }
}

print("\n========== 07 - Custom Decoding ==========")

do {
    let item = try JSONDecoder().decode(CartItem.self, from: json(#"{"name": "Socks", "price": "49.99"}"#))

    print(item.name, item.price, item.quantity)           // Socks 49.99 1
} catch {
    print("Error:", error)
}


//==============================================================
// MARK: - 08. Reading Decoding Errors
//==============================================================
//
// DecodingError tells you exactly what went wrong and where.
//

print("\n========== 08 - Decoding Errors ==========")

let badJSON = json(#"{"id": "one", "name": "Shoes", "price": 49.99}"#)   // id is a String

do {
    _ = try JSONDecoder().decode(Product.self, from: badJSON)
} catch DecodingError.typeMismatch(let type, let context) {
    print("Type mismatch: expected \(type) at", context.codingPath.map(\.stringValue))   // ["id"]
} catch DecodingError.keyNotFound(let key, _) {
    print("Missing key:", key.stringValue)
} catch {
    print("Other error:", error)
}


//==============================================================
// MARK: - Interview Questions
//==============================================================
//
// 1. What is Codable?
//    → A typealias for Decodable & Encodable — converts between models and JSON.
//
// 2. How do you map snake_case keys?
//    → keyDecodingStrategy = .convertFromSnakeCase, or CodingKeys for specific names.
//
// 3. What happens when a required key is missing?
//    → The whole decode fails with keyNotFound — make it Optional if it can be absent.
//
// 4. How do you decode dates?
//    → Set dateDecodingStrategy (e.g. .iso8601) on the decoder.
//
// 5. When do you write init(from:)?
//    → When JSON types or shapes don't match the model, or you need default values.
//
// 6. How do you debug a failing decode?
//    → Catch DecodingError — it gives the key, the expected type, and the coding path.
//
//==============================================================
