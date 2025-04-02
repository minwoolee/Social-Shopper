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
                Text(comment.userId) // Show user's display name
                    .font(.caption)
                    .fontWeight(.semibold)
                Text(comment.relativeTeimstamp)
                    .font(.caption)
                    .foregroundColor(.gray)
                Spacer()
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
        userId: "minwoolee@gmail.com",
        timestamp: Date()
    )
    CommentRow(comment: comment)
}
