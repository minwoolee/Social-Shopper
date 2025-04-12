//
//  Social_ShopperApp.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseAuth

// Main App
@main
struct SocialShopperApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State private var deepLinkDestination: DeepLinkDestination?
    @State private var productManager: ProductManager
    @State private var deepLinkProductId: String?
    @State private var showAddProductView: Bool = false
    @State private var showError = false
    @State var cartManager: CartManager
    @State var userManager: UserManager

    init() {
        FirebaseSetup.configure()
        productManager = ProductManager()
        cartManager = CartManager.shared
        userManager = UserManager.shared
    }

    var body: some Scene {
        WindowGroup {
            if userManager.isSignedIn {
                MainView(deepLinkProductId: $deepLinkProductId)
                    .environment(productManager)
                    .environment(cartManager)
                    .environment(userManager)
                    .onOpenURL { url in
                        if let destination = DeepLink.handleURL(url),
                           case .product(let id) = destination {
                            deepLinkProductId = id
                        }
                    }
                    .alert("Error", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Failed to load the product")
                    }
            } else {
                LoginView()
                    .environment(userManager)
            }
        }
    }
}



final class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        return true
    }
}

// MARK: - Firebase Configuration
// Don't forget to add GoogleService-Info.plist to your project.  This is a placeholder.
class FirebaseSetup {
    static func configure() {
        FirebaseApp.configure() // Initialize Firebase
        //  Initialize Firestore
        let db = Firestore.firestore()
        // Example:  Setting Firestore settings (optional)
        let settings = db.settings
        settings.cacheSettings = PersistentCacheSettings()
        db.settings = settings
    }
}

// Add LoadingProductView to handle async product loading
struct LoadingProductView<Content: View>: View {
    let productId: String
    let content: (Product) -> Content

    @Environment(ProductManager.self) private var productManager
    @Environment(\.dismiss) private var dismiss
    @State private var product: Product?
    @State private var error: Error?

    init(productId: String, @ViewBuilder content: @escaping (Product) -> Content) {
        self.productId = productId
        self.content = content
    }

    var body: some View {
        Group {
            if let product {
                content(product)
            } else {
                ProgressView("Loading product...")
            }
        }
        .task {
            do {
                product = try await productManager.loadProduct(by: productId)
            } catch {
                self.error = error
                dismiss()
            }
        }
    }
}

// Make DeepLinkDestination conform to Identifiable
extension DeepLinkDestination: Identifiable {
    var id: String {
        switch self {
        case .product(let id):
            return "product_\(id)"
        }
    }
}
