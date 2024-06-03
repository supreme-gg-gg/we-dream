//
//  UserManager.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-20.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// collection -> documents (can then embed collections again)... explore at console

struct DBUser: Codable {
    let userId: String
    let email: String?
    let photoUrl: String?
    let dateCreated: Date?
    var isPremium: Bool?
    var weeklyXP: Int?
    
    // simplifying: creating a convenience initialiser inside here
    init(auth: AuthDataResultModel) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoURL
        self.dateCreated = Date()
        self.isPremium = false
        self.weeklyXP = 0
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        weeklyXP: Int
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.weeklyXP = weeklyXP
    }
    
    // For method 1 (update struct)
    /*
    func updatePremiumStatus() -> DBUser {
        
        let currentValue = isPremium ?? false
        
        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated, isPremium: !currentValue)
    } */
    
    // For method 2 (mutate struct)
    mutating func updatePremiumStatus() {
        let currentValue = isPremium ?? false
        isPremium = !currentValue
    }
    
    /// ignore this for now, I used another method below in UserManager for instant update
    /// I might return to this later in case we figured out a way to store data locally efficiently :)
    mutating func updateXP(by: Int, clear: Bool?) -> Int? {
        if (clear ?? false) {
            weeklyXP = 0
            return weeklyXP
        }
        var currentXP = weeklyXP ?? 0
        currentXP += by
        weeklyXP = currentXP
        return weeklyXP
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    let userCollection = Firestore.firestore().collection("users")
    
    func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    let encoder: Firestore.Encoder = {
        let encoder = Firestore.Encoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase
        return encoder
    }()
    
    let decoder: Firestore.Decoder = {
        let decoder = Firestore.Decoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return decoder
    }()
    
    // same function but push the user itself rather than creating dictionary!
    func createNewUser(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
        
        // customised encoder needed to change the key case ("dateCreated -> date_created")
    }
    
    func createNewUser(auth: AuthDataResultModel) async throws {
        
        // change the data into the required format (dictionary)
        var userData: [String: Any] = [
            "user_id" : auth.uid,
            "date_created" : Timestamp(),
            "weeklyXP": 0
        ]
        
        // take care about optionals
        if let email = auth.email {
            userData["email"] = email
        }
        if let photoURL = auth.photoURL {
            userData["photo_url"] = photoURL
        }
        
        // "set" data will override but "update" only adds fields
        try await userDocument(userId: auth.uid).setData(userData, merge: false)
        
    }
    
    // get the document as a User directly!!
    func getUser(userId: String) async throws -> DBUser {
        // again, you will need a custom decoder
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }
    
    /*
    func getUser(userId: String) async throws -> DBUser {
        
        let snapshot = try await userDocument(userId: userId).getDocument()
        
        // convert the type to a dictoinary & "decode" it
        guard let data = snapshot.data(), let userId = data["user_id"] as? String else {
            throw URLError(.badServerResponse)
        }
        
        let email = data["email"] as? String
        let photoURL = data["photo_url"] as? String
        let dateCreated = data["date_created"] as? Date // decode as Swift Date
        
        return DBUser(userId: userId, email: email, photoUrl: photoURL, datCreated: dateCreated)
    } */
    
    /*
    func updateUserPremiumStatus(user: DBUser) async throws {
        try userDocument(userId: user.userId).setData(from: user, merge: true, encoder: encoder)
    } */
    
    // a better solution: update only the changed field
    func updateUserPremiumStatus(userId: String, isPremium: Bool) async throws {
        
        let data: [String: Any] = [
            "is_premium" : isPremium
        ]
        
        try await userDocument(userId: userId).updateData(data)
    }
    
    func updateWeeklyXP(userId: String, weeklyXP: Int) async throws {
        
        let data: [String: Any] = [
            "weekly_xp" : weeklyXP
        ]
        
        try await userDocument(userId: userId).updateData(data)
        
    } // the next problem -- where to call this function and WHEN??
    
    func updateProfile(userId: String, newProfile: [String: Any]) async throws {
        
        try await userDocument(userId: userId).updateData(newProfile)
        
    }
}
