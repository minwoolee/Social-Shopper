import SwiftUI

struct CommentRow: View {
    let comment: Comment
    let isCurrentUser: Bool
    @State private var isAnimating = false
    
    var body: some View {
        HStack {
            if isCurrentUser {
                Spacer()
            }
            
            VStack(alignment: isCurrentUser ? .trailing : .leading, spacing: 4) {
                Text(comment.userId)
                    .font(.caption)
                    .foregroundColor(.gray)
                
                Text(comment.text)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 8)
                    .background(isCurrentUser ? Color.blue.opacity(0.2) : Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .offset(x: isAnimating ? 0 : (isCurrentUser ? 50 : -50))
            .opacity(isAnimating ? 1 : 0)
            
            if !isCurrentUser {
                Spacer()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 4)
        .onAppear {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    VStack {
        CommentRow(
            comment: Comment(
                id: "1",
                text: "This is my message",
                userId: "user1",
                timestamp: Date()
            ),
            isCurrentUser: true
        )
        
        CommentRow(
            comment: Comment(
                id: "2",
                text: "This is someone else's message",
                userId: "user2",
                timestamp: Date()
            ),
            isCurrentUser: false
        )
    }
}
