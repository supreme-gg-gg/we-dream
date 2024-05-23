//
//  SettingsViewModel.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import Foundation

@MainActor
final class SettingsViewModel: ObservableObject {
    
    @Published var authProviders: [AuthProviderOption] = []
    
    func loadAuthProviders() {
        if let providers = try? AuthManager.shared.getProviders() {
            authProviders = providers
        }
    }
    
    // like SignInViewModel, these function belong to this view
    
    func logOut() throws {
        try AuthManager.shared.signOut()
    }
    
    func resetPassword() async throws {
        // there should be somewhere for user to enter email, this only loads the current user
        let AuthUser = try AuthManager.shared.getAuthUser()
        guard let email = AuthUser.email else {
            throw URLError(.fileDoesNotExist) // create actual customised errors!
        }
        try await AuthManager.shared.resetPassword(email: email)
    }
    
    func updateEmail(email: String) async throws {
        // notice that this function (Firebase) can only be called when the user authenticated recently (so log out and signin again), send an alert
        try await AuthManager.shared.updateEmail(email: email)
    }
    
    func updatePassword(password: String) async throws {
        try await AuthManager.shared.updatePassword(password: password)
    }
    
}
