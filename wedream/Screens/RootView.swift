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
    
    var body: some View {
        ZStack {
            if !showSignInView {
                // only draw it when signed in
                NavigationStack {
                    
                    TabView (selection: $selectedTab) {
                        
                        HRView()
                            .tabItem {
                                Image(systemName: "trophy.fill")
                                Text("Honour Roll")
                            }
                            .tag(0)
                        
                        ProfileView(showSignInView: .constant(false))
                            .tabItem {
                                Image(systemName: "person.fill")
                                Text("Profile")
                            }
                            .tag(1)
                        
                        HomeView()
                            .tabItem {
                                Label("Home", systemImage: "house.fill")
                            }.tag(2)
                        
                        ChallengesView()
                            .tabItem {
                                Image(systemName: "trophy.fill")
                                Text("Challenges")
                            }.tag(3)
                        
                        Text("Social page")
                            .tabItem {
                                Image(systemName: "person.2.fill")
                                Text("Social")
                            }.tag(4)
                    }
                }
            }
        }
        .onAppear {
            let authUser = try? AuthManager.shared.getAuthUser()
            self.showSignInView = authUser == nil ? true : false
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
