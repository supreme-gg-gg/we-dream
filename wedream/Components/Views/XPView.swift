//
//  XPView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI

struct XPView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        VStack(spacing: 5) {
            Text("You XP gained this week is:")
            Text("\(userVM.profileInfo?["xp"] ?? 0)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(Color.blueDark)
        }
        .onAppear {
            if let user = userVM.user {
                Task {
                    self.userVM.profileInfo = try await UserManager.shared.fetchMapFromId(userId: user.userId, key: "profile_info")
                }
            }
        }
    }
}

#Preview {
    XPView()
        .environmentObject(UserViewModel())
}
