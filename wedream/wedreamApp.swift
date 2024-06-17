//
//  wedreamApp.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-06.
//

import SwiftUI
import FirebaseCore

class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()
    print("FirebaseApp Configured")

    return true
  }
}

@main
struct YourApp: App {
   
  @StateObject private var userVM = UserViewModel()
    
  // register app delegate for Firebase setup
  @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate

  var body: some Scene {
    WindowGroup {
      SplashScreenView()
        .environmentObject(userVM)
        /*
        .onAppear {
            Task {
                try await userVM.loadCurrentUser()
            }
        } */
    }
  }
}
