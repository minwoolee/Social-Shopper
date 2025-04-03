//
//  CartManager.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation
import Observation
import FirebaseFirestore

@Observable
class CartManager {
    var items: [CartItem] = []
    var paymentSuccess = false
    var error: AppError?

    private let cartKey = "cartItems"
    private let taxRate = 0.10 // 10% tax rate

    init() {
        loadCart()
    }

    // Add item to cart
    func addItem(product: Product, quantity: Int = 1) async throws {
        guard quantity > 0 else {
            error = .validationError("Quantity must be greater than 0")
            throw error!
        }
        
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
        saveCart()
    }

    // Remove item from cart
    func removeItem(item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCart()
    }

    // Get subtotal (price before tax)
    func getSubtotal() -> Double {
        return items.reduce(0) { total, item in
            total + (item.product.price * Double(item.quantity))
        }
    }
    
    // Get tax amount
    func getTax() -> Double {
        return getSubtotal() * taxRate
    }

    // Get total price including tax
    func getTotalPrice() -> Double {
        return getSubtotal() + getTax()
    }

    func clearCart() {
        items.removeAll()
        saveCart()
        paymentSuccess = true
    }

    // Save cart to UserDefaults
    private func saveCart() {
        do {
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: cartKey)
        } catch {
            self.error = .databaseError("Failed to save cart: \(error.localizedDescription)")
            print("Error encoding cart: \(error.localizedDescription)")
        }
    }

    // Load cart from UserDefaults
    private func loadCart() {
        guard let data = UserDefaults.standard.data(forKey: cartKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([CartItem].self, from: data)
            items = decoded
        } catch {
            self.error = .databaseError("Failed to load cart: \(error.localizedDescription)")
            print("Error decoding cart: \(error.localizedDescription)")
        }
    }
}
