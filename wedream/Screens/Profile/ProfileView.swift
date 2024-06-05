//
//  ProfileView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import SwiftUI

/// for users to view other's profile by only providing the userId, it will load the other user's public profile and builds a new profile view using that
struct LazyProfileView: View {
    
    var userId: String
    
    var body: some View {
        
        ProfileView(showSignInView: .constant(false))
            .environmentObject(UserViewModel(id: userId))
    }
}

struct ProfileView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    
    @Binding var showSignInView: Bool
    
    @State private var isProfileView = false
    
    var body: some View {
        
        NavigationStack {
            // can i add a scroll view here??? List conflict??
            VStack(spacing: 20) {
                Image("pfp")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 4))
                    .shadow(radius: 10)
                
                // user contains private profile info, only dispalyed if it is logged in user
                if let profile = userVM.profileInfo {
                    
                    if let user = userVM.user {
                        ProfileInfoView(profile: profile, userId: user.userId)
                            .navigationTitle("Profile")
                    } else {
                        ProfileInfoView(profile: profile)
                            .navigationTitle("Profile")
                    }
                    
                } else {
                    Text("No profile info available")
                        .foregroundColor(.gray)
                        .navigationTitle("Profile")
                }
                /*
                else {
                    Text("No user data available")
                        .foregroundColor(.gray)
                } */
                Section("User Sleep Record") {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            Text("Graphs will appear here")
                                .foregroundColor(.secondary)
                        )
                        .padding(.horizontal)
                }
                
                Spacer()
                
            }
            .padding()
            }
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

struct ProfileInfoView: View {
    
    var profile: [String: Any]
    var userId: String? = nil
    
    var body: some View {
        
        // This automatically reads everything in profile_info map since that contains all the public profile info (it can grow no problem)
        List {
            ForEach(profile.keys.sorted(), id: \.self) { key in
                if let value = profile[key] {
                    HStack {
                        Text("\(key.capitalized):")
                        Text("\(String(describing: value))")
                            .foregroundColor(.blueDark)
                    }
                }
            }
            
            if let id = userId {
                VStack {
                    HStack {
                        Text("User ID:")
                        Text(id)
                            .foregroundColor(.green)
                    }
                    Text("For testing purpose only, ID will not be shown to actual user.")
                        .font(.caption)
                }
            }
            
        }
        .listStyle(.inset)
    }
}

struct UserDetailView: View {
    
    var userId: String
    var weeklyXP: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            
        }
    }
}

#Preview {
   ProfileView(showSignInView: .constant(false)) .environmentObject(UserViewModel())
    
    // LazyProfileView(userId: "9vQY7TwOtBdCNCm1hrYIy8EzoFp1")
}
