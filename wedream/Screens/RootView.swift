//
//  RootView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-14.
//

import SwiftUI

struct RootView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State private var showSignInView: Bool = false
    @State private var selectedTab = 2
    @State private var showSignUpView: Bool = false
    
    var body: some View {
        ZStack {
            if !showSignInView {
                
                // only draw it when signed in
                TabView (selection: $selectedTab) {
                        
                    NavigationStack {
                        
                        HRView()
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
                        
                        HomeView()
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
                    .fullScreenCover(isPresented: $showSignUpView, content: {
                        SignUpView(showSignUpView: $showSignUpView)
                    })
                }
            }
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getAuthUser()
            self.showSignInView = authUser == nil ? true : false
            // self.showSignUpView = authUser?.isNewUser == true ? true : false
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
