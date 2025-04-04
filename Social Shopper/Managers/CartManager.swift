//
//  CartManager.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation
import Observation
import FirebaseFirestore
import FirebaseAuth

@Observable
class CartManager {
    static let shared = CartManager()
    
    var items: [CartItem] = []
    var paymentSuccess = false
    var error: AppError?
    var isLoading = false

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?

    private init() {
        setupCartListener()
    }

    func removeCartListener() {
        listener?.remove()
    }

    func setupCartListener() {
        guard let userId = Auth.auth().currentUser?.uid else { return }
        
        listener?.remove()
        listener = db.collection("carts").document(userId).collection("cart")
            .addSnapshotListener { [weak self] (querySnapshot, error) in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = .databaseError("Failed to load cart: \(error.localizedDescription)")
                    return
                }
                
                guard let documents = querySnapshot?.documents else {
                    self.items = []
                    return
                }
                
                do {
                    self.items = try documents.compactMap { document in
                        try document.data(as: CartItem.self)
                    }
                } catch {
                    self.error = .databaseError("Failed to decode cart items: \(error.localizedDescription)")
                }
            }
    }

    // Add item to cart
    func addItem(product: Product, quantity: Int = 1) async throws {
        guard let userId = UserManager.shared.user?.uid else {
            error = .authenticationError("User not authenticated")
            throw error!
        }
        
        guard quantity > 0 else {
            error = .validationError("Quantity must be greater than 0")
            throw error!
        }
        
        do {
            // Check if item already exists in cart
            if let existingItem = items.first(where: { $0.product.id == product.id }) {
                // Update quantity of existing item
                try await updateItemQuantity(item: existingItem, newQuantity: existingItem.quantity + quantity)
            } else {
                // Create new cart item
                let cartItem = CartItem(product: product, quantity: quantity, userId: userId)
                try db.collection("carts").document(userId).collection("cart").addDocument(from: cartItem)
            }
        } catch {
            self.error = .databaseError("Failed to add item to cart: \(error.localizedDescription)")
            throw self.error ?? .unknownError("Failed to add item to cart")
        }
    }

    // Update item quantity
    private func updateItemQuantity(item: CartItem, newQuantity: Int) async throws {
        guard let itemId = item.id else {
            error = .validationError("Invalid cart item")
            throw error!
        }
        guard let userId = UserManager.shared.user?.uid else {
            error = .authenticationError("User not authenticated")
            throw error!
        }

        do {
            try await db.collection("carts").document(userId).collection("cart").document(itemId).updateData([
                "quantity": newQuantity,
                "updatedAt": Date()
            ])
        } catch {
            self.error = .databaseError("Failed to update item quantity: \(error.localizedDescription)")
            throw self.error ?? .unknownError("Failed to update item quantity")
        }
    }

    // Remove item from cart
    func removeItem(item: CartItem) async throws {
        guard let itemId = item.id else {
            error = .validationError("Invalid cart item")
            throw error!
        }
        guard let userId = UserManager.shared.user?.uid else {
            error = .authenticationError("User not authenticated")
            throw error!
        }

        do {
            try await db.collection("carts").document(userId).collection("cart").document(itemId).delete()
        } catch {
            self.error = .databaseError("Failed to remove item from cart: \(error.localizedDescription)")
            throw self.error ?? .unknownError("Failed to remove item from cart")
        }
    }

    // Get subtotal (price before tax)
    func getSubtotal() -> Double {
        return items.reduce(0) { total, item in
            total + (item.product.price * Double(item.quantity))
        }
    }
    
    // Get tax amount
    func getTax() -> Double {
        return getSubtotal() * 0.10 // 10% tax rate
    }

    // Get total price including tax
    func getTotalPrice() -> Double {
        return getSubtotal() + getTax()
    }

    // Clear cart
    func clearCart() async throws {
        guard let userId = Auth.auth().currentUser?.uid else {
            error = .authenticationError("User not authenticated")
            throw error!
        }
        
        do {
            let batch = db.batch()
            let snapshot = try await db.collection("carts").document(userId).collection("cart")
                .getDocuments()
            
            for document in snapshot.documents {
                batch.deleteDocument(document.reference)
            }
            
            try await batch.commit()
            paymentSuccess = true
        } catch {
            self.error = .databaseError("Failed to clear cart: \(error.localizedDescription)")
            throw self.error ?? .unknownError("Failed to clear cart")
        }
    }

    deinit {
        listener?.remove()
    }
}
