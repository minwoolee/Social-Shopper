//
//  SwiftUIView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//

import SwiftUI
import FirebaseAuth

struct LoginView: View {
    @Environment(UserManager.self) private var userManager
    @State private var isLoginMode = false
    @State private var email = ""
    @State private var password = ""
    @State private var isLoading = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 16) {
                    Picker(selection: $isLoginMode, label: Text("Picker here")) {
                        Text("Login")
                            .tag(true)
                        Text("Create Account")
                            .tag(false)
                    }.pickerStyle(SegmentedPickerStyle())

                    Group {
                        TextField("Email", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                        SecureField("Password", text: $password)
                    }
                    .padding(12)
                    .background(Color.white)

                    Button {
                        Task {
                            await handleAction()
                        }
                    } label: {
                        Text(isLoginMode ? "Log In" : "Create Account")
                            .frame(maxWidth: .infinity)
                    }
                    .primaryButton(isLoading: isLoading)
                    .disabled(isLoading)
                }
                .padding()
            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
            .errorAlert(error: userManager.error) {
                userManager.error = nil
            }
        }
    }

    private func handleAction() async {
        isLoading = true
        defer { isLoading = false }

        if isLoginMode {
            await userManager.signIn(email: email, password: password)
        } else {
            await userManager.createAccount(email: email, password: password)
        }
    }
}

#Preview {
    LoginView()
        .environment(UserManager.shared)
}
