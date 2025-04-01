//
//  ProductDetailView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import SwiftUI

struct ProductDetailView: View {
    var product: Product
    @Environment(CartManager.self) var cartManager
    @State private var quantity = 1
    @State private var commentText = ""
    @State var commentManager: CommentManager // Use ObservedObject
    @State private var user: User? // Hold the current user.
    @State private var showShareSheet = false // State for showing share sheet
    @State private var paymentSuccess = false

    // Use the product ID to initialize the comment manager.  This is crucial.
    init(product: Product, productManager: ProductManager) {
        self.product = product
        commentManager = CommentManager(productID: product.id ?? "")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Product Image
                AsyncImage(url: URL(string: product.imageUrl)) { phase in
                    switch phase {
                    case .empty:
                        ProgressView() // Show loading indicator
                            .frame(height: 200)
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
                    case .failure:
                        Image(systemName: "photo") // Error indicator
                            .frame(height: 200)
                            .clipShape(RoundedRectangle(cornerRadius: 10))
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
                    Stepper("\(quantity)", value: $quantity, in: 1...10) // Limit quantity
                }

                // Add to Cart Button
                Button(action: {
                    cartManager.addItem(product: product, quantity: quantity)
                     paymentSuccess = true
                }) {
                    Text("Add to Cart")
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .padding(.vertical)
                 .alert(isPresented: $paymentSuccess) {
                        Alert(title: Text("Success"), message: Text("\(product.name) added to cart!"), dismissButton: .default(Text("OK")))
                }

                // Share Button
                Button(action: {
                    showShareSheet = true
                }) {
                    Text("Share")
                        .padding()
                        .background(Color.green)
                        .foregroundColor(.white)
                        .cornerRadius(8)
                }
                .sheet(isPresented: $showShareSheet) {
                    // Use UIActivityViewController for sharing
                    ActivityViewController(activityItems: [product.name, product.description, URL(string: product.imageUrl)!], applicationActivities: nil)
                }

                // Live Comments Section
                Text("Live Comments")
                    .font(.title2)
                    .fontWeight(.semibold)

                // Comments List
                if commentManager.isLoading {
                    ProgressView() // Show loading indicator
                } else if let error = commentManager.error {
                    Text("Error: \(error.localizedDescription)") // Show error
                }
                else {
                    ForEach(commentManager.comments) { comment in
                        CommentRow(comment: comment)
                    }
                }

                // Comment Input
                HStack {
                    TextField("Add a comment...", text: $commentText)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                    Button(action: {
                        if !commentText.isEmpty, let user = user {
                            commentManager.addComment(text: commentText, userId: user.id, userDisplayName: user.displayName)
                            commentText = "" // Clear the input field
                        }
                    }) {
                        Text("Post")
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .disabled(commentText.isEmpty || user == nil) // Disable if text is empty or no user
                }
                .padding(.vertical)

                // Display a message if the user is not logged in.
                if user == nil {
                    Text("Please log in to post comments.")
                        .foregroundColor(.red)
                        .font(.caption)
                }

            }
            .padding()
        }
        .onAppear {
            // Simulate fetching the user.  In a real app, you'd get this from your auth system.
            //  For this example, we'll create a dummy user.
            user = User(id: "user123", displayName: "Test User")
            commentManager.loadComments()
        }
    }
}

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
