//
//  SignInGoogleHelper.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import UIKit

// like creating a local version of Auth Result do it for Google tokens

struct GoogleSignInResultModel {
    let idToken: String
    let accessToken: String
    let name: String?
    let email: String?
}

final class SignInGoogleHelper {
    
    // since we are finding the viewController it must run on main thread
    
    @MainActor
    func signIn() async throws -> GoogleSignInResultModel {
        
        guard let topVC = topViewController() else {
            throw URLError(.cannotFindHost)
        }

        // wait until Google SDK finishes and run the rest of Firebase Auth

        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)

        guard let idToken: String = gidSignInResult.user.idToken?.tokenString else {
            throw URLError(.badServerResponse)
        }

        let accessToken: String = gidSignInResult.user.accessToken.tokenString
        
        // the gidSignInResult also contains other user info!!
        let name = gidSignInResult.user.profile?.name
        let email = gidSignInResult.user.profile?.email

        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken, name: name, email: email)
        
        return tokens

    }
    
    @MainActor
    func topViewController(controller: UIViewController? = nil) -> UIViewController? {
            
            // deprecated but not a problem for now lol
            let controller = controller ?? UIApplication.shared.keyWindow?.rootViewController
        
            if let navigationController = controller as? UINavigationController {
                return topViewController(controller: navigationController.visibleViewController)
            }
            if let tabController = controller as? UITabBarController {
                if let selected = tabController.selectedViewController {
                    return topViewController(controller: selected)
                }
            }
            if let presented = controller?.presentedViewController {
                return topViewController(controller: presented)
            }
            return controller
        }
    
}

