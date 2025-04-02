//
//  Product.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation
import FirebaseFirestore

struct Product: Identifiable, Codable, Equatable, Hashable {
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

    // Added an empty initializer
    init(id: String? = nil, name: String, description: String, price: Double, imageUrl: String, category: String) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageUrl = imageUrl
        self.category = category
    }

    static var sample: Product {
        .init(
            id: "123",
            name: "Apple iPhone 13",
            description: "6.1\" Super Retina XDR display. 5G Superfast downloads, high quality streaming",
            price: 297.00,
            imageUrl: "https://m.media-amazon.com/images/I/71MKNCEgE6L._AC_SL1500_.jpg",
            category: "Electronics"
        )
    }
}
