//
//  ProfileView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import SwiftUI

@MainActor
final class ProfileViewModel: ObservableObject {
    
    @Published private(set) var user: DBUser? = nil
    
    @Published var profileInfo: [String: Any] = [
        "name": "",
        "gender": "",
        "age" : 0,
        "sleepGoal" : 7
    ]
    
    func loadCurrentUser() async throws {
        let authDataResult = try AuthManager.shared.getAuthUser()
        self.user = try await UserManager.shared.getUser(userId: authDataResult.uid)
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
    
    func updateProfile() {
        
    }
    
}

struct ProfileView: View {
    
    @StateObject private var viewModel = ProfileViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        VStack {
            List {
                if let user = viewModel.user {
                    Text("UserId: \(user.userId)")
                    
                    Button {
                        viewModel.togglePremiumStatus()
                    } label: {
                        Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                    }
                }
            }.task {
                try? await viewModel.loadCurrentUser()
            }
            
            Form {
                Section(header: Text("User Settings")) {
                    TextField("Name", text: Binding<String>(
                        get: { self.viewModel.profileInfo["name"] as! String },
                        set: { self.viewModel.profileInfo["name"] = $0 }
                    ))
                    .padding()
                    Picker(selection: Binding<String>(
                        get: { self.viewModel.profileInfo["gender"] as! String },
                        set: { self.viewModel.profileInfo["gender"] = $0 }
                    ), label: Text("Gender")) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                }
                
                Section(header: Text("Health Information")) {
                    Stepper(value: Binding<Int>(
                        get: { self.viewModel.profileInfo["sleepGoal"] as! Int },
                        set: { self.viewModel.profileInfo["sleepGoal"] = $0 }
                    ), in: 0...24) {
                        Text("Sleep Goal: \(viewModel.profileInfo["sleepGoal"] as! Int)")
                    }
                    .padding()
                }
                
                Button {
                    viewModel.updateProfile()
                } label: {
                    Text("Save Preferences")
                }
            }
        }
        .navigationTitle("Profile")
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                NavigationLink {
                    SettingsView(showSignInView: $showSignInView)
                } label: {
                    Image(systemName: "gear")
                        .font(.headline)
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileView(showSignInView: .constant(false))
    }
}
