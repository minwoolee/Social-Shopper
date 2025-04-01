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
    var userDisplayName: String // Added display name

    // Added CodingKeys for clarity
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case userId
        case timestamp
        case userDisplayName
    }

     // Custom initializer
    init(id: String? = nil, text: String, userId: String, timestamp: Date, userDisplayName: String) {
        self.id = id
        self.text = text
        self.userId = userId
        self.timestamp = timestamp
        self.userDisplayName = userDisplayName
    }
}
