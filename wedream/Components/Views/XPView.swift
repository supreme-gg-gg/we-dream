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
        ZStack {
            // Background Gradient
            LinearGradient(
                gradient: Gradient(colors: [Color.white, Color.blue.opacity(0.2)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                
                Spacer()
                // Title with Icon
                HStack {
                    Image(systemName: "star.circle.fill")
                        .resizable()
                        .frame(width: 40, height: 40)
                        .foregroundColor(.yellow)
                    Text("XP Gained This Week")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.blue)
                }
                
                Spacer()

                Text("\(userVM.profileInfo?["xp"] ?? 0)")
                    .font(.system(size: 60, weight: .bold, design: .rounded))
                    .foregroundColor(.blue)
                    .background(
                        ZStack {
                            Circle()
                                .fill(Color.blue.opacity(0.1))
                                .frame(width: 150, height: 150)
                            Circle()
                                .stroke(Color.blue, lineWidth: 4)
                                .frame(width: 170, height: 170)
                        }
                    )
                    .shadow(color: .blue.opacity(0.3), radius: 10, x: 0, y: 5)
                    .padding(.bottom, 50)
                
                Text("Keep up the great work!")
                    .font(.headline)
                    .foregroundColor(.gray)
                
                Spacer()
                
                // Decorative Shape
                ZStack {
                    RoundedRectangle(cornerRadius: 20)
                        .fill(Color.blue.opacity(0.1))
                        .frame(height: 100)
                        .padding(.horizontal)
                        .shadow(color: .blue.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    HStack {
                        Image(systemName: "arrow.up.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .foregroundColor(.green)
                        
                        Text("Level up by gaining more XP!")
                            .font(.headline)
                            .foregroundColor(.blue)
                            .padding(.leading, 10)
                    }
                }
                
                Spacer()
            }
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
