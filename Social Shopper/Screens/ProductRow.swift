//
//  ProductRow.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import SwiftUI
import CachedAsyncImage

struct ProductRow: View {
    var product: Product

    var body: some View {
        HStack {
            CachedAsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo") // Placeholder
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo") // Error indicator
                        .frame(width: 50, height: 50)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading) {
                Text(product.name)
                    .font(.headline)
                Text(product.description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text(product.formattedPrice)
                    .font(.callout)
                    .fontWeight(.bold)
            }
        }
    }
}

#Preview {
    ProductRow(product: .sample)
}
