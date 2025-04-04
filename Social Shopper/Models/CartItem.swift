//
//  CartItem.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation
import FirebaseFirestore

enum CartItemError: LocalizedError {
    case invalidQuantity
    case invalidProduct
    
    var errorDescription: String? {
        switch self {
        case .invalidQuantity:
            return "Quantity must be greater than 0"
        case .invalidProduct:
            return "Invalid product data"
        }
    }
}

struct CartItem: Identifiable, Codable {
    @DocumentID var id: String?
    var product: Product
    var quantity: Int
    var userId: String
    var createdAt: Date
    var updatedAt: Date
    
    // MARK: - Validation
    private func validate() throws {
        if quantity <= 0 {
            throw CartItemError.invalidQuantity
        }
    }
    
    // MARK: - Initialization
    init(id: String? = nil, product: Product, quantity: Int, userId: String) {
        self.id = id
        self.product = product
        self.quantity = quantity
        self.userId = userId
        self.createdAt = Date()
        self.updatedAt = Date()
    }
    
    // MARK: - Sample Data
    static var sample: CartItem {
        .init(
            product: .sample,
            quantity: 1,
            userId: "sample_user"
        )
    }
}
