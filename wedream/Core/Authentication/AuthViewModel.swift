//
//  AuthViewModel.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import Foundation

@MainActor
final class AuthViewModel: ObservableObject {
    
    // find the top-most UI Controller & the Google Sign-in Modal will show above it
    
    func singInGoogle() async throws {
        
        let helper = SignInGoogleHelper()
        let tokens = try await helper.signIn()
        let authDataResult = try await AuthManager.shared.signInWithGoogle(tokens: tokens)
        
        let user = DBUser(auth: authDataResult)
        try await UserManager.shared.createNewUser(user: user)
        // try await UserManager.shared.createNewUser(auth: authDataResult)
        
    }
    
}
