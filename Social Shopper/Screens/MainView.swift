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

            ProductListView(
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
