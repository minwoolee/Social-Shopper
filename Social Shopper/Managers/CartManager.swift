//
//  CartManager.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation
import Observation

@Observable
class CartManager {
    var items: [CartItem] = []
    var paymentSuccess = false // Added state for payment confirmation

    private let cartKey = "cartItems" // Consistent key for UserDefaults

    init() {
        loadCart()
    }

    // Add item to cart
    func addItem(product: Product, quantity: Int = 1) {
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

    // Get total price of items in cart
      func getTotalPrice() -> Double {
          return items.reduce(0) { total, item in
              total + (item.product.price * Double(item.quantity))
          }
      }

    func clearCart() {
        items.removeAll()
        saveCart()
        paymentSuccess = true // Set the flag
    }

    // Save cart to UserDefaults
    private func saveCart() {
        do {
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: cartKey)
        } catch {
            print("Error encoding cart: \(error.localizedDescription)")
            // Consider showing an alert to the user in a real app.
        }
    }

    // Load cart from UserDefaults
    private func loadCart() {
        guard let data = UserDefaults.standard.data(forKey: cartKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([CartItem].self, from: data)
            items = decoded
        } catch {
            print("Error decoding cart: \(error.localizedDescription)")
            // Consider showing an alert to the user in a real app.
        }
    }
}
