//
//  HomeView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI

struct HomeView: View {
    
    @EnvironmentObject var userVM: UserViewModel
    
    var body: some View {
        
        NavigationStack {
            
            // Top Navigation Bar
            HStack(alignment: .center, spacing: 60) {
                Spacer()
                NavBarItem(destination: AnyView(StreakView()), title: "Streak", image: "flame.fill")
                NavBarItem(destination: AnyView(XPView()), title: "XP", image: "moonphase.waxing.crescent")
                NavBarItem(destination: AnyView(ProfileView(showSignInView: .constant(false))), title: "Profile", image: "person.crop.circle.fill")
                Spacer()
            }
            .padding(.top, 10)
            .padding(.bottom, 10)
            .background(Color.gray.opacity(0.1))
            
            ZStack {
                
                LinearGradient(
                    gradient: Gradient(colors: [Color("blue_light").opacity(0.7), Color("blue_dark").opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing)
                
                ScrollView {
                    VStack(spacing: 0) {
                        
                        // Welcome Text
                        Text("Hello, \(userVM.profileInfo?["name"] ?? "dreamer")")
                            .font(.title)
                            .fontWeight(.semibold)
                            .foregroundColor(Color("blue_dark"))
                            .padding(.top, 20)
                        
                        Image("moon_icon")
                            .resizable()
                            .scaledToFit()
                            .frame(width: 200, height: 200)
                        
                        // Sleep Time Display
                        // MARK: BIG BUG HERE, cannot run a func to convert TimeInterval to String :cry
                        Text("\(userVM.sleepTime?["daily_sleep"] ?? "00:00")")
                            .font(.system(size: 64))
                            .fontWeight(.black)
                            .foregroundColor(Color("blue_dark"))
                        
                        // Horizontal Scrollable Buttons
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 20) {
                                LargeButton(title: "Challenges", imageName: "flag.filled.and.flag.crossed", destination: AnyView(ChallengesView()))
                                LargeButton(title: "Meditation", imageName: "figure.mind.and.body")
                                LargeButton(title: "Wind down music", imageName: "music.note")
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                        Text("Sleep better tonight!")
                            .font(.title2)
                            .fontWeight(.bold)
                            .padding(.bottom, 5)
                            .foregroundColor(Color("blue_dark"))
                        
                        ScrollView(.horizontal) {
                            HStack (spacing: 26) {
                                if let articleURL = URL(string: "https://newsinhealth.nih.gov/2021/04/good-sleep-good-health") {
                                    ArticleBlockView(title: "Good Sleep for Good Health", imageURL: "https://newsinhealth.nih.gov/sites/nihNIH/files/styles/featured_media_breakpoint-large/public/2021/April/illustration-man-shutting-off-light-getting-bed.jpg?itok=-VyUSDbo", articleURL: articleURL)
                                }
                                
                                if let articleURL = URL(string: "https://www.sleepfoundation.org/how-sleep-works/why-do-we-need-sleep") {
                                    ArticleBlockView(title: "Why do we need sleep?", imageURL: "https://healthmanagement.co.uk/wp-content/uploads/2021/03/Article-Images-01.png", articleURL: articleURL)
                                }
                            }
                        }
                        .padding()
                        
                        // Placeholder for Sleep Analytics Graphs
                        VStack {
                            Text("Sleep Analytics")
                                .font(.title2)
                                .fontWeight(.bold)
                                .padding(.bottom, 5)
                                .foregroundColor(Color("blue_dark"))
                            
                            // This will be where your sleep analytics graphs go
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.gray.opacity(0.2))
                                .frame(height: 200)
                                .overlay(
                                    Text("Graphs will appear here")
                                        .foregroundColor(.secondary)
                                )
                                .padding(.horizontal)
                        }
                        .padding(.top, 20)
                        .padding(.bottom, 20)
                        
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)
                }
                .edgesIgnoringSafeArea(.bottom)
                .toolbar {
                    // Set toolbar to nil to hide it
                    ToolbarItem(placement: .navigationBarTrailing) {
                        EmptyView()
                    }
                }
            
            
            }.ignoresSafeArea()
        }
    }
}

struct NavBarItem : View {
    
    var destination: AnyView
    var title: String
    var image: String
    
    var body: some View {
        
        NavigationLink(destination: destination) {
            VStack {
                Image(systemName: image)
                    .font(.title2)
                Text(title)
                    .font(.footnote)
            }
        }
        
    }
}

struct ArticleBlockView: View {
    let title: String
    let imageURL: String
    let articleURL: URL // URL to the online article
    
    var body: some View {
        VStack {
            AsyncImage(url: URL(string: imageURL)) { phase in
                switch phase {
                case .success(let image):
                    image
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                case .failure:
                    // Placeholder image or error handling
                    Image(systemName: "photo")
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 120, height: 120)
                        .cornerRadius(8)
                case .empty:
                    // Placeholder image or loading indicator
                    ProgressView()
                @unknown default:
                    EmptyView()
                }
            }
            Text(title)
                .font(.headline)
                .foregroundColor(.primary)
                .padding(.top, 8)
        }
        .padding(8)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 3)
        .onTapGesture {
            // Navigate to the online article
            UIApplication.shared.open(articleURL)
        }
    }
}

#Preview {
    HomeView()
        .environmentObject(UserViewModel())
}
