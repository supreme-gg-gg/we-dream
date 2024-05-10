//
//  HomeView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI

struct HomeView: View {
    var body: some View {
        
        TabView {
            
            Text("let EuclidChampion2024 = 'Frank Zhang'")
                .tabItem {
                    Image(systemName: "list.number")
                    Text("Honour Roll")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Profile")
                }
            
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
                    NavigationLink(destination: ProfileView()) {
                        Image(systemName: "person.crop.circle.fill")
                    }.padding()
                        
                    Spacer()
                        
                }
                // .background(Color("gray_light"))
                
                // ScrollView { vertical scroll need fix
                    VStack {
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
                                LargeButton(title: "Challenges", imageName: "trophy.fill")
                                LargeButton(title: "Leaderboard", imageName: "list.number")
                                LargeButton(title: "Clan Battle", imageName: "shield.lefthalf.filled")
                            }
                        }
                        
                        
                        Spacer()
                    }
                    .ignoresSafeArea(edges: .bottom)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Image("home_bg").resizable().scaledToFill().clipped().opacity(0.8))
                // }
            }
            .tabItem {
                Label("Home", systemImage: "house.fill")
            }
                    
                
            ChallengesView()
                .tabItem {
                    Image(systemName: "trophy.fill")
                    Text("Challenges")
                }
            
            Text("Social page")
                .tabItem {
                    Image(systemName: "person.3.sequence.fill")
                    Text("Social")
                }
            
        }
    }
}

#Preview {
    HomeView()
}
