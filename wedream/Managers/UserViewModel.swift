//
//  UserViewModel.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-24.
//

import Foundation

@MainActor
final class UserViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    @Published var profileInfo: [String: Any]? = [
        "name": "",
        "gender": "",
        "age" : 0,
        "sleepGoal" : 7
    ]
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid) // this automatically gets the user's info
    }
    
    func togglePremiumStatus() {
        guard let user else { return }
        let currentValue = user.isPremium ?? false
        
        /// Now we have to update the user struct
        ///
        /// Method 1: Take current user -> create a new user with desired new value (write func in user struct) -> update the database (write the func in manager)
        
        // let updatedUser = user.updatePremiumStatus()
        
        /// Method 2: Mutate the struct directly (change only that variable) by making it "var"
        
        // user.updatePremiumStatus()
        
        /// Method 3: 1 & 2 both changes the struct and reset the entire document in DB, but we can also just change on single key-value
        
        Task {
            try await UserManager.shared.updateUserPremiumStatus(userId: user.userId, isPremium: !currentValue)
            
            self.user = try await UserManager.shared.getUser(userId: user.userId)
        }
    }
    
    // AuthDataResult is stored locally but we want to load the profile from Database!
    
    func updateUserProfile() {
        guard let user else {return}
        guard let profileInfo else {return}
        Task {
            try await UserManager.shared.updateProfile(userId: user.userId, newProfile: profileInfo)
        }
    }
    
}
