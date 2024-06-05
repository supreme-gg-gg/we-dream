//
//  UserViewModel.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-24.
//

import Foundation

@MainActor
final class UserViewModel: ObservableObject {
    
    var id : String?
    
    @Published private(set) var user: DBUser? = nil
    
    func updateSleepGoal(to newGoal: Int) {
        guard var user = user else { return }
        user.sleepGoal = newGoal
        self.user = user
    }
    
    /*
    @Published var profileInfo: [String: Any]? = [
        "name": "World",
        "gender": "Male",
        "age" : 0,
        "sleep_goal" : 7
    ]
    
    // these data are first stored as int (or TimeInterval), but will be converted to or back from string in "00:00" using functions in "Utilities"
    @Published var sleepTime: [String: Any]? = [
        "weekly_sleep": 0,
        "daily_sleep" : 0
    ] */
    
    @Published var profileInfo: [String: Any]? = nil
    
    @Published var sleepTime: [String: Any]? = nil
    
    init(id : String? = nil) {
        
        self.id = id
        
        Task {
            try await initUserVM()
        }
    }
    
    // honestly this is so useless LMAO
    private func initUserVM() async throws {
        if let id = id { // if id exists
            
            // Fetch data for a user with a specific Id (viewing other profiles)
            // only fetch the necessary profile data (including xp)
            self.profileInfo = try await UserManager.shared.fetchMapFromId(userId: id, key: "profile_info")
            
        } else {
            // Fetch data for the current authenticated user (all data)
            try await loadCurrentUser()
        }
    }
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid) // this automatically gets the user's info
        self.profileInfo = try await UserManager.shared.fetchMapFromId(userId: authDataResult.uid, key: "profile_info")
        self.sleepTime = try await UserManager.shared.loadSleepTime()
    }
    
    /*
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
     
     */
}
