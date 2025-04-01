//
//  Error+Ext.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/1/25.
//
import Foundation

extension Error {
    var localizedDescription: String {
        (self as NSError).localizedDescription
    }
}
