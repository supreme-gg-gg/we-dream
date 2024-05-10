//
//  User.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import Foundation

struct User : Hashable {
    
    var name: String
    var email: String
    var username: String
    var id = UUID()
    var password: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    /*
    static func == (lhs: Self, rhs: Self) {
        lhs.id = rhs.id
    } */
    
    // more code to include dynamic data from healthkit?
    
}

extension User {
    
    func healthData() {
        // do something
    }
    
}

// sample user data, Firebase will be connected over the weekend

struct Users {
    var users = [User(name: "Jet Chiang", email: "jetjiang.ez@gmail.com", username: "supreme-gg", password: "12345678")]
}
