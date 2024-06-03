//
//  ChallengesView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI

struct ChallengesView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var challenges: [Challenge] = []
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(challenges, id: \.self) { challenge in
                    ChallengeRowView(challenge: challenge)
                        .listRowInsets(EdgeInsets())
                }
            }
            .navigationTitle("Challenges")
        }
        .onAppear {
            Task {
                if let userId = userVM.user?.userId {
                    self.challenges = try await UserManager.shared.loadChallenges(userId: userId)
                }
            }
        }
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        guard let user = userVM.user else {
                            return
                        }
                        
                        try await UserManager.shared.checkChallengeStatus(for: challenges, user: user)
                    }
                } label: {
                    Image(systemName: "arrow.clockwise.circle.fill")
                        .font(.headline)
                }
            }
            
            // this is just for testing purpose
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    Task {
                        guard let user = userVM.user else {
                            return
                        }
                        
                        try await UserManager.shared.updateChallenges(userId: user.userId)
                    }
                } label: {
                    Image(systemName: "hammer.circle.fill")
                        .font(.headline)
                }
            }
        }
    }
}

struct ChallengeRowView: View {
    var challenge: Challenge
    
    var body: some View {
        HStack(alignment: .top) {
            
            // for now we don't have our own aesthetic graphics, so we will use system image of different colors as a compromise
            
            Image(systemName: "medal.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.trailing, 10)
            
            VStack(alignment: .leading, spacing: 5) {
                Text(challenge.title)
                    .font(.headline)
                
                Text(challenge.description)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("XP: \(challenge.xp)")
                        .font(.caption)
                        .fontWeight(.bold)
                        .foregroundColor(Color("blue_dark"))
                }
                
            }
            Spacer()
            
            Image(systemName: challenge.completion ? "checkmark.square.fill" : "square")
                .resizable()
                .frame(width: 40, height: 40)
                .padding(.trailing, 10)
        }
        .padding(.all, 20)
        .background(challenge.completion ? Color("blue_light") : Color(.white))
        // change the display color based on whether it's completed or not
    }
}

#Preview {
    
    ChallengesView()
        .environmentObject(UserViewModel())
}
