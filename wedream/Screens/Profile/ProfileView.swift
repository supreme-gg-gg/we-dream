//
//  ProfileView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    
    @Binding var showSignInView: Bool
    
    @State private var isProfileView = false
    
    var body: some View {
        NavigationStack {
            List {
                if let user = userVM.user {
                    HStack {
                        Text("UserId: \(user.userId)")
                    }
                    HStack {
                        Text("Your XP: \(user.weeklyXP ?? 0)")
                    }
                } else {
                    Text("No user data available")
                }
                
                if let profile = userVM.profileInfo {
                    HStack {
                        Text("Name: \(profile["name"] ?? "")")
                    }
                } else {
                    Text("No profile info available")
                }
                
                if let user = userVM.user {
                    Button {
                        userVM.togglePremiumStatus()
                    } label: {
                        Text("User is premium: \((user.isPremium ?? false).description.capitalized)")
                    }
                }
            }
            .navigationTitle("Profile")
            .toolbar {
                if isProfileView {
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
            .onAppear {
                isProfileView = true
            }
            .onDisappear {
                isProfileView = false
            }
        }
        
    }
}

#Preview {
    ProfileView(showSignInView: .constant(false))
        .environmentObject(UserViewModel())
}
