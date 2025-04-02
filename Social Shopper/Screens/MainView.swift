//
//  MainView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//
import SwiftUI

struct MainView: View {

    var body: some View {
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

    }
}


#Preview {
    MainView()
}
