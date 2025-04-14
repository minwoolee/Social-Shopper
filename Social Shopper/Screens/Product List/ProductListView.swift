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
    @Environment(\.scenePhase) private var scenePhase

    @Binding var deepLinkProductId: String?
    @Binding var deepLinkThreadId: String?
    @Binding var navigationPath: NavigationPath

    @State private var searchText = ""
    @State private var selectedCategory: Category?
    @State private var shouldShowLogoutSheet: Bool = false
    @State private var shouldShowAddProductView: Bool = false
    @State private var shouldShowError: Bool = false

    var body: some View {
        NavigationStack(path: $navigationPath) {
            VStack {
                // Category Filter
                categoryFilterView

                // Product List
                if productManager.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    List(filteredProducts) { product in
                        NavigationLink(value: product) {
                            ProductRowView(product: product)
                        }
                    }
                    .listStyle(PlainListStyle())
                }
            }
            .navigationTitle("Products")
            .navigationBarTitleDisplayMode(.inline)
            .searchable(
                text: $searchText,
                prompt: "Search products",
            )
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .active {
                    productManager.loadProducts()
                }
            }
            .onAppear {
                productManager.loadProducts()
            }
            .navigationDestination(for: Product.self) { product in
                ProductDetailView(
                    product: product,
                    deepLinkThreadId: $deepLinkThreadId
                )
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
            .fullScreenCover(isPresented: $shouldShowAddProductView) {
                AddProductView()
            }
            .actionSheet(isPresented: $shouldShowLogoutSheet) {
                .init(title: Text(UserManager.shared.user?.email ?? ""), buttons: [
                    .default(Text("Sign out"), action: {
                        print("Signing out")
                        userManager.signOut()
                    }),
                    .cancel()
                ])
            }
            .onChange(of: deepLinkProductId) { _, _ in
                Task {
                    if let id = deepLinkProductId,
                       let product = await productManager.getProduct(by: id) {
                        navigationPath.append(product)
                        deepLinkProductId = nil
                    }
                }
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
                        if selectedCategory == nil || selectedCategory != category {
                            selectedCategory = category
                        } else {
                            selectedCategory = nil
                        }
                    }) {
                        Text(category.rawValue)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 8)
                            .background(
                                selectedCategory == category ? Color.blue : Color.gray.opacity(0.2)
                            )
                            .foregroundColor(
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
    ProductListView(
        deepLinkProductId: .constant(nil),
        deepLinkThreadId: .constant(nil),
        navigationPath: .constant(NavigationPath())
    )
    .environment(ProductManager())
    .environment(UserManager.shared)
}
