//
//  ProfileView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import SwiftUI

struct ProfileView: View {
    
    @StateObject private var viewModel = UserViewModel()
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
                        get: { self.viewModel.profileInfo?["name"] as! String },
                        set: { self.viewModel.profileInfo?["name"] = $0 }
                    ))
                    .padding()
                    Picker(selection: Binding<String>(
                        get: { self.viewModel.profileInfo?["gender"] as! String },
                        set: { self.viewModel.profileInfo?["gender"] = $0 }
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
                        get: { self.viewModel.profileInfo?["sleepGoal"] as! Int },
                        set: { self.viewModel.profileInfo?["sleepGoal"] = $0 }
                    ), in: 0...24) {
                        Text("Sleep Goal: \(viewModel.profileInfo?["sleepGoal"] as! Int)")
                    }
                    .padding()
                }
                
                Button {
                    viewModel.updateUserProfile()
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
