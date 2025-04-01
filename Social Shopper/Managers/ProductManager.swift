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
    var error: Error?

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration? // To store the listener

    // Load products from Firestore
    func loadProducts() {
        isLoading = true
        error = nil

        // Remove any existing listener before setting up a new one
        listener?.remove()

        listener = db.collection("products").addSnapshotListener { (querySnapshot, error) in
            self.isLoading = false
            if let error = error {
                self.error = error
                print("Error getting products: \(error.localizedDescription)") // Log the error
                return
            } else {
                self.products = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Product.self)
                } ?? []
            }
        }
    }

    // Add a new product to Firestore
    func addProduct(product: Product) {
        do {
            _ = try db.collection("products").addDocument(from: product)
        } catch {
            self.error = error
            print("Error adding product: \(error.localizedDescription)")
        }
    }

    // Get a single product by ID.
    func getProduct(by id: String) -> Product? {
        products.first { $0.id == id }
    }

    // Deinit to remove listener
     deinit {
         listener?.remove() // Clean up the listener when the manager is deallocated
     }
}
