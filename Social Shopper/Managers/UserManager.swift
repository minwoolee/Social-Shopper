//
//  UserManager.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//

import Foundation
import FirebaseCore
import FirebaseAuth

@Observable
final class UserManager {

    static let shared = UserManager()

    var isSignedIn: Bool = false

    private init() {
        _ = Auth.auth().addStateDidChangeListener { _, user in
            self.isSignedIn = user != nil
            print("User signed in: \(self.isSignedIn)")
            
            if self.isSignedIn {
                // User has signed in, set up cart listener
                CartManager.shared.setupCartListener()
            }
        }
    }

    var user: User? {
        return Auth.auth().currentUser
    }

    func signOut() {
        if let _ = try? Auth.auth().signOut() {
            isSignedIn = false
            CartManager.shared.removeCartListener()
        }
    }
}
