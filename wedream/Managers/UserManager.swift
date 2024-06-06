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
    var sleepGoal: Int?
    
    // simplifying: creating a convenience initialiser inside here
    init(auth: AuthDataResultModel, sleepGoal: Int? = nil) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoURL
        self.dateCreated = Date()
        self.isPremium = false
        self.weeklyXP = 0
        self.sleepGoal = sleepGoal
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        weeklyXP: Int? = nil,
        sleepGoal: Int? = nil
    ) {
        self.userId = userId
        self.email = email
        self.photoUrl = photoUrl
        self.dateCreated = dateCreated
        self.isPremium = isPremium
        self.weeklyXP = weeklyXP
        self.sleepGoal = sleepGoal
    }
    
    // For method 1 (update struct)
    /*
    func updatePremiumStatus() -> DBUser {
        
        let currentValue = isPremium ?? false
        
        return DBUser(userId: userId, email: email, photoUrl: photoUrl, dateCreated: dateCreated, isPremium: !currentValue)
    } */
    
    /*
    // For method 2 (mutate struct)
    mutating func updatePremiumStatus() {
        let currentValue = isPremium ?? false
        isPremium = !currentValue
    }
    
    /// Calling these mutating functions directly will not work since "user: DBUser" is declared in a class UserVM. So you need to call the function in UserVM that will then call this function
    
    mutating func updateSleepGoal(to newGoal: Int) {
        self.sleepGoal = newGoal
        
    } */
    
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
    
    mutating func updateXp(to newXp: Int) {
        self.weeklyXP = newXp
    }
}

final class UserManager {
    
    static let shared = UserManager()
    private init() { }
    
    let userCollection = Firestore.firestore().collection("users")
    
    func userDocument(userId: String) -> DocumentReference {
        userCollection.document(userId)
    }
    
    // customised encoder needed to change the key case ("dateCreated -> date_created")
    // to avoid complication for most cases we will just use a_b manually for the keys (sad)
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
    
    /// creates new user documents and fields and subcollections (both user, profileInfo, and sleepData). However, only sleepData working now, checked other two raw value no problem. Critical error here MUST BE FIXED
    func createNewUser(user: DBUser, profileInfo: [String: Any]? = nil) async throws {
        
        // set the basic user data
        try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
        
        try await userDocument(userId: user.userId).setData(["sleep_goal": user.sleepGoal ?? 0])
        
        // [String: Any] is not encodable, and we are lazy to make another struct lol
        if let p = profileInfo {
            print("Hello I'm setting profile info?")
            try await userDocument(userId: user.userId).setData(["profile_info": p], merge: false)
        }
        
        // new user loads sleepTime when creating profile, existing user just load sleepTime when loading user (separate function)
        let sleepData = try await loadSleepTime()
        // recall that sleep data itself is a dictionary returned by loadSleepTime()!
        try await userDocument(userId: user.userId).setData(["sleep_data": sleepData])
        
        // now initialise the challenges subcollection and get things going!
        try await updateChallenges(userId: user.userId) // update challenges
        
        // userDocument(userId: user.userId).collection("leaderboard").addDocuments(...)
        
        // also add the new user to a leaderboard @FRANK!
    }
    
    /// we will rarely use this with AuthDataResultModel since it provides so little data, we generally convert it first to DBUser and create user in DB together with additional maps/fields we need. DO NOT use this function it probably doesn't work, you MUST use the version with user and profileInfo (which is called in SignUp function)
    func createNewUser(auth: AuthDataResultModel) async throws {
        
        // change the data into the required format (dictionary)
        
        let sleepData = try await loadSleepTime()
        
        var userData: [String: Any] = [
            "user_id" : auth.uid,
            "date_created" : Timestamp(),
            "weekly_xp": 0,
            // this is read by sleep_data map, everything else by DBUser
            "sleep_data": [
                sleepData
            ],
            "sleep_goal": 7
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
        
        // also initialise these two subcollection but they will be filled later
        userDocument(userId: auth.uid).collection("challnges")
        
        try await updateChallenges(userId: auth.uid) // update challenges
        
        userDocument(userId: auth.uid).collection("leaderboard")
        
        // also add the new user to a leaderboard @FRANK!
        
    }
    
    // get the document as a User directly!! (only for DBUser)
    func getUser(userId: String) async throws -> DBUser {
        
        // again, you will need a custom decoder
        try await userDocument(userId: userId).getDocument(as: DBUser.self, decoder: decoder)
    }
    
    /// Used to fetch user profile data or sleep data as dictionaries
    /// The key must be a document key under "user" document, so "profile_data" or "sleep_time"
    func fetchMapFromId(userId: String, key: String) async throws -> [String: Any] {
        
        let snapshot = try await userDocument(userId: userId).getDocument()
        
        // convert the type to a dictoinary & "decode" it
        guard let data = snapshot.data(), let map = data[key] as? [String: Any] else {
            throw URLError(.badServerResponse)
        }
        
        return map
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
    
    /// This single function is capable of handling almost all types of regular database writes, be ware of what data you are passing in though. This CANNOT set data, it only updates existing values
    func updateDatabase(userId: String, key: String, newValue: Any) {
        
        userDocument(userId: userId).updateData([key: newValue])
        
    }
    
    /// This function ATTEMPTS to update locally the environment object userVM  (the DBUser part of it), the profile part will be fetched again for simplicity lol you can discard the result if you just want to update DB?
    @discardableResult
    func updateUserXp(user: DBUser, by xp: Int) -> DBUser {
        
        let newXp = (user.weeklyXP ?? 0) + xp
        userDocument(userId: user.userId).updateData(["weekly_xp" : newXp])
        userDocument(userId: user.userId).updateData(["profile_info.xp" : newXp])
        
        // this is an extremely stupid method since it literally just creates another new massive struct when I just need to change on variable...
        return DBUser(userId: user.userId,
                      email: user.email,
                      photoUrl: user.photoUrl,
                      dateCreated: user.dateCreated,
                      isPremium: user.isPremium,
                      weeklyXP: newXp,
                      sleepGoal: user.sleepGoal)
        
    }
    
    /*
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
        
        let data : [String: Any] = [
            "profile_info": newProfile
        ]
        
        try await userDocument(userId: userId).setData(data)
        
    }
    
    func updateSleepGoal(userId: String, user: DBUser, newGoal: Int) async throws {
        // user.updateSleepGoal(to: newGoal)
        try await userDocument(userId: userId).updateData(["sleep_goal": newGoal])
    }
     */
    
    /// loads sleep data from HealthKit and does two things: update the database with the latest changes AND returns the new change locally
    func loadSleepTime() async throws -> [String: Any]  {
        
        let data = [
            "daily_sleep": 0,
            "weekly_sleep": 0
        ]
        
        // Ask Frank to complete here with HealthKit Stuff??
        
        return data
    }
}
