//
//  RootView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-14.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    // this is the source of truth, all other showSignInView are bindings!
    @State private var showSignInView: Bool = false
    @State private var selectedTab = 2
    
    var body: some View {
        ZStack {
            
            if !showSignInView {
                
                // only draw it when signed in
                TabView (selection: $selectedTab) {
                        
                    LeaderboardView()
                        .tabItem {
                            Image(systemName: "trophy.fill")
                            Text("Honour Roll")
                        }
                        .safeAreaPadding(.bottom)
                        .background(Color(.gray))
                        .tag(0)
                    
                    ProfileView(showSignInView: $showSignInView)
                        .safeAreaPadding(.bottom)
                        .tabItem {
                            Image(systemName: "person.fill")
                            Text("Profile")
                        }
                        .tag(1)
                    
                    HomeView(showSignInView: $showSignInView)
                        .safeAreaPadding(.bottom)
                        .tabItem {
                            Label("Home", systemImage: "house.fill")
                        }.tag(2)
                    
                    ChallengesView()
                        .safeAreaPadding(.bottom)
                        .tabItem {
                            Image(systemName: "trophy.fill")
                            Text("Challenges")
                        }.tag(3)
                    
                    Text("Social page")
                        .safeAreaPadding(.bottom)
                        .tabItem {
                            Image(systemName: "person.2.fill")
                            Text("Social")
                        }.tag(4)
                    }
            }
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getAuthUser()
            self.showSignInView = authUser == nil ? true : false
            // self.showSignUpView = authUser?.isNewUser == true ? true : false
            
            // three possibility: login, already logged in, signup
            
            // onAppear only runs once at the very beginning before Auth pages even come up, so at this point on already logged in users can be loaded
            if !showSignInView {
                Task {
                    try await userVM.loadCurrentUser()
                    await HealthStore.shared.requestAuthorization()
                }
            }
        }
        // therefore we need a listener of when status changes to load data again (this means the user finished authentication and their info is in the database or can be read now)
        .onChange(of: showSignInView) {
            Task {
                try await userVM.loadCurrentUser()
            }
        }
        .fullScreenCover(isPresented: $showSignInView, content: {
            NavigationView {
                AuthView(showingSignInView: $showSignInView)
            }
        })
    }
}

#Preview {
    RootView()
        .environmentObject(UserViewModel())
}
