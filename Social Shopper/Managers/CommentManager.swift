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
    var threads: [Thread] = []
    var comments: [String: [Comment]] = [:] // threadId: [Comments]
    var isLoading = false
    var error: Error?
    
    private var db = Firestore.firestore()
    private var productID: String
    private var threadListeners: [String: ListenerRegistration] = [:]
    private var threadsListener: ListenerRegistration?
    
    init(productID: String) {
        self.productID = productID
        loadThreads()
    }
    
    func loadThreads() {
        isLoading = true
        error = nil
        
        threadsListener?.remove()
        
        // Query threads where user is a participant
        threadsListener = db.collection("products").document(productID)
            .collection("threads")
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error
                    return
                }
                
                do {
                    self.threads = try snapshot?.documents.compactMap {
                        try $0.data(as: Thread.self)
                    } ?? []
                    
                    // Load comments for each thread
                    for thread in self.threads {
                        self.loadComments(for: thread.id ?? "")
                    }
                } catch {
                    self.error = error
                }
                
                self.isLoading = false
            }
    }
    
    func loadComments(for threadId: String) {
        threadListeners[threadId]?.remove()
        
        let listener = db.collection("products").document(productID)
            .collection("threads").document(threadId)
            .collection("comments")
            .order(by: "timestamp", descending: false)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let error = error {
                    self.error = error
                    return
                }
                
                do {
                    self.comments[threadId] = try snapshot?.documents.compactMap {
                        try $0.data(as: Comment.self)
                    } ?? []
                } catch {
                    self.error = error
                }
            }
        
        threadListeners[threadId] = listener
    }
    
    func createThread(title: String, userId: String) async throws -> Thread {
        let thread = Thread(
            productId: productID,
            creatorId: userId,
            title: title,
            createdAt: Date(),
            participants: [userId]
        )
        
        let ref = try db.collection("products").document(productID)
            .collection("threads")
            .addDocument(from: thread)
        
        return try await ref.getDocument(as: Thread.self)
    }
    
    func addComment(text: String, userId: String, threadId: String) async throws {
        let comment = Comment(
            threadId: threadId,
            userId: userId,
            text: text,
            timestamp: Date()
        )
        
        try db.collection("products").document(productID)
            .collection("threads").document(threadId)
            .collection("comments")
            .addDocument(from: comment)
    }
    
    func addParticipant(_ userId: String, to threadId: String) async throws {
        try await db.collection("products").document(productID)
            .collection("threads").document(threadId)
            .updateData([
                "participants": FieldValue.arrayUnion([userId])
            ])
    }
    
    deinit {
        threadsListener?.remove()
        threadListeners.values.forEach { $0.remove() }
    }
}
