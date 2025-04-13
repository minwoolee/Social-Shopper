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
    @State private var showNewThreadSheet = false
    @State private var selectedThread: Thread?
    @State private var paymentSuccess = false
    @State private var isAddingToCart = false
    @State private var validationError: AppError?
    @State private var commentManager: CommentManager
    @State private var newThreadTitle = ""

    init(product: Product) {
        self.product = product
        self.commentManager = CommentManager(productID: product.id ?? "")
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

                // Threads Section
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Discussion Threads")
                            .font(.headline)

                        Spacer()

                        Button(action: {
                            showNewThreadSheet = true
                        }) {
                            Label("New Thread", systemImage: "plus.bubble")
                        }
                        .disabled(userManager.user == nil)
                    }

                    if userManager.user == nil {
                        Text("Sign in to view and create discussion threads")
                            .foregroundColor(.secondary)
                    } else if commentManager.isLoading {
                        ProgressView()
                    } else if commentManager.threads.isEmpty {
                        Text("No threads available. Create one to start discussing!")
                            .foregroundColor(.secondary)
                    } else {
                        ForEach(commentManager.threads) { thread in
                            ThreadRow(thread: thread, currentUserEmail: userManager.user?.email)
                                .onTapGesture {
                                    selectedThread = thread
                                }
                        }
                    }
                }
                .padding(.top)
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
        .sheet(item: $selectedThread) { thread in
            CommentsView(thread: thread, commentManager: commentManager)
        }
        .sheet(isPresented: $showNewThreadSheet) {
            newThreadForm()
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

    fileprivate func newThreadForm() -> NavigationStack<NavigationPath, some View> {
        return NavigationStack {
            Form {
                Section {
                    TextField("Thread Title", text: $newThreadTitle)
                }
            }
            .navigationTitle("New Thread")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        showNewThreadSheet = false
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        Task {
                            guard let userId = userManager.user?.email else { return }
                            _ = try? await commentManager.createThread(
                                title: newThreadTitle,
                                userId: userId
                            )
                            showNewThreadSheet = false
                            newThreadTitle = ""
                        }
                    }
                    .disabled(newThreadTitle.isEmpty)
                }
            }
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
