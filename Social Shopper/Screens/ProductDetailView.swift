//
//  ProductDetailView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import SwiftUI
import CachedAsyncImage

struct ProductDetailView: View {
    var product: Product
    @Environment(CartManager.self) var cartManager
    @Environment(ProductManager.self) var productManager
    @Environment(UserManager.self) var userManager
    @State private var quantity = 1
    @State private var commentText = ""
    @State var commentManager: CommentManager
    @State private var showShareSheet = false
    @State private var paymentSuccess = false
    @State private var isAddingToCart = false
    @State private var isPostingComment = false
    @State private var validationError: AppError?

    init(product: Product) {
        self.product = product
        commentManager = CommentManager(productID: product.id ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                CachedAsyncImage(url: URL(string: product.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    case .failure:
                        Image(systemName: "photo")
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                            .overlay(
                                Text("Failed to load image")
                                    .foregroundColor(.red)
                                    .padding()
                            )
                    @unknown default:
                        EmptyView()
                    }
                }

                // Product Name and Description
                Text(product.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(product.description)
                    .font(.body)
                    .foregroundColor(.gray)

                // Product Price
                Text("Price: \(product.formattedPrice)")
                    .font(.headline)
                    .fontWeight(.semibold)

                // Quantity Picker
                HStack {
                    Text("Quantity:")
                        .font(.headline)
                    Stepper("\(quantity)", value: $quantity, in: 1...10)
                }

                // Add to Cart Button
                Button(action: {
                    Task {
                        await addToCart()
                    }
                }) {
                    Text("Add to Cart")
                }
                .primaryButton(isLoading: isAddingToCart)
                .disabled(isAddingToCart)
                .padding(.vertical)

                // Share Button
                Button(action: {
                    showShareSheet = true
                }) {
                    Text("Share")
                }
                .secondaryButton()
                .padding(.vertical)

                // Live Comments Section
                Text("Live Comments")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Comments List
                if commentManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                } else {
                    ForEach(commentManager.comments) { comment in
                        CommentRow(comment: comment)
                    }
                }

                // Comment Input
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        Task {
                            await postComment()
                        }
                    }) {
                        Text("Post")
                    }
                    .primaryButton(isLoading: isPostingComment)
                    .disabled(commentText.isEmpty || userManager.user == nil || isPostingComment)
                }
                .padding(.vertical)

                if userManager.user == nil {
                    Text("Please log in to post comments.")
                        .foregroundColor(.red)
                        .font(.caption)
                }
            }
            .padding()
        }
        .onAppear {
            commentManager.loadComments()
        }
        .alert("Success", isPresented: $paymentSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(product.name) added to cart!")
        }
        .errorAlert(
            error: (
                validationError ?? commentManager.error ?? cartManager.error
            ) as? AppError
        ) {
            validationError = nil
            commentManager.error = nil
            cartManager.error = nil
        }
    }

    private func addToCart() async {
        isAddingToCart = true
        defer { isAddingToCart = false }

        do {
            try await cartManager.addItem(product: product, quantity: quantity)
            paymentSuccess = true
        } catch {
            validationError = .validationError("Failed to add item to cart: \(error.localizedDescription)")
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

struct ActivityViewController: UIViewControllerRepresentable {
    var activityItems: [Any]
    var applicationActivities: [UIActivity]? = nil

    func makeUIViewController(context: Context) -> UIActivityViewController {
        let activityViewController = UIActivityViewController(activityItems: activityItems, applicationActivities: applicationActivities)
        return activityViewController
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {
        // Update the view controller if needed.  In this case, nothing to update.
    }
}

#Preview {
    ProductDetailView(product: .sample)
        .environment(CartManager.shared)
        .environment(ProductManager())
}
