//
//  SplashScreenView.swift
//  wedream
//
//  Created by Boyuan Jiang on 4/6/2024.
//

import SwiftUI

struct SplashScreenView: View {
    @EnvironmentObject var userVM: UserViewModel
    @State var isActive : Bool = false
    @State private var size = 0.8
    @State private var opacity = 0.5
    
    // Customise your SplashScreen here
    var body: some View {
        if isActive {
            RootView()
                .environmentObject(userVM)
        } else {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color("blue_light"), Color("blue_dark")]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing).ignoresSafeArea()
                
                VStack {
                    VStack {
                        Text("WeDream")
                            .font(.largeTitle)
                            .fontWeight(.black)
                            .foregroundStyle(Color.white)
                            .shadow(radius: 3)
                        Text("where dreamers connect")
                            .font(.headline)
                            .italic()
                            .foregroundStyle(Color.white)
                    }
                    .scaleEffect(size)
                    .opacity(opacity)
                    .onAppear {
                        withAnimation(.easeIn(duration: 0.5)) {
                            self.size = 0.9
                            self.opacity = 1.00
                        }
                    }
                }
                .onAppear {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                        withAnimation {
                            self.isActive = true
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    SplashScreenView()
        .environmentObject(UserViewModel())
}
