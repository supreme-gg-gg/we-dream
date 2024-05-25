//
//  AuthView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-14.
//

import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct AuthView: View {
    
    @StateObject private var viewModel = AuthViewModel()
    @Binding var showingSignInView: Bool
    
    var body: some View {
        VStack {
            NavigationLink {
                SignInEmailView(showSignInView: $showingSignInView)
            } label: {
                Text("Sign in with email")
                    .font(.headline)
                    .foregroundColor(.white)
                    .frame(height: 55)
                    .frame(maxWidth: .infinity)
                    .background(.blue)
                    .cornerRadius(5)
            }
            
            GoogleSignInButton(viewModel: GoogleSignInButtonViewModel(scheme: .dark, style: .wide, state: .normal)) {
                Task {
                    do {
                        try await viewModel.singInGoogle()
                        showingSignInView = false
                    } catch {
                        print(error)
                    }
                }
            }
        }
        .padding()
        .navigationTitle("Sign In")
        
        Spacer()
    }
}

#Preview {
    NavigationStack {
        AuthView(showingSignInView: .constant(false))
    }
}
