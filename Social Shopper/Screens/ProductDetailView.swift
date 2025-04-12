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
    @State private var showShareSheet = false
    @State private var showComments = false
    @State private var paymentSuccess = false
    @State private var isAddingToCart = false
    @State private var validationError: AppError?

    init(product: Product) {
        self.product = product
    }

    private var shareItems: [Any] {
        var items: [Any] = [
            "Check out \(product.name) - \(product.formattedPrice)",
            URL(string: product.imageUrl)!
        ]

        if let productId = product.id,
           let deepLink = DeepLink.productURL(id: productId) {
            items.append(deepLink)
        }

        return items
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

                Text(product.name)
                    .font(.title)
                    .fontWeight(.bold)
                Text(product.description)
                    .font(.body)
                    .foregroundColor(.gray)

                Text("Price: \(product.formattedPrice)")
                    .font(.headline)
                    .fontWeight(.semibold)

                HStack {
                    Text("Quantity:")
                        .font(.headline)
                    Stepper("\(quantity)", value: $quantity, in: 1...10)
                }

                Button(action: {
                    Task {
                        await addToCart()
                    }
                }) {
                    Text("Add to Cart")
                        .frame(maxWidth: .infinity)
                }
                .primaryButton(isLoading: isAddingToCart)
                .disabled(isAddingToCart)

                Button(action: {
                    showComments = true
                }) {
                    HStack {
                        Image(systemName: "bubble.left")
                        Text("View Comments")
                    }
                    .frame(maxWidth: .infinity)
                }
                .secondaryButton()
            }
            .padding()
        }
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ActivityViewController(activityItems: shareItems)
        }
        .sheet(isPresented: $showComments) {
            CommentsView(product: product)
        }
        .alert("Success", isPresented: $paymentSuccess) {
            Button("OK", role: .cancel) { }
        } message: {
            Text("\(product.name) added to cart!")
        }
        .errorAlert(error: validationError ?? cartManager.error) {
            validationError = nil
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
    NavigationStack {
        ProductDetailView(product: .sample)
            .environment(CartManager.shared)
            .environment(UserManager.shared)
            .environment(ProductManager())
    }
}
