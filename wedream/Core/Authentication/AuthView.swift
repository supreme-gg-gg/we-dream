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
        NavigationStack {
        
            ZStack {
                
                Color.blue.ignoresSafeArea()
                Circle().scale(1.7).foregroundColor(.white.opacity(0.15))
                Circle().scale(1.35).foregroundColor(.white)
                
                VStack {
                    
                    Text("Welcome")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    
                    NavigationLink {
                        LoginView(showSignInView: $showingSignInView)
                    } label: {
                        Text("Email and Password")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(width: 300, height: 50)
                            .background(.blue)
                            .cornerRadius(10)
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
                    .frame(width: 300, height: 50)
                    .cornerRadius(5)
                }
                .navigationBarHidden(true)
            }
        }
    }
}

#Preview {
    AuthView(showingSignInView: .constant(false))
}
