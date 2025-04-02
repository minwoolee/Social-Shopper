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
    var text: String
    var userId: String  //  Consider storing a user ID, not the whole user object.
    var timestamp: Date

    var relativeTeimstamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: .now)
    }

     // Custom initializer
    init(id: String? = nil, text: String, userId: String, timestamp: Date) {
        self.id = id
        self.text = text
        self.userId = userId
        self.timestamp = timestamp
    }
}
