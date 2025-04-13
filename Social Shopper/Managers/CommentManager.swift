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

    @ObservationIgnored var allThreads: [Thread] = []
    @ObservationIgnored private var db = Firestore.firestore()
    @ObservationIgnored private var productID: String
    @ObservationIgnored private var threadListeners: [String: ListenerRegistration] = [:]
    @ObservationIgnored private var threadsListener: ListenerRegistration?

    init(productID: String) {
        self.productID = productID
        loadThreads()
    }

    func loadThreads() {
        isLoading = true
        error = nil

        threadsListener?.remove()

        let threadsRef = db.collection("products").document(productID).collection("threads")
        threadsListener = threadsRef.addSnapshotListener { [weak self] snapshot, error in
            guard let self = self else { return }

            if let error = error {
                self.error = error
                return
            }

            do {
                allThreads = try snapshot?.documents.compactMap {
                    try $0.data(as: Thread.self)
                } ?? []

                if let currentUserEmail = UserManager.shared.user?.email {
                    self.threads = allThreads.filter { thread in
                        thread.creatorEmail == currentUserEmail ||
                        thread.participants.contains(currentUserEmail)
                    }

                    // Load comments for each accessible thread
                    for thread in self.threads {
                        self.loadComments(for: thread.id ?? "")
                    }
                } else {
                    self.threads = []
                }
            } catch {
                self.error = error
            }

            self.isLoading = false
        }
    }

    func loadThread(by threadId: String) -> Thread? {
        guard let thread = allThreads.first(where: { $0.id == threadId }),
              let email = UserManager.shared.user?.email
        else { return nil }
        if !threads.contains(where: { $0.id == thread.id }) {
            threads.append(thread)
        }
        Task {
            do {
                try await addParticipant(email, to: threadId)
            } catch {
                self.error = error
            }
        }
        return thread
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

    func createThread(title: String, email: String) async throws -> Thread {
        let thread = Thread(
            productId: productID,
            creatorEmail: email,
            title: title,
            createdAt: Date(),
            participants: [email]
        )

        let ref = try db.collection("products").document(productID)
            .collection("threads")
            .addDocument(from: thread)

        return try await ref.getDocument(as: Thread.self)
    }

    func addComment(text: String, email: String, threadId: String) async throws {
        let comment = Comment(
            threadId: threadId,
            email: email,
            text: text,
            timestamp: Date()
        )

        try db.collection("products").document(productID)
            .collection("threads").document(threadId)
            .collection("comments")
            .addDocument(from: comment)
    }

    func addParticipant(_ email: String, to threadId: String) async throws {
        try await db.collection("products").document(productID)
            .collection("threads").document(threadId)
            .updateData([
                "participants": FieldValue.arrayUnion([email])
            ])
    }

    deinit {
        threadsListener?.remove()
        threadListeners.values.forEach { $0.remove() }
    }
}
