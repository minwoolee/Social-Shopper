//
//  Comment.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//

import Foundation
import FirebaseFirestore

struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    let threadId: String // Add thread reference
    let email: String
    let text: String
    let timestamp: Date
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: timestamp)
    }
    
    // Custom initializer
    init(id: String? = nil, threadId: String, email: String, text: String, timestamp: Date) {
        self.id = id
        self.threadId = threadId
        self.text = text
        self.email = email
        self.timestamp = timestamp
    }
}
