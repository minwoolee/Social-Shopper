//
//  AddProductView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//

import SwiftUI

struct AddProductView: View {
    @Environment(ProductManager.self) var productManager
    @Environment(\.presentationMode) var presentationMode
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var errorMessage: String?
    @State private var imageURL: String = ""
    @State private var category: String = ""

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Product Details")) {
                        TextField("Product Name", text: $name)
                        TextField("Description", text: $description)
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                        TextField("Image URL", text: $imageURL)
                        TextField("Category", text: $category)
                    }

                    if let errorMessage = errorMessage {
                        Section {
                            Text(errorMessage)
                                .foregroundColor(.red)
                        }
                    }

                }
                .navigationTitle("Add Product")
                .navigationBarItems(trailing: Button("Cancel") {
                    presentationMode.wrappedValue.dismiss()
                })
                Button(action: {
                    addProduct()
                }) {
                    Text("Add Product")
                }.buttonStyle(.borderedProminent)
            }
        }
    }

    private func addProduct() {
        // Validate input
        guard !name.isEmpty, !description.isEmpty, let price = Double(price), !imageURL.isEmpty, !category.isEmpty else {
            errorMessage = "Please fill in all fields correctly."
            return
        }

        let newProduct = Product(
            name: name,
            description: description,
            price: price,
            imageUrl: imageURL,
            category: category
        )
        productManager.addProduct(product: newProduct)

        // Dismiss the view
        presentationMode.wrappedValue.dismiss()
    }
}

#Preview {
    AddProductView()
        .environment(ProductManager())
}
