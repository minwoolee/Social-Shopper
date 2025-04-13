import SwiftUI

struct CommentsView: View {
    let thread: Thread
    @Environment(UserManager.self) private var userManager
    @State private var commentText = ""
    @State private var isPostingComment = false
    @State private var showShareSheet = false
    @Environment(\.dismiss) private var dismiss
    @State var commentManager: CommentManager

    init(thread: Thread, commentManager: CommentManager) {
        self.thread = thread
        self.commentManager = commentManager
    }

    var body: some View {
        NavigationStack {
            CommentsContent(
                thread: thread,
                commentText: $commentText,
                isPostingComment: $isPostingComment,
                showShareSheet: $showShareSheet,
                commentManager: commentManager,
                postComment: postComment
            )
        }
        .onAppear {
            commentManager.loadComments(for: thread.id ?? "")
        }
    }

    private func postComment() async {
        guard let userId = userManager.user?.email,
              let threadId = thread.id,
              !commentText.isEmpty else { return }

        isPostingComment = true
        defer { isPostingComment = false }

        do {
            try await commentManager.addComment(
                text: commentText.trimmingCharacters(in: .whitespacesAndNewlines),
                userId: userId,
                threadId: threadId
            )
            commentText = ""
        } catch {
            print("Failed to post comment: \(error)")
        }
    }
}

private struct CommentsContent: View {
    let thread: Thread
    @Binding var commentText: String
    @Binding var isPostingComment: Bool
    @Binding var showShareSheet: Bool
    let commentManager: CommentManager
    let postComment: () async -> Void
    @Environment(UserManager.self) private var userManager
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack {
            CommentsList(
                thread: thread,
                comments: commentManager.comments[thread.id ?? ""] ?? []
            )

            CommentInputField(
                commentText: $commentText,
                isPostingComment: isPostingComment,
                userManager: userManager,
                postComment: postComment
            )
            .padding()
        }
        .navigationTitle(thread.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Button("Done") {
                    dismiss()
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            if let url = DeepLink.threadURL(productId: thread.productId, threadId: thread.id ?? "") {
                ActivityViewController(activityItems: [
                    "Join this discussion thread!",
                    url
                ])
            }
        }
    }
}

private struct CommentsList: View {
    let thread: Thread
    let comments: [Comment]
    @Environment(UserManager.self) private var userManager

    var body: some View {
        ScrollViewReader { proxy in
            List {
                if comments.isEmpty && thread.id != nil {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    ForEach(comments) { comment in
                        CommentRow(comment: comment, isCurrentUser: comment.userId == userManager.user?.email)
                            .id(comment.id)
                    }
                    Color.clear
                        .frame(height: 1)
                        .id("bottom")
                }
            }
            .onChange(of: comments.count) { _, _ in
                withAnimation {
                    proxy.scrollTo("bottom", anchor: .bottom)
                }
            }
        }
    }
}

private struct CommentInputField: View {
    @Binding var commentText: String
    let isPostingComment: Bool
    let userManager: UserManager
    let postComment: () async -> Void

    var body: some View {
        HStack {
            TextField("Add a comment...", text: $commentText)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .disabled(userManager.user == nil)

            Button(action: {
                Task {
                    await postComment()
                }
            }) {
                Image(systemName: "paperplane.fill")
            }
            .iconButton()
            .disabled(commentText.isEmpty || userManager.user == nil || isPostingComment)
        }

        if userManager.user == nil {
            Text("Please log in to post comments.")
                .foregroundColor(.red)
                .font(.caption)
                .padding(.bottom)
        }
    }
}

struct ThreadRow: View {
    let thread: Thread
    let currentUserEmail: String?

    private var isCreator: Bool {
        currentUserEmail == thread.creatorId
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(thread.title)
                    .font(.headline)
                Spacer()
                if isCreator {
                    Text("Created by you")
                        .font(.caption)
                        .foregroundColor(.blue)
                } else {
                    Text("Participant")
                        .font(.caption)
                        .foregroundColor(.green)
                }
            }
            Text(thread.formattedDate)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color.secondary.opacity(0.1))
        .cornerRadius(8)
    }
}
