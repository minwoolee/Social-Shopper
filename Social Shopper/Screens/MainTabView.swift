//
//  MainView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//

import SwiftUI

struct MainTabView: View {
    @Binding var deepLinkProductId: String?
    @Binding var deepLinkThreadId: String?

    @Environment(ProductManager.self) private var productManager

    @State private var selectedTab = 0
    @State private var navigationPath = NavigationPath()

    var body: some View {

        TabView(selection: $selectedTab) {

            ProductListView(
                deepLinkProductId: $deepLinkProductId,
                deepLinkThreadId: $deepLinkThreadId,
                navigationPath: $navigationPath
            )
            .task {
                if let id = deepLinkProductId {
                    let product = await productManager.getProduct(by: id)
                    navigationPath.append(product)
                    deepLinkProductId = nil
                }
            }
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
