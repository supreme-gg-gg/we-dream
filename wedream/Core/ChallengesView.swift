//
//  ChallengesView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI

// MARK: FOR TESTIING: Hammer = update challenges ; Arrow = check completion status
struct ChallengesView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var challenges: [Challenge] = []
    
    // a stupid and failed attempt to modify navigation bar, I hate this thing so much it is a nightmare to style OMG
    /*
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.backgroundColor = .systemBackground
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    } */
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(challenges, id: \.self) { challenge in
                    ChallengeRowView(challenge: challenge)
                        .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Challenges")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        Task {
                            guard let user = userVM.user else {
                                return
                            }
                            
                            // honestly we can just leave it to manual instead of time-based
                            
                            try await UserManager.shared.checkChallengeStatus(for: challenges, user: user)
                            
                            // whenever updated we refresh the screen. HOWEVER THIS IS VERY INEFFICIENT since it keeps fetching the database instead of doing it locally, we need to fix it before release
                            self.challenges = try await UserManager.shared.loadChallenges(userId: user.userId)
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise.circle.fill")
                            .font(.headline)
                    }
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    // this will eventually be weekly
                    Button {
                        Task {
                            guard let user = userVM.user else {
                                return
                            }
                            
                            try await UserManager.shared.updateChallenges(userId: user.userId)
                            
                            self.challenges = try await UserManager.shared.loadChallenges(userId: user.userId)
                        }
                    } label: {
                        Image(systemName: "hammer.circle.fill")
                            .font(.headline)
                    }
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .background(Color.gray)
        .onAppear {
            Task {
                if let userId = userVM.user?.userId {
                    self.challenges = try await UserManager.shared.loadChallenges(userId: userId)
                }
            }
        }
    }
}

struct ChallengeRowView: View {
    var challenge: Challenge
    
    var body: some View {
        HStack(alignment: .center) {
            
            // for now we don't have our own aesthetic graphics, so we will use system image of different colors as a compromise
            
            Image(systemName: "medal.fill")
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.trailing, 10)
                .foregroundStyle(LinearGradient(gradient: Gradient(colors: [.yellow, Color(red: 0.8, green: 0.6, blue: 0.2)]), startPoint: .top, endPoint: .bottom))
                
            
            VStack(alignment: .leading, spacing: 5) {
                Text(challenge.title)
                    .font(.headline)
                
                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                Text("XP: \(challenge.xp)")
                    .font(.caption)
                    .fontWeight(.bold)
                    .foregroundColor(Color("blue_dark"))
            }
            
            Spacer()
            
            Image(systemName: challenge.completion ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.trailing, 10)
        }
        .padding(.all, 20)
        .background(challenge.completion ? Color("blue_light").opacity(0.3) : Color(.white))
        // change the display color based on whether it's completed or not
    }
}

#Preview {
    ChallengesView()
        .environmentObject(UserViewModel())
}
