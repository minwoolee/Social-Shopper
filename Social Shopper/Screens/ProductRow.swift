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
        HStack(alignment: .top) {
            CachedAsyncImage(url: URL(string: product.imageUrl)) { phase in
                switch phase {
                case .empty:
                    Image(systemName: "photo") // Placeholder
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .success(let image):
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                case .failure:
                    Image(systemName: "photo") // Error indicator
                        .frame(width: 100, height: 100)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                @unknown default:
                    EmptyView()
                }
            }

            VStack(alignment: .leading) {
                HStack {
                    Text(product.name)
                        .font(.headline)
                        .lineLimit(2)
                        .minimumScaleFactor(0.5)
                    Spacer()
                    Text(product.formattedPrice)
                        .font(.callout)
                        .fontWeight(.bold)
                }
                Text(product.description)
                    .font(.caption)
                    .lineLimit(3)
                    .foregroundColor(.gray)
            }
        }
    }
}

#Preview {
    ProductRow(product: .sample)
}
