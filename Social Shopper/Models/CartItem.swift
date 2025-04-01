//
//  CartItem.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation

struct CartItem: Identifiable, Codable {
    var id = UUID()
    var product: Product
    var quantity: Int
}
