//
//  AuthManager.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-14.
//

import Foundation
import FirebaseAuth

struct AuthDataResultModel {
    let uid: String // Firebase automatically gives us an unique ID for each user
    let email: String?
    let photoURL: String?
    let isNewUser: Bool?
    
    init (user: User, isNewUser: Bool) { // User object comes with FirebaseAuth SDK
        self.uid = user.uid
        self.email = user.email
        self.photoURL = user.photoURL?.absoluteString
        self.isNewUser = isNewUser
    }
}

enum AuthProviderOption: String {
    case email = "password"
    case google = "google.com"
}

final class AuthManager {
    
    static let shared = AuthManager()
    
    private init() { }
    
    @discardableResult
    func getAuthUser() throws -> AuthDataResultModel { // NOT async so only going to search locally
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse) // custom error to be created
        }
        
        return AuthDataResultModel(user: user, isNewUser: false)
    }
    
    func getProviders() throws -> [AuthProviderOption] {
        guard let providerData = Auth.auth().currentUser?.providerData else {
            throw URLError(.badServerResponse)
        }
        
        // the "providerData" is an array since each user can have multiple signin method, use an enum to extract it
        
        var providers: [AuthProviderOption] = []
        for provider in providerData {
            if let option = AuthProviderOption(rawValue: provider.providerID) {
                providers.append(option)
            } else {
                // this error will not crash the app
                assertionFailure("Provider option not found: \(provider.providerID)")
            }
        }
        
        return providers
    }
    
    func signOut() throws {
        try Auth.auth().signOut()
    }
}

// MARK: SIGN IN EMAIL

extension AuthManager {
    
    func createUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().createUser(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user, isNewUser: authDataResult.additionalUserInfo?.isNewUser ?? true)
    }
    
    @discardableResult
    func signInUser(email: String, password: String) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(withEmail: email, password: password)
        return AuthDataResultModel(user: authDataResult.user, isNewUser: authDataResult.additionalUserInfo?.isNewUser ?? true)
    }
    
    func resetPassword(email: String) async throws {
        try await Auth.auth().sendPasswordReset(withEmail: email)
    }
    
    func updatePassword(password: String) async throws{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updatePassword(to: password)
    }
    
    func updateEmail(email: String) async throws{
        guard let user = Auth.auth().currentUser else {
            throw URLError(.badServerResponse)
        }
        
        try await user.updateEmail(to: email)
    }
}

// MARK: SIGN IN SSO

extension AuthManager {
    
    @discardableResult
    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> AuthDataResultModel{
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        return try await signIn(credential: credential)
    }
    
    // Apple and Google etc. sing-in uses the same way here with credential
    
    func signIn(credential: AuthCredential) async throws -> AuthDataResultModel {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        return AuthDataResultModel(user: authDataResult.user, isNewUser: authDataResult.additionalUserInfo?.isNewUser ?? true)
    }
    
}
