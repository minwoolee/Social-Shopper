//
//  SwiftUIView.swift
//  Social Shopper
//
//  Created by Min Woo Lee on 4/2/25.
//
import SwiftUI
import FirebaseAuth

struct LoginView: View {

    @State var isLoginMode = false
    @State var email = ""
    @State var password = ""

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
                        handleAction()
                    } label: {
                        HStack {
                            Spacer()
                            Text(isLoginMode ? "Log In" : "Create Account")
                                .foregroundColor(.white)
                                .padding(.vertical, 10)
                                .font(.system(size: 14, weight: .semibold))
                            Spacer()
                        }.background(Color.blue)

                    }
                }
                .padding()

            }
            .navigationTitle(isLoginMode ? "Log In" : "Create Account")
            .background(Color(.init(white: 0, alpha: 0.05))
                .ignoresSafeArea())
        }
    }

    private func handleAction() {
        if isLoginMode {
            Auth.auth().signIn(withEmail: email, password: password)
        } else {
            Auth
                .auth()
                .createUser(withEmail: email, password: password) { result, error in
                    if let error = error {
                        print("Error creating user: \(error.localizedDescription)")
                        return
                    }
                    print("User created successfully!")
                }
        }
    }
}

#Preview {
    LoginView()
}
