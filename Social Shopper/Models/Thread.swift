import Foundation
import FirebaseFirestore

struct Thread: Identifiable, Codable {
    @DocumentID var id: String?
    let productId: String
    let creatorEmail: String
    let title: String
    let createdAt: Date
    var participants: [String] // Array of user IDs/emails
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdAt)
    }
}
