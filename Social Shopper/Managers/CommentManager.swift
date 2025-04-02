//
//  CommentManager.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Observation
import FirebaseFirestore

@Observable
class CommentManager {
    var comments: [Comment] = [] // Use @Published
    var isLoading = false
    var error: Error?

    private var db = Firestore.firestore()
    private var productID: String // Store the product ID to fetch comments for the correct product
    private var listener: ListenerRegistration?

    init(productID: String) {
        self.productID = productID
        loadComments()
    }

    // Load comments for a specific product
    func loadComments() {
        isLoading = true
        error = nil

        // Remove any existing listener
        listener?.remove()

        // Query for comments for the specific product, ordered by timestamp
        listener = db.collection("products").document(productID).collection("comments")
//            .order(by: "timestamp", descending: false) // Order by timestamp
            .addSnapshotListener { (querySnapshot, error) in
                self.isLoading = false
                if let error = error {
                    self.error = error
                    print("Error getting comments: \(error.localizedDescription)")
                    return
                } else {
                    self.comments = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Comment.self)
                    } ?? []
                }
            }
    }

    // Add a comment for a specific product
    func addComment(text: String, userId: String, userDisplayName: String) {
        let newComment = Comment(text: text, userId: userId, timestamp: Date())
        do {
            _ = try db.collection("products").document(productID).collection("comments").addDocument(from: newComment)
            // No need to call loadComments() after adding. The snapshot listener will automatically update the list.
        } catch {
            self.error = error
            print("Error adding comment: \(error.localizedDescription)")
        }
    }

     deinit {
        listener?.remove()
    }
}
