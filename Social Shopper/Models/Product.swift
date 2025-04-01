//
//  Product.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var imageUrl: String
    var category: String  // Added category for filtering

    // Example of a computed property.
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    // Equatable conformance (for more efficient comparison) - useful for SwiftUI
      static func == (lhs: Product, rhs: Product) -> Bool {
          return lhs.id == rhs.id
      }

    //  Added CodingKeys for clarity and maintainability, especially if your property
     //  names differ from your Firestore field names.
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageUrl
        case category
    }

     // Custom initializer to handle decoding
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Firestore may not always include the 'id' in the payload when retrieving
        // documents.  We handle this more robustly.  If the ID exists, decode it;
        // otherwise, leave it nil.  The @DocumentID property wrapper should then
        // populate the ID when the document is retrieved.
        id = try? container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        category = try container.decode(String.self, forKey: .category)
    }

    // Added an empty initializer
    init(id: String? = nil, name: String, description: String, price: Double, imageUrl: String, category: String) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageUrl = imageUrl
        self.category = category
    }
}
