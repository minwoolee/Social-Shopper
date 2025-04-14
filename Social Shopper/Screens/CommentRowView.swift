import SwiftUI

struct CommentRowView: View {
    let comment: Comment
    let isCurrentUser: Bool
    @State private var isAnimating = false

    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }

            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(comment.email)
                    .font(.caption)
                    .foregroundColor(.gray)

                Text(comment.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color.blue.opacity(0.8) : Color(UIColor.systemGray5))
                    .foregroundColor(isCurrentUser ? .white : .primary)
                    .clipShape(RoundedRectangle(cornerRadius: 16))

                Text(comment.relativeTimestamp)
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
            .padding(.vertical, 2)
            .offset(x: isAnimating ? 0 : (isCurrentUser ? 50 : -50))
            .opacity(isAnimating ? 1 : 0)

            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    VStack(alignment: .leading, spacing: 10) {
        CommentRowView(
            comment: Comment(
                id: "1",
                threadId: "thread1",
                email: "user1@gmail.com",
                text: "This is my message",
                timestamp: Calendar.current.date(byAdding: .minute, value: -5, to: Date())!
            ),
            isCurrentUser: true
        )

        CommentRowView(
            comment: Comment(
                id: "2",
                threadId: "thread2",
                email: "user2@gmail.com",
                text: "This is someone else's message, sent a bit longer ago.",
                timestamp: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!
            ),
            isCurrentUser: false
        )
        CommentRowView(
            comment: Comment(
                id: "3",
                threadId: "thread2",
                email: "user2@gmail.com",
                text: "Yesterday's message.",
                timestamp: Calendar.current.date(byAdding: .day, value: -1, to: Date())!
            ),
            isCurrentUser: false
        )
    }
    .padding()
}
