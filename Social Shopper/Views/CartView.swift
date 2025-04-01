import SwiftUI
import FirebaseCore
import FirebaseFirestore
import FirebaseStorage
import FirebaseMessaging
import FirebaseAnalytics
import UIKit
import Combine
import CoreGraphics
import Observation

struct CartView: View {
    @Environment(CartManager.self) var cartManager
    @State private var paymentSuccess = false

    var body: some View {
        NavigationView {
            VStack {
                if cartManager.items.isEmpty {
                    Text("Your cart is empty.")
                        .padding()
                } else {
                    List {
                        ForEach(cartManager.items) { item in
                            CartItemRow(item: item)
                        }
                        HStack {
                            Text("Total:")
                                .font(.headline)
                            Spacer()
                            Text(String(format: "$%.2f", cartManager.getTotalPrice()))
                                .font(.headline)
                                .fontWeight(.bold)
                        }
                        .padding(.vertical)
                    }
                    .listStyle(PlainListStyle())

                    Button(action: {
                        // In a real app, you would integrate with a payment gateway (e.g., Stripe, Apple Pay).
                        // For this example, we'll just simulate a successful payment.
                        cartManager.clearCart()
                         paymentSuccess = true

                    }) {
                        Text("Checkout")
                            .padding()
                            .background(Color.green)
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                     .alert(isPresented: $paymentSuccess) {
                        Alert(title: Text("Payment Successful"), message: Text("Thank you for your purchase!"), dismissButton: .default(Text("OK")))
                    }
                }
            }
            .navigationTitle("Cart")
        }
    }
}

// Cart Item Row
struct CartItemRow: View {
    var item: CartItem
    @Environment(CartManager.self) var cartManager

    var body: some View {
        HStack {
            AsyncImage(url: URL(string: item.product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo")
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo")
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView()
                }
            }
            VStack(alignment: .leading) {
                Text(item.product.name)
                    .font(.headline)
                Text("Quantity: \(item.quantity)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(item.product.formattedPrice)
                    .font(.callout)
                    .fontWeight(.bold)
            }
            Spacer()
            Button(action: {
                cartManager.removeItem(item: item)
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}
