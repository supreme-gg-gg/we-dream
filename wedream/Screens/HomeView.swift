//
//  HomeView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI

struct HomeView: View {
    
    var body: some View {
        
        NavigationStack {
            
            HStack {
                Spacer()
                NavigationLink(destination: StreakView()) {
                    Image(systemName: "flame.fill")
                    Text("Streak")
                }.padding()
                    
                Spacer()
                NavigationLink(destination: XPView()) {
                    Image(systemName: "moonphase.waxing.crescent.inverse")
                    Text("XP")
                }.padding()
                    
                Spacer()
                NavigationLink(destination: ProfileView(showSignInView: .constant(false))) {
                    Image(systemName: "person.crop.circle.fill")
                }.padding()
                    
                Spacer()
                    
            }.background(Color.gray.opacity(0.1))
            
            VStack (spacing: 0){
                Text("Hello, user")
                    .font(.title)
                    .fontWeight(.semibold)
                    .foregroundColor(Color("blue_light"))
                    .padding(.top)
                    .alignmentGuide(.leading, computeValue: { dimension in
                        return 0
                    }) // doesn't work huh??
                
                Spacer()
                
                Text("10:00")
                    .font(.largeTitle)
                    .fontWeight(.black)
                    .foregroundColor(.white)
                
                Spacer()
                
                ScrollView(.horizontal) {
                    HStack {
                        LargeButton(title: "Challenges", imageName: "flag.filled.and.flag.crossed")
                        LargeButton(title: "Meditation", imageName: "figure.mind.and.body")
                        LargeButton(title: "Wind down music", imageName: "music.note")
                    }
                }
                
                Spacer()
            }
            .ignoresSafeArea(edges: .bottom)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.gray.opacity(0.1))
             //.background(Image("home_bg").resizable().scaledToFill().clipped().opacity(0.8))
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
}
