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
    @State private var selectedCategory: Category?
    @State private var shouldShowLogoutSheet: Bool = false
    @State private var shouldShowAddProductView: Bool = false

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
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
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
            .onAppear {
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
            .errorAlert(error: productManager.error) {
                productManager.error = nil
            }
        }
    }

    var categoryFilterView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(Category.allCases, id: \.self) { category in
                    Button(action: {
                        selectedCategory = category
                    }) {
                        Text(category.rawValue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                // Background color changes based on selection
                                selectedCategory == category ? Color.blue : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(
                                // Text color changes based on selection
                                selectedCategory == category ? .white : .blue
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
