//
//  Product.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation
import FirebaseFirestore

enum Category: String, Codable, CaseIterable {
    case clothing = "Clothing"
    case electronics = "Electronics"
    case books = "Books"
    case homeGoods = "Home Goods"
}

struct Product: Identifiable, Codable, Equatable, Hashable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var imageUrl: String
    var category: Category

    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    // Equatable conformance (for more efficient comparison) - useful for SwiftUI
    static func == (lhs: Product, rhs: Product) -> Bool {
        return lhs.id == rhs.id
    }

    // Added an empty initializer
    init(id: String? = nil, name: String, description: String, price: Double, imageUrl: String, category: Category) {
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
            description: "The Apple iPhone 14 Pro Max 5G comes with a 6.7-inch ProMotion technology touchscreen, features Crash Detection and a new Truedepth 48-megapixel front camera with Photonic Engine, an extra hour of video playback compared to last year's model and a new Action mode that provides smoother looking videos with better image stabilization.This is all powered by the Apple A16 Bionic chipset and 6GB of RAM.",
            price: 297.00,
            imageUrl: "https://m.media-amazon.com/images/I/71MKNCEgE6L._AC_SL1500_.jpg",
            category: .electronics
        )
    }
}
