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
            ScrollView {
                VStack(spacing: 20) {
                    Image("pfp")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 120, height: 120)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 4))
                        .shadow(radius: 10)
                    
                    if let profile = userVM.profileInfo as? [String: String] {
                        ProfileInfoView(name: profile["name"] ?? "", gender: profile["gender"] ?? "", age: profile["age"] ?? "")
                    } else {
                        Text("No profile info available")
                            .foregroundColor(.gray)
                    }
                    
                    if let user = userVM.user {
                        UserDetailView(userId: user.userId, weeklyXP: user.weeklyXP)
                    } else {
                        Text("No user data available")
                            .foregroundColor(.gray)
                    }
                    
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.gray.opacity(0.1))
                        .frame(height: 200)
                        .overlay(
                            Text("Graphs will appear here")
                                .foregroundColor(.secondary)
                        )
                        .padding(.horizontal)
                }
                .padding()
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
}

struct ProfileInfoView: View {
    
    var name: String
    var gender: String
    var age: String
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Name: \(name)")
            Text("Gender: \(gender)")
            Text("Age: \(age)")
        }
    }
}

struct UserDetailView: View {
    
    var userId: String
    var weeklyXP: Int?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("User ID:")
                Text(userId)
                    .foregroundColor(.blue)
            }
            HStack {
                Text("Your XP:")
                Text("\(weeklyXP ?? 0)")
                    .foregroundColor(.green)
            }
        }
    }
}

#Preview {
   // ProfileView(showSignInView: .constant(false))
        // .environmentObject(UserViewModel())
    
    LazyProfileView(userId: "9vQY7TwOtBdCNCm1hrYIy8EzoFp1")
}
