//
//  SignInEmailView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-14.
//

import SwiftUI

@MainActor
final class SignInEmailViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password is found") // need real alert
            return
        }
        
        let authDataResult = try await AuthManager.shared.createUser(email: email, password: password)
        
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        
        // try await UserManager.shared.createNewUser(auth: authDataResult)
        
    }
        
    func signIn() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password is found") // need real alert
            return
        }
        
        try await AuthManager.shared.signInUser(email: email, password: password)
        
    }
    
} // view model handles changes in state

struct SignInEmailView: View {
    
    @StateObject private var viewModel = SignInEmailViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            TextField("Email...", text: $viewModel.email)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            SecureField("Password...", text: $viewModel.password)
                .padding(.horizontal)
                .frame(height: 55)
                .background(Color.gray.opacity(0.4))
                .cornerRadius(10)
            Button {
                Task {
                    do {
                        try await viewModel.signIn()
                        showSignInView = false // dismiss signin view if it is successful
                        return // if can signin return out directly
                    } catch {
                        print(error)
                    }
                    
                    // it will only get here if signin failed
                    
                    do {
                        try await viewModel.signUp()
                        showSignInView = false
                        return
                    } catch {
                        print(error)
                    }
                    
                }
            } label: {
                Text("Sign in")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(5)
            }
        }.navigationTitle("Enter your email")
            .padding()
            /* sheet(isPresented: $viewModel.showOverlay, content: {
                NavigationStack {
                    ProfileForm(userVM: UserViewModel())
                        .navigationTitle("Create your profile")
                }
            }) */
    }
}

#Preview {
    NavigationStack {
        SignInEmailView(showSignInView: .constant(false))
    }
}
