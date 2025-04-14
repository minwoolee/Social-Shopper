//
//  AddProductView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//

import SwiftUI

struct AddProductView: View {
    @Environment(ProductManager.self) var productManager
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""
    @State private var description: String = ""
    @State private var price: String = ""
    @State private var imageURL: String = ""
    @State private var category: Category?
    @State private var validationError: AppError?
    @State private var isSubmitting = false

    var body: some View {
        NavigationView {
            VStack {
                Form {
                    Section(header: Text("Product Details")) {
                        TextField("Product Name", text: $name)
                            .textContentType(.name)
                        TextField("Description", text: $description)
                            .textContentType(.none)
                        TextField("Price", text: $price)
                            .keyboardType(.decimalPad)
                        TextField("Image URL", text: $imageURL)
                            .textContentType(.URL)
                        Picker("Category", selection: $category) {
                            Text("---").tag(nil as Category?)
                            ForEach(Category.allCases, id: \.self) {
                                Text($0.rawValue).tag($0)
                            }
                        }
                    }

                    if isSubmitting {
                        Section {
                            HStack {
                                Spacer()
                                ProgressView()
                                Spacer()
                            }
                        }
                    }
                }
                .navigationTitle("Add Product")
                .navigationBarItems(trailing: Button("Cancel") {
                    dismiss()
                })
                .disabled(isSubmitting)

                Button(action: {
                    Task {
                        await addProduct()
                    }
                }) {
                    Text("Add Product")
                }
                .buttonStyle(.borderedProminent)
                .disabled(isSubmitting)
            }
            .errorAlert(error: validationError ?? productManager.error) {
                validationError = nil
                productManager.error = nil
            }
        }
    }

    private func validateInput() -> AppError? {
        if name.isEmpty {
            return .validationError("Product name is required")
        }
        if description.isEmpty {
            return .validationError("Description is required")
        }
        if price.isEmpty {
            return .validationError("Price is required")
        }
        if let priceDouble = Double(price), priceDouble <= 0 {
            return .validationError("Price must be greater than 0")
        }
        if imageURL.isEmpty {
            return .validationError("Image URL is required")
        }
        if !imageURL.hasPrefix("http://") && !imageURL.hasPrefix("https://") {
            return .validationError("Image URL must start with http:// or https://")
        }
        if category == nil {
            return .validationError("Category is required")
        }
        return nil
    }

    private func addProduct() async {
        // Validate input
        if let error = validateInput() {
            validationError = error
            return
        }

        isSubmitting = true
        defer { isSubmitting = false }

        let newProduct = Product(
            name: name.trimmingCharacters(in: .whitespacesAndNewlines),
            description: description.trimmingCharacters(in: .whitespacesAndNewlines),
            price: Double(price) ?? 0,
            imageUrl: imageURL.trimmingCharacters(in: .whitespacesAndNewlines),
            category: category!
        )

        do {
            try await productManager.addProduct(product: newProduct)
            dismiss()
        } catch {
            // Error is already handled by ProductManager
            print("Failed to add product: \(error.localizedDescription)")
        }
    }
}

#Preview {
    AddProductView()
        .environment(ProductManager())
}
