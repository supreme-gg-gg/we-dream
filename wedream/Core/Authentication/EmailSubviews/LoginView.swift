//
//  LoginView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-14.
//

import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
        
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password is found") // need real alert
            return
        }
        
        try await AuthManager.shared.signInUser(email: email, password: password)
        
    }
    
} // view model handles changes in state

struct LoginView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        NavigationStack { // move back and forth between Login and Register
            
            VStack {
                
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 100)
                    .padding(.vertical, 32)
                
                VStack(spacing: 24) {
                    InputView(text: $viewModel.email, title: "Email Address", placeholder: "name@example.com")
                    
                    InputView(text: $viewModel.password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Button {
                    Task {
                        do {
                            try await viewModel.signIn()
                            showSignInView = false
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    HStack {
                        Text("Log In")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                NavigationLink {
                    RegisterView(showSignInView: $showSignInView)
                        .navigationBarBackButtonHidden(true)
                } label: {
                    HStack(spacing: 3) {
                        Text("Don't have an account?")
                        Text("Sign up")
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 15)
            }
        }
    }
}

#Preview {
    LoginView(showSignInView: .constant(false))
}
