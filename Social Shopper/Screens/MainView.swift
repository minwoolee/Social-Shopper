//
//  MainView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//

import SwiftUI

struct MainView: View {
    @Binding var deepLinkProductId: String?
    @State private var selectedTab = 0
    @State private var navigationPath = NavigationPath()
    @Environment(ProductManager.self) private var productManager

    var body: some View {
        TabView(selection: $selectedTab) {
            ProductNavigationView(
                deepLinkProductId: $deepLinkProductId,
                navigationPath: $navigationPath
            )
            .tabItem {
                Label("Products", systemImage: "list.bullet")
            }
            .tag(0)

            CartView()
                .tabItem {
                    Label("Cart", systemImage: "cart")
                }
                .tag(1)
        }
        .onChange(of: deepLinkProductId) { _, newValue in
            if newValue != nil {
                selectedTab = 0
            }
        }
    }
}

struct ProductNavigationView: View {
    @Binding var deepLinkProductId: String?
    @Binding var navigationPath: NavigationPath
    @Environment(ProductManager.self) private var productManager

    var body: some View {
        NavigationStack(path: $navigationPath) {
            ProductListView()
                .navigationDestination(for: Product.self) { product in
                    ProductDetailView(product: product)
                }
                .onChange(of: deepLinkProductId) { _, _ in
                    if let id = deepLinkProductId {
                        if productManager.products.contains(where: { $0.id == id }) {
                            navigationPath.append(productManager.getProduct(by: id)!)
                        }
                        deepLinkProductId = nil
                    }
                }
        }
    }
}
