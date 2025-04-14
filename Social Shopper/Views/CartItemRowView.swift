//
//  CartItemRow.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import SwiftUI
import CachedAsyncImage

struct CartItemRowView: View {
    var item: CartItem
    @Environment(CartManager.self) var cartManager

    var body: some View {
        HStack {
            CachedAsyncImage(url: URL(string: item.product.imageUrl)) { phase in
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
                Task {
                    try? await cartManager.removeItem(item: item)
                }
            }) {
                Image(systemName: "trash")
                    .foregroundColor(.red)
            }
        }
    }
}

#Preview {
    CartItemRowView(item: .sample)
        .environment(CartManager.shared)
}
