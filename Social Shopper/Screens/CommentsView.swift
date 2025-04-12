import SwiftUI

struct CommentsView: View {
    let product: Product
    @Environment(UserManager.self) private var userManager
    @State private var commentText = ""
    @State private var isPostingComment = false
    @State var commentManager: CommentManager
    @Environment(\.dismiss) private var dismiss

    init(product: Product) {
        self.product = product
        self._commentManager = State(initialValue: CommentManager(productID: product.id ?? ""))
    }

    var body: some View {
        NavigationStack {
            VStack {
                ScrollViewReader { proxy in
                    List {
                        if commentManager.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                        } else {
                            ForEach(commentManager.comments) { comment in
                                CommentRow(comment: comment, isCurrentUser: comment.userId == userManager.user?.email)
                                    .id(comment.id)
                            }
                            // Invisible marker view at the bottom
                            Color.clear
                                .frame(height: 1)
                                .id("bottom")
                        }
                    }
                    .onChange(of: commentManager.comments.count) { _, _ in
                        withAnimation {
                            proxy.scrollTo("bottom", anchor: .bottom)
                        }
                    }
                }

                // Comment Input
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
                .padding()

                if userManager.user == nil {
                    Text("Please log in to post comments.")
                        .foregroundColor(.red)
                        .font(.caption)
                        .padding(.bottom)
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                }
            }
        }
        .onAppear {
            commentManager.loadComments()
        }
    }

    private func postComment() async {
        guard !commentText.isEmpty, let user = userManager.user else { return }

        isPostingComment = true
        defer { isPostingComment = false }

        commentManager.addComment(
            text: commentText.trimmingCharacters(in: .whitespacesAndNewlines),
            userId: user.email!,
            userDisplayName: user.email!
        )
        commentText = ""
    }
}
