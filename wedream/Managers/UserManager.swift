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
    var email: String?
    let photoUrl: String?
    let dateCreated: Date?
    var isPremium: Bool?
    var weeklyXP: Double?
    var sleepGoal: Int? // sleepGoal and other sensitive health preferences will always only be part of your PRIVATE profile, never shown to the PUBLIC
    
    // simplifying: creating a convenience initialiser inside here
    init(auth: AuthDataResultModel, sleepGoal: Int? = nil) {
        self.userId = auth.uid
        self.email = auth.email
        self.photoUrl = auth.photoURL
        self.dateCreated = Date()
        self.isPremium = false
        self.weeklyXP = 0.0
        self.sleepGoal = sleepGoal
    }
    
    init(
        userId: String,
        email: String? = nil,
        photoUrl: String? = nil,
        dateCreated: Date? = nil,
        isPremium: Bool? = nil,
        weeklyXP: Double? = nil,
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
    
    /*
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
    } */
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
    /// when you are using the .setData() function from Firebase, REMEBER to turn on "merge: true" or else it basically removes whatever fields were originally in the document
    func createNewUser(user: DBUser, profileInfo: [String: Any]? = nil) async throws {
        
        var mutableUser = user
        var mutableProfile = profileInfo
        
        // tested that all input for the function are valid, data is fine!
        
        // new user loads sleepTime when creating profile, existing user just load sleepTime when loading user (separate function)
        let result = await loadSleepTime(userId: user.userId, isNewUser: true)
        let sleepData = result.0
        // recall that sleep data itself is a dictionary returned by loadSleepTime()!
        try await userDocument(userId: user.userId).setData(["sleep_data": sleepData], merge: true)
    
        mutableProfile?["xp"] = result.1
        mutableUser.weeklyXP = result.1
        
        // set the basic user data
        // try userDocument(userId: user.userId).setData(from: user, merge: false, encoder: encoder)
        
        do {
            
            try userDocument(userId: user.userId).setData(from: mutableUser, merge: true, encoder: encoder)
            
            try await userDocument(userId: user.userId).setData(["sleep_goal": mutableUser.sleepGoal ?? 0], merge: true)
            
            // [String: Any] is not encodable, and we are lazy to make another struct lol
            if let p = mutableProfile {
                try await userDocument(userId: user.userId).setData(["profile_info": p], merge: true)
            }
            
            print("User data for \(user.userId) set successfully.")
            
        } catch {
            print("Error setting user data: \(error)")
            throw error
        }
        
        // now initialise the challenges subcollection and get things going!
        try await updateChallenges(userId: user.userId) // update challenges
        
        // userDocument(userId: user.userId).collection("leaderboard").addDocuments(...)
    }
    
    /// we will rarely use this with AuthDataResultModel since it provides so little data, we generally convert it first to DBUser and create user in DB together with additional maps/fields we need. DO NOT use this function it probably doesn't work, you MUST use the version with user and profileInfo (which is called in SignUp function)
    func createNewUser(auth: AuthDataResultModel) async throws {
        
        // change the data into the required format (dictionary)
        
        let sleepData = await loadSleepTime(userId: auth.uid, isNewUser: true)
        
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
    
    /// This function works with ALL IN-APP XP updates, so that does not count sleep data xp which is handled by loadSleepData. It returns an xp for userVM update
    // @discardableResult
    func updateUserXp(user: DBUser, by xp: Double) -> Double {
        
        print(user.weeklyXP)
        let newXp = (user.weeklyXP ?? 0) + xp
        print(newXp)
        userDocument(userId: user.userId).updateData(["weekly_xp" : newXp])
        userDocument(userId: user.userId).updateData(["profile_info.xp" : newXp])
        
        return newXp
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
    
    /// UPDATES sleep data from HealthKit and does two things: update the database with the latest changes AND returns the new change locally. Note that it doesn't only load from HK, but also "updates" (i.e. adds to or clears) the original data from the database and refreshes it. This function should actually be split into two by parameter number one of new user one for regulat LOL. The function also rewards XP directly whenever it is called, since it is only called at the app opens.
    func loadSleepTime(userId: String, isNewUser: Bool = false) async -> ([String: Double], Double) {
        
        // MARK: MISSING REWARD XP EVERY TIME THIS FUNCTION RUNS BASED ON THE NEW DAILY SLEEP!!!
        
        // if new user then initialise or else just read original from DB
        // quite dumb but for the purpose of fetching we must first use [String: Any] and THEN convert it to [String: Double] to return and process it (:cry)
        
        // gets data for today's date (i.e. last night's sleep)
        let sleepData = await HealthStore.shared.fetchSleepData()

        let data : [String: Double] = [
            "daily_sleep": sleepData?.todayDuration ?? 0.0,
            "weekly_sleep": sleepData?.totalDuration ?? 0.0
        ]
        
        let weeklyNewXP = (data["weekly_sleep"] ?? 0.0) / 3600 * 10
        
        if isNewUser {
            
            // for new user just get today and it's done, create func will update DB
            return (data, weeklyNewXP)
            
        } else {
            
            // fetchSleepData doesn't need to read from DB anymore, get whole week directly!
            // You don't even need to clear weekly record manually lmao
            /* var data = try await fetchMapFromId(userId: userId, key: "sleep_data")
            
            guard var dataDouble = data as? [String: Double] else {
                return [:]
            } */
            
            // now let's send it to the database, and at the same time just update the XP when the app opens LOL saves time
            // get old XP here??????
            UserManager.shared.updateDatabase(userId: userId, key: "sleep_data", newValue: data)
            UserManager.shared.updateDatabase(userId: userId, key: "weekly_xp", newValue: weeklyNewXP)
            UserManager.shared.updateDatabase(userId: userId, key: "profile_info.xp", newValue: weeklyNewXP)
            
            // and return the value back to be received LOCALLY
            return (data, weeklyNewXP)
        }
    }
}
