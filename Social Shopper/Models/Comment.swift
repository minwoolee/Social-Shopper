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

    var relativeTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full // e.g., "5 minutes ago", "1 hour ago"
        return formatter.localizedString(for: timestamp, relativeTo: Date())
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
