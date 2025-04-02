//
//  CommentRow.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import SwiftUI

struct CommentRow: View {
    var comment: Comment

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(comment.userDisplayName) // Show user's display name
                    .font(.headline)
                    .fontWeight(.semibold)
                Spacer()
                Text(comment.timestamp.formatted()) // Show formatted date
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            Text(comment.text)
                .font(.body)
                .foregroundColor(.primary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    let comment = Comment(
        id: "123",
        text: "Hello world!",
        userId: "minwoolee",
        timestamp: Date(),
        userDisplayName: "Min Woo Lee"
    )
    CommentRow(comment: comment)
}
