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
        List {
            Button("Log out") {
                Task {
                    do {
                        try viewModel.logOut()
                        showSignInView = true // return to signin screen
                    } catch {
                        print(error)
                    }
                }
            }
            
            if viewModel.authProviders.contains(.email) {
                emailSection
            }
            
            Section(header: Text("Profile")) {
                ProfileForm(userVM: userVM)
            }
            
        }
        .listStyle(GroupedListStyle())
        .onAppear {
            viewModel.loadAuthProviders()
        }
        .navigationTitle("Settings")
     }
}

#Preview {
    NavigationStack {
        SettingsView(showSignInView: .constant(false))
            .environmentObject(UserViewModel())
    }
}

extension SettingsView { // all email features grouped here
    private var emailSection: some View {
        Section {
            Button("Reset Password") {
                Task {
                    do {
                        try await viewModel.resetPassword()
                        print("Password Reset")
                    } catch {
                        print(error)
                    }
                }
            }
            
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
        } header: {
            Text("Email functions")
        }
    }
}
