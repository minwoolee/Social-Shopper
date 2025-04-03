//
//  ProductManager.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Observation
import FirebaseFirestore

@Observable
class ProductManager {
    var products: [Product] = []
    var isLoading = false
    var error: AppError?
    
    private var db = Firestore.firestore()
    private var listener: ListenerRegistration?
    
    // Load products from Firestore
    func loadProducts() {
        isLoading = true
        error = nil
        
        // Remove any existing listener before setting up a new one
        listener?.remove()
        
        listener = db.collection("products").addSnapshotListener { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            self.isLoading = false
            
            if let error = error {
                self.error = .databaseError(error.localizedDescription)
                print("Error getting products: \(error.localizedDescription)")
                return
            }
            
            guard let documents = querySnapshot?.documents else {
                self.error = .databaseError("No documents found")
                return
            }
            
            do {
                self.products = try documents.compactMap { document in
                    try document.data(as: Product.self)
                }
            } catch {
                self.error = .databaseError("Failed to decode products: \(error.localizedDescription)")
            }
        }
    }
    
    // Add a new product to Firestore
    func addProduct(product: Product) async throws {
        isLoading = true
        defer {
            isLoading = false
        }
        error = nil
        
        do {
            let ref = try db.collection("products").addDocument(from: product)
            print("Document added with ID: \(ref.documentID)")
            
            // Verify the document was added correctly
            let addedProduct = try await ref.getDocument(as: Product.self)
            print("Verified product: \(addedProduct)")
            
            // Update local products array
            if !products.contains(where: { $0.id == addedProduct.id }) {
                products.append(addedProduct)
            }
        } catch {
            self.error = .databaseError("Failed to add product: \(error.localizedDescription)")
            throw self.error ?? .unknownError("Failed to add product")
        }
    }
    
    // Get a single product by ID
    func getProduct(by id: String) -> Product? {
        products.first { $0.id == id }
    }
    
    // Delete a product
    func deleteProduct(id: String) async throws {
        isLoading = true
        defer {
            isLoading = false
        }
        error = nil
        
        do {
            try await db.collection("products").document(id).delete()
            products.removeAll { $0.id == id }
        } catch {
            self.error = .databaseError("Failed to delete product: \(error.localizedDescription)")
            throw self.error ?? .unknownError("Failed to delete product")
        }
    }
    
    // Deinit to remove listener
    deinit {
        listener?.remove()
    }
}
