//
//  SettingsView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-14.
//

import SwiftUI

struct SettingsView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @StateObject private var viewModel = SettingsViewModel()
    @Binding var showSignInView: Bool
    
    var body: some View {
        
        NavigationView {
            List {
                Section {
                    HStack {
                        Text("\(userVM.profileInfo?["name"] ?? "HW")") // find an actual way to get the initials
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundStyle(.white)
                            .frame(width: 72, height: 72)
                            .background(Color(.blueDark))
                            .clipShape(Circle())
                        
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(userVM.profileInfo?["name"] ?? "Hello World")")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .padding(.top, 4)
                            
                            Text("\(userVM.user?.email ?? "User email N/A")")
                                .font(.footnote)
                                .accentColor(.blue)
                        }
                        .padding(.leading, 10)
                    }
                }
                
                Section("General") {
                    HStack {
                        SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                        
                        Spacer()
                        
                        Text("Beta Pre-release")
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
                
                Section("Account") {
                    Button {
                        Task {
                            do {
                                try viewModel.logOut()
                                showSignInView = true // return to signin screen
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        SettingsRowView(imageName: "arrow.left.circle.fill", title: "Sign Out", tintColor: .red)
                    }
                    
                    Button {
                        print("Delete account...")
                    } label: {
                        SettingsRowView(imageName: "xmark.circle.fill", title: "Delete account", tintColor: .red)
                    }
                    Button {
                        Task {
                            do {
                                try await viewModel.resetPassword()
                                print("Password Reset")
                            } catch {
                                print(error)
                            }
                        }
                    } label: {
                        SettingsRowView(imageName: "person.badge.key.fill", title: "Reset Password", tintColor: .red)
                    }
                    
                }
                
                Section("User Profile") {
                    NavigationLink(destination: ProfileForm().environmentObject(userVM)) {
                        Label(
                            title: { Text("Update Profile").font(.subheadline)
                                .foregroundStyle(.blueDark) },
                            icon: { Image(systemName: "person.crop.circle.fill") }
                        )
                    }
                    
                    if viewModel.authProviders.contains(.email) {
                                        
                        NavigationLink(destination: EmailUpdateForm().environmentObject(userVM)) {
                            Label(
                                title: { Text("Update Email and/or Password").font(.subheadline)
                                    .foregroundStyle(.blueDark) },
                                icon: { Image(systemName: "envelope.fill") }
                            )
                        }
                        
                    }
                    
                }
                
            }
            .navigationTitle("Settings")
            .onAppear {
                viewModel.loadAuthProviders()
            }
        }
        
    }
}

struct SettingsRowView: View {
    
    let imageName: String
    let title: String
    let tintColor: Color
    
    var body: some View {
        
        HStack(spacing: 12) {
            Image(systemName: imageName)
                .imageScale(.small)
                .font(.title)
                .foregroundColor(tintColor)
            
            Text(title)
                .font(.subheadline)
                .foregroundStyle(.blueDark)
        }
        
    }
    
}

#Preview {
    SettingsView(showSignInView: .constant(false))
        .environmentObject(UserViewModel())
}

/*
extension SettingsView { // all email features grouped here
    private var emailSection: some View {
        Section {
            
            Button("Update Password") {
                Task {
                    do {
                        // MARK: THERE SHOULD BE SOME WAY TO LET USER ENTER PASSWORD/EMAIL
                        try await viewModel.updatePassword(password: "12345678")
                        print("Password Updated!")
                    } catch {
                        print(error)
                    }
                }
            }
            
            Button("Update Email") {
                Task {
                    do {
                        try await viewModel.updateEmail(email: "jetjiang.ez@gmail.com")
                        print("Email updated")
                    } catch {
                        print(error)
                    }
                }
            }
        }
    }
}
*/
