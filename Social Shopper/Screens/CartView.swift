import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseAnalytics
import UIKit
import Combine
import CoreGraphics
import Observation

struct CartView: View {
    @Environment(CartManager.self) var cartManager
    @State private var paymentSuccess = false
    @State private var isProcessingPayment = false
    @State private var validationError: AppError?

    var body: some View {
        NavigationView {
            VStack {
                if cartManager.items.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "cart")
                            .font(.system(size: 50))
                            .foregroundColor(.gray)
                        Text("Your cart is empty")
                            .font(.headline)
                        Text("Add some products to your cart")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                    .padding()
                } else {
                    List {
                        ForEach(cartManager.items) { item in
                            CartItemRow(item: item)
                        }
                        
                        Section {
                            HStack {
                                Text("Subtotal:")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f", cartManager.getSubtotal()))
                                    .font(.headline)
                            }
                            
                            HStack {
                                Text("Tax (10%):")
                                    .font(.headline)
                                Spacer()
                                Text(String(format: "$%.2f", cartManager.getTax()))
                                    .font(.headline)
                            }
                            
                            HStack {
                                Text("Total:")
                                    .font(.headline)
                                    .fontWeight(.bold)
                                Spacer()
                                Text(String(format: "$%.2f", cartManager.getTotalPrice()))
                                    .font(.headline)
                                    .fontWeight(.bold)
                            }
                        }
                        .padding(.vertical)
                    }
                    .listStyle(PlainListStyle())

                    Button(action: {
                        Task {
                            await processPayment()
                        }
                    }) {
                        Text("Checkout")
                    }
                    .successButton(isLoading: isProcessingPayment)
                    .disabled(isProcessingPayment)
                    .padding()
                }
            }
            .navigationTitle("Cart")
            .alert("Success", isPresented: $paymentSuccess) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Thank you for your purchase!")
            }
            .errorAlert(error: validationError ?? cartManager.error) {
                validationError = nil
                cartManager.error = nil
            }
        }
    }
    
    private func processPayment() async {
        isProcessingPayment = true
        defer { isProcessingPayment = false }
        
        do {
            // In a real app, you would integrate with a payment gateway (e.g., Stripe, Apple Pay)
            // For this example, we'll simulate a payment process
            try await Task.sleep(nanoseconds: 1_500_000_000) // Simulate network delay
            
            // Validate cart before processing
            guard !cartManager.items.isEmpty else {
                validationError = .validationError("Cart is empty")
                return
            }
            
            // Process payment
            cartManager.clearCart()
            paymentSuccess = true
        } catch {
            validationError = .validationError("Payment failed: \(error.localizedDescription)")
        }
    }
}

#Preview {
    CartView()
        .environment(CartManager())
}
