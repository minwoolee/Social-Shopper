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

    @State private var productManager: ProductManager
    @State private var cartManager: CartManager
    @State private var userManager: UserManager

    @State private var deepLinkDestination: DeepLinkDestination?
    @State private var deepLinkProductId: String?
    @State private var deepLinkThreadId: String?

    @State private var showAddProductView: Bool = false
    @State private var showError = false

    init() {
        FirebaseSetup.configure()
        productManager = ProductManager()
        cartManager = CartManager.shared
        userManager = UserManager.shared
    }

    var body: some Scene {
        WindowGroup {
            if userManager.isSignedIn {
                MainView(deepLinkProductId: $deepLinkProductId, deepLinkThreadId: $deepLinkThreadId)
                    .environment(productManager)
                    .environment(cartManager)
                    .environment(userManager)
                    .onOpenURL { url in
                        if let destination = DeepLink.handleURL(url) {
                            switch destination {
                            case .product(let id):
                                deepLinkProductId = id
                            case .thread(let productId, let threadId):
                                deepLinkProductId = productId
                                deepLinkThreadId = threadId
                            }
                        }
                    }
                    .alert("Error", isPresented: $showError) {
                        Button("OK", role: .cancel) { }
                    } message: {
                        Text("Failed to load content")
                    }
            } else {
                LoginView()
                    .environment(userManager)
            }
        }
    }
}

// MARK: - Firebase Configuration
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
