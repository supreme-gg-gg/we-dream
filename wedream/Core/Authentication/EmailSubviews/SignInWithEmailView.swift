//
//  SignInWithEmailView.swift
//  wedream
//
//  Created by Boyuan Jiang on 4/6/2024.
//

/*
import SwiftUI

struct SignInWithEmailView: View {
    
    @StateObject private var viewModel = LoginViewModel()
    @Binding var showSignInView: Bool
    @State private var wrongCredentials = 0
    
    var body: some View {
        
        NavigationStack { // move back and forth between Login and Register
            
            ZStack {
                
                Color.blue.ignoresSafeArea()
                Circle().scale(1.7).foregroundColor(.white.opacity(0.15))
                Circle().scale(1.35).foregroundColor(.white)
                
                VStack {
                    Text("Login/SignUp")
                        .font(.largeTitle)
                        .bold()
                        .padding()
                    TextField("Email...", text: $viewModel.email)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .border(.red, width: CGFloat(wrongCredentials))
                    SecureField("Password...", text: $viewModel.password)
                        .padding()
                        .frame(width: 300, height: 50)
                        .background(Color.gray.opacity(0.2))
                        .cornerRadius(10)
                        .border(.red, width: CGFloat(wrongCredentials))
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
                    }
                    .foregroundColor(.white)
                    .frame(width: 300, height: 50)
                    .background(Color.blue)
                    .cornerRadius(10)
                }.padding()
                
            }.navigationBarHidden(true)
            
            
            /* sheet(isPresented: $viewModel.showOverlay, content: {
             NavigationStack {
             ProfileForm(userVM: UserViewModel())
             .navigationTitle("Create your profile")
             }
             }) */
        }
    }
}

#Preview {
    SignInWithEmailView(showSignInView: .constant(false))
}
*/
