//
//  ContentView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging
import FirebaseAnalytics
import UIKit
import Combine
import CoreGraphics

// MARK: - Firebase Configuration
// Don't forget to add GoogleService-Info.plist to your project.  This is a placeholder.
class FirebaseSetup {
    static func configure() {
        FirebaseApp.configure() // Initialize Firebase
        //  Initialize Firestore
        let db = Firestore.firestore()
        // Example:  Setting Firestore settings (optional)
        let settings = db.settings
        settings.isPersistenceEnabled = true // Enable offline persistence
        db.settings = settings

        // You might need to request notification permissions.  This is a basic example.
        //  For full implementation, handle errors and different authorization statuses.
        if let current = UNUserNotificationCenter.current(){
            current.requestAuthorization(options: [.alert, .sound]) { granted, error in
                if let error = error {
                    print("Error requesting notification authorization: \(error)")
                } else if granted {
                    print("Notification permissions granted.")
                    // Get the device token
                    UIApplication.shared.registerForRemoteNotifications()
                }
            }
        }
    }
}

// MARK: - Models

// Product Model
struct Product: Identifiable, Codable, Equatable {
    @DocumentID var id: String?
    var name: String
    var description: String
    var price: Double
    var imageUrl: String
    var category: String  // Added category for filtering

    // Example of a computed property.
    var formattedPrice: String {
        String(format: "$%.2f", price)
    }

    // Equatable conformance (for more efficient comparison) - useful for SwiftUI
      static func == (lhs: Product, rhs: Product) -> Bool {
          return lhs.id == rhs.id
      }

    //  Added CodingKeys for clarity and maintainability, especially if your property
     //  names differ from your Firestore field names.
    enum CodingKeys: String, CodingKey {
        case id
        case name
        case description
        case price
        case imageUrl
        case category
    }

     // Custom initializer to handle decoding
     init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        // Firestore may not always include the 'id' in the payload when retrieving
        // documents.  We handle this more robustly.  If the ID exists, decode it;
        // otherwise, leave it nil.  The @DocumentID property wrapper should then
        // populate the ID when the document is retrieved.
        id = try? container.decodeIfPresent(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        price = try container.decode(Double.self, forKey: .price)
        imageUrl = try container.decode(String.self, forKey: .imageUrl)
        category = try container.decode(String.self, forKey: .category)
    }

    // Added an empty initializer
    init(id: String? = nil, name: String, description: String, price: Double, imageUrl: String, category: String) {
        self.id = id
        self.name = name
        self.description = description
        self.price = price
        self.imageUrl = imageUrl
        self.category = category
    }
}

// Cart Item Model
struct CartItem: Identifiable, Codable {
    var id = UUID()
    var product: Product
    var quantity: Int
}

// Comment Model
struct Comment: Identifiable, Codable {
    @DocumentID var id: String?
    var text: String
    var userId: String  //  Consider storing a user ID, not the whole user object.
    var timestamp: Date
    var userDisplayName: String // Added display name

    // Added CodingKeys for clarity
    enum CodingKeys: String, CodingKey {
        case id
        case text
        case userId
        case timestamp
        case userDisplayName
    }

     // Custom initializer
    init(id: String? = nil, text: String, userId: String, timestamp: Date, userDisplayName: String) {
        self.id = id
        self.text = text
        self.userId = userId
        self.timestamp = timestamp
        self.userDisplayName = userDisplayName
    }
}

// User Model (Simplified for this example)
struct User: Identifiable, Codable {
    var id: String
    var displayName: String
    // Add other user properties as needed (e.g., email, profileImageUrl)
}

// MARK: - Data Managers

// Product Manager
class ProductManager: ObservableObject {
    @Published var products: [Product] = []
    @Published var isLoading = false
    @Published var error: Error?

    private var db = Firestore.firestore()
    private var listener: ListenerRegistration? // To store the listener

    // Load products from Firestore
    func loadProducts() {
        isLoading = true
        error = nil

        // Remove any existing listener before setting up a new one
        listener?.remove()

        listener = db.collection("products").addSnapshotListener { (querySnapshot, error) in
            self.isLoading = false
            if let error = error {
                self.error = error
                print("Error getting products: \(error.localizedDescription)") // Log the error
                return
            } else {
                self.products = querySnapshot?.documents.compactMap { document in
                    try? document.data(as: Product.self)
                } ?? []
            }
        }
    }

    // Add a new product to Firestore
    func addProduct(product: Product) {
        do {
            _ = try db.collection("products").addDocument(from: product)
        } catch {
            self.error = error
            print("Error adding product: \(error.localizedDescription)")
        }
    }

    // Get a single product by ID.
    func getProduct(by id: String) -> Product? {
        products.first { $0.id == id }
    }

    // Deinit to remove listener
     deinit {
         listener?.remove() // Clean up the listener when the manager is deallocated
     }
}

// Cart Manager
class CartManager: ObservableObject {
    @Published var items: [CartItem] = []
    @Published var paymentSuccess = false // Added state for payment confirmation

    private let cartKey = "cartItems" // Consistent key for UserDefaults

    init() {
        loadCart()
    }

    // Add item to cart
    func addItem(product: Product, quantity: Int = 1) {
        if let index = items.firstIndex(where: { $0.product.id == product.id }) {
            items[index].quantity += quantity
        } else {
            items.append(CartItem(product: product, quantity: quantity))
        }
        saveCart()
    }

    // Remove item from cart
    func removeItem(item: CartItem) {
        items.removeAll { $0.id == item.id }
        saveCart()
    }

    // Get total price of items in cart
      func getTotalPrice() -> Double {
          return items.reduce(0) { total, item in
              total + (item.product.price * Double(item.quantity))
          }
      }

    func clearCart() {
        items.removeAll()
        saveCart()
        paymentSuccess = true // Set the flag
    }

    // Save cart to UserDefaults
    private func saveCart() {
        do {
            let encoded = try JSONEncoder().encode(items)
            UserDefaults.standard.set(encoded, forKey: cartKey)
        } catch {
            print("Error encoding cart: \(error.localizedDescription)")
            // Consider showing an alert to the user in a real app.
        }
    }

    // Load cart from UserDefaults
    private func loadCart() {
        guard let data = UserDefaults.standard.data(forKey: cartKey) else { return }
        do {
            let decoded = try JSONDecoder().decode([CartItem].self, from: data)
            items = decoded
        } catch {
            print("Error decoding cart: \(error.localizedDescription)")
            // Consider showing an alert to the user in a real app.
        }
    }
}

// Comment Manager
class CommentManager: ObservableObject {
    @Published var comments: [Comment] = []
    @Published var isLoading = false
    @Published var error: Error?

    private var db = Firestore.firestore()
    private var productID: String // Store the product ID to fetch comments for the correct product
    private var listener: ListenerRegistration?

    init(productID: String) {
        self.productID = productID
        loadComments()
    }

    // Load comments for a specific product
    func loadComments() {
        isLoading = true
        error = nil

        // Remove any existing listener
        listener?.remove()

        // Query for comments for the specific product, ordered by timestamp
        listener = db.collection("products").document(productID).collection("comments")
            .order(by: "timestamp", descending: false) // Order by timestamp
            .addSnapshotListener { (querySnapshot, error) in
                self.isLoading = false
                if let error = error {
                    self.error = error
                    print("Error getting comments: \(error.localizedDescription)")
                    return
                } else {
                    self.comments = querySnapshot?.documents.compactMap { document in
                        try? document.data(as: Comment.self)
                    } ?? []
                }
            }
    }

    // Add a comment for a specific product
    func addComment(text: String, userId: String, userDisplayName: String) {
        let newComment = Comment(text: text, userId: userId, timestamp: Date(), userDisplayName: userDisplayName)
        do {
            _ = try db.collection("products").document(productID).collection("comments").addDocument(from: newComment)
            // No need to call loadComments() after adding. The snapshot listener will automatically update the list.
        } catch {
            self.error = error
            print("Error adding comment: \(error.localizedDescription)")
        }
    }

     deinit {
        listener?.remove()
    }
}

// MARK: - Views

// Product List View
struct ProductListView: View {
    @ObservedObject var productManager: ProductManager
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil // Added state for selected category

    // Available categories (for the filter)
    let categories = ["All", "Electronics", "Clothing", "Home Goods", "Books"] // Added more categories

    var body: some View {
        NavigationView {
            VStack {
                // Search Bar
                TextField("Search products", text: $searchText)
                    .padding(.horizontal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Category Filter
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = (category == "All") ? nil : category // nil for "All"
                            }) {
                                Text(category)
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        // Background color changes based on selection
                                        selectedCategory == (category == "All" ? nil : category) ? Color.blue : Color.gray.opacity(0.2)
                                    )
                                    .foregroundColor(
                                        // Text color changes based on selection
                                        selectedCategory == (category == "All" ? nil : category) ? .white : .blue
                                    )
                                    .cornerRadius(8)
                            }
                        }
                    }
                    .padding(.horizontal)
                }

                // Product List
                if productManager.isLoading {
                    ProgressView() // Show loading indicator
                } else if let error = productManager.error {
                    Text("Error: \(error.localizedDescription)") // Show error message
                } else {
                    List {
                        ForEach(filteredProducts) { product in
                            NavigationLink(destination: ProductDetailView(product: product, productManager: productManager)) {
                                ProductRow(product: product)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Products")
            .onAppear {
                productManager.loadProducts() // Load products when the view appears
            }
        }
    }

    // Computed property for filtered products
    var filteredProducts: [Product] {
        let filteredByCategory: [Product]
        if let selectedCategory = selectedCategory {
            filteredByCategory = productManager.products.filter { $0.category == selectedCategory }
        } else {
            filteredByCategory = productManager.products
        }

        if searchText.isEmpty {
            return filteredByCategory
        } else {
            return filteredByCategory.filter { $0.name.localizedCaseInsensitiveContains(searchText) }
        }
    }
}

// Product Row (for the list)
struct ProductRow: View {
    var product: Product

    var body: some View {
        HStack {
            // Use AsyncImage to load images from URLs
            AsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo") // Placeholder
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo") // Error indicator
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(product.formattedPrice)
                    .font(.callout)
                    .fontWeight(.bold)
            }
        }
    }
}

// Product Detail View
struct ProductDetailView: View {
    var product: Product
    @EnvironmentObject var cartManager: CartManager
    @State private var quantity = 1
    @State private var commentText = ""
    @ObservedObject var commentManager: CommentManager // Use ObservedObject
    @State private var user: User? // Hold the current user.
    @State private var showShareSheet = false // State for showing share sheet
     @State private var paymentSuccess = false

    // Use the product ID to initialize the comment manager.  This is crucial.
    init(product: Product, productManager: ProductManager) {
        self.product = product
        _commentManager = StateObservedObject(wrappedValue: CommentManager(productID: product.id ?? ""))
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
                        Alert(title: Text("Success"), message: Text("\(product.name) added to cart!"), dismissButton: .default(Text("OK")){
                            paymentSuccess = false
                        })
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

// Comment Row View
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

// Cart View
struct CartView: View {
    @EnvironmentObject var cartManager: CartManager
     @State private var paymentSuccess = false

    var body: some View {
        NavigationView {
            VStack {
                if cartManager.items.isEmpty {
                    Text("Your cart is empty.")
                        .padding()
                } else {
                    List {
                        ForEach(cartManager.items) { item in
                            CartItemRow(item: item)
                        }
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.2f", cartManager.getTotalPrice()))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical)
                    }
                    .listStyle(PlainListStyle())

                    Button(action: {
                        // In a real app, you would integrate with a payment gateway (e.g., Stripe, Apple Pay).
                        // For this example, we'll just simulate a successful payment.
                        cartManager.clearCart()
                        paymentSuccess = true

                    }) {
                        Text("Checkout")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                    .alert(isPresented: $paymentSuccess) {
                        Alert(title: Text("Payment Successful"), message: Text("Thank you for your purchase!"), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .navigationTitle("Cart")
        }
    }
}

// Cart Item Row
struct CartItemRow: View {
    var item: CartItem
    @EnvironmentObject var cartManager: CartManager

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: item.product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo")
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo")
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading) {
                Text(item.product.name)
                    .font(.headline)
                Text("Quantity: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(item.product.formattedPrice)
                    .font(.callout)
                    .fontWeight(.bold)
            }
            Spacer()
            Button(action: {
                cartManager.removeItem(item: item)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

// Activity View Controller (for sharing)
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

// Main App
@main
struct ECommerceApp: App {
    // Register the app delegate for handling remote notifications
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @StateObject var productManager = ProductManager()
    @StateObject var cartManager = CartManager()

    var body: some Scene {
        WindowGroup {
            TabView {
                ProductListView(productManager: productManager)
                    .tabItem {
                        Image(systemName: "list.bullet.below.rectangle")
                        Text("Products")
                    }

                CartView()
                    .tabItem {
                        Image(systemName: "cart.fill")
                        Text("Cart")
                    }
            }
            .environmentObject(cartManager)
        }
    }
}

// MARK: - App Delegate for Notifications
class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        // Configure Firebase
        FirebaseSetup.configure()

        // Set the delegate for the user notification center.  This is important for handling notifications.
         UNUserNotificationCenter.current().delegate = self

        return true
    }

    // Handle device token registration
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        // Convert the device token to a string
        let tokenString = deviceToken.map { String(format: "%02.2hhx", $0) }.joined()
        print("Device Token: \(tokenString)")

        // You should send this token to your server (Firebase) to associate it with the user.
        //  For example:
        //  Firestore.firestore().collection("users").document(userUID).updateData(["fcmToken": tokenString])
    }

    // Handle device token registration failure
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Failed to register for remote notifications: \(error.localizedDescription)")
    }

     // Handle receiving remote notifications while the app is in the foreground
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Customize how the notification is presented when the app is running in the foreground
        completionHandler([.alert, .sound, .badge]) // Show alert, play sound, and update badge
    }

    // Handle when the user taps on a notification
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo

        // Handle the data in the notification
        if let message = userInfo["message"] as? String {
            print("Message from notification: \(message)")
            //  Here, you could navigate the user to a specific part of the app,
            //  depending on the content of the notification.
        }

        completionHandler()
    }
}

// Extension for handling errors more cleanly.
extension Error {
    var localizedDescription: String {
        (self as NSError).localizedDescription
    }
}

