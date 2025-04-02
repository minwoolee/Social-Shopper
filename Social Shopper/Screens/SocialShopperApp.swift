//
//  Social_ShopperApp.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//

import SwiftUI
import FirebaseCore
import FirebaseFirestore

// Main App
@main
struct SocialShopperApp: App {

    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    @State var productManager: ProductManager
    @State var cartManager: CartManager

    init() {
        FirebaseSetup.configure()
        productManager = ProductManager()
        cartManager = CartManager()
    }

    var body: some Scene {
        WindowGroup {
            TabView {
                ProductListView()
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
            .environment(cartManager)
            .environment(productManager)
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
