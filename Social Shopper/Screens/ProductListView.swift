//
//  ProductListView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import SwiftUI

struct ProductListView: View {
    @Environment(ProductManager.self) var productManager
    @Environment(UserManager.self) var userManager
    @State private var searchText = ""
    @State private var selectedCategory: String? = nil
    @State private var shouldShowLogoutSheet: Bool = false
    @State private var shouldShowAddProductView: Bool = false

    // Available categories (for the filter)
    let categories = ["All", "Electronics", "Clothing", "Home Goods", "Books"] // Added more categories

    var body: some View {
        NavigationStack {
            VStack {
                // Search Bar
                TextField("Search products", text: $searchText)
                    .padding(.horizontal)
                    .textFieldStyle(RoundedBorderTextFieldStyle())

                // Category Filter
                categoryFilterView

                // Product List
                if productManager.isLoading {
                    ProgressView() // Show loading indicator
                } else if let error = productManager.error {
                    Text("Error: \(error.localizedDescription)") // Show error message
                } else {
                    List {
                        ForEach(filteredProducts) { product in
                            NavigationLink(value: product) {
                                ProductRow(product: product)
                            }
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.inline)
            .task {
                productManager.loadProducts()
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(product: product)
            }
            .toolbar {
                Button(action: {
                    shouldShowAddProductView.toggle()
                }) {
                    Image(systemName: "plus")
                }
                .opacity(
                    userManager.user?.email == "minwoolee@gmail.com" ? 1 : 0
                )
                Button {
                    shouldShowLogoutSheet.toggle()
                } label: {
                    Image(systemName: "gear")
                }
            }
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                }
            }
            .fullScreenCover(isPresented: $shouldShowAddProductView) {
                AddProductView()
            }
            .actionSheet(isPresented: $shouldShowLogoutSheet) {
                .init(title: Text("Settings"), buttons: [
                    .default(Text("Sign out"), action: {
                        print("Signing out")
                        userManager.signOut()
                    }),
                    .cancel()
                ])
            }
        }
    }

    var categoryFilterView: some View {
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

#Preview {
    ProductListView()
        .environment(ProductManager())
        .environment(UserManager())
}
