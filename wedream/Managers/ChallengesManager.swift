//
//  Challenges.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-31.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

// decode the public challenge fields to this
struct publicChallenge : Codable {
    let challengeId: String
    let title: String
    let description: String
    let xp: Int
    let criteria: String
}

// then initialise this with private completion status and above struct
struct Challenge : Hashable {
    let challengeId: String
    let title: String
    let description: String
    let xp: Int
    let completion: Bool // True means completed
    let criteria: String // a code that maps to a function
    
    init(data: publicChallenge, status: Bool) {
        self.challengeId = data.challengeId
        self.title = data.title
        self.description = data.description
        self.xp = data.xp
        self.criteria = data.criteria
        self.completion = status
    }
}

// these functions are all for challenges
extension UserManager {
    
    private func userChallenges(userId: String) -> CollectionReference {
        userCollection.document(userId).collection("challenges")
    }
    
    /// call this once a week to update challenges, the function has passed testing and proved to be WORKING WELL!
    func updateChallenges(userId: String) async throws {
        
        let userChallenges = userChallenges(userId: userId)
        
        let challengesRef = Firestore.firestore().collection("challenges")
        
        // use a list of ids to present the total challenges
        var challenges: [String] = []
        
        // yes this is quite dumb but it dynamically gets all challenges LOL
        let querySnapshot = try await challengesRef.getDocuments()
        for document in querySnapshot.documents {
            challenges.append(document.documentID)
        }
        
        // randomly select 2
        let shuffledChallenges = challenges.shuffled()
        let selectedChallenges = Array(shuffledChallenges.prefix(2))
        
        for challenge in selectedChallenges {
            
            let challengeData: [String: Any] = [
                "challenge_id": challenge,
                "challenge_ref": "/challenges/\(challenge)",
                "completion": false,
                "deadline": dateOneWeekFromToday()
            ]
            
            userChallenges.addDocument(data: challengeData) { error in
                if let error = error {
                    print("Error adding document: \(error)")
                } else {
                    print("Document added successfully")
                }
            }
        }
    }
    
    func loadChallenges(userId: String) async throws -> [Challenge] {
        
        let userChallenges = userChallenges(userId: userId)
        let challengesRef = Firestore.firestore().collection("challenges")
        
        var activeChallenges: [Challenge] = []
        
        let querySnapshot = try await userChallenges.getDocuments()
        for document in querySnapshot.documents {
            
            let data = document.data()
            
            guard let challengeRef = data["challenge_ref"] as? String,
                  let completion = data["completion"] as? Bool else {
                continue
            }
            
            let publicChallenge = try await challengesRef.document(challengeRef).getDocument(as: publicChallenge.self, decoder: decoder)
            
            // a user challenge has two components, one that is stored publicly in the "library" and constant, and one that is personalised (e.g. completion time, status, deadline, customisation...)
            activeChallenges.append(Challenge(data: publicChallenge, status: completion))
            
        }
        
        return activeChallenges
    }
    
    // let's just update these once a day or manually
    func checkChallengeStatus(for challenges: [Challenge], user: DBUser) async throws {
        
        for challenge in challenges {
            
            if ChallengesCompletionHandler.shared.checkCompletion(for: challenge) {
                
                let challengeId = challenge.challengeId
                try await userChallenges(userId: user.userId).document(challengeId).updateData(["completion": true])
                
                // there is a mutating function inside the user class, but there have been problems with mutability in using that one
                let newXp = (user.weeklyXP ?? 0) + challenge.xp
                try await userDocument(userId: user.userId).updateData(["weekly_xp": newXp])
                
            }
        }
    }
    
}

class ChallengesCompletionHandler {
        
    static let shared = ChallengesCompletionHandler()
    
    private init() {}
    
    func checkCompletion(for challenge: Challenge) -> Bool {
        switch challenge.criteria {
            
        // Type A = sleep before a certain time?
        case "TypeA":
            return checkTypeACompletion(challenge)
            
        // Type B = minimise screen time to one hour after 10 pm?
        case "TypeB":
            return checkTypeBCompletion(challenge)
            
        // Type C = sleep for more than 50 hours a week
        case "TypeC":
            return checkTypeCCompletion(challenge)
            
        default:
            return false
            
        }
    }
    
    private func checkTypeACompletion(_ challenge: Challenge) -> Bool {
        
        // this uses Frank's code to read how much sleep the person got that night
        // finds when does the person goes to sleep ?
        // or find how long he has slept
        
        if challenge.completion {
            return false // for testing I made it a toggle lol
        }
        
        return true
    }
    
    private func checkTypeBCompletion(_ challenge: Challenge) -> Bool {
        
        // obtains the screentime during the target time
        
        if challenge.completion {
            return false
        }
        
        return true
    }
    
    private func checkTypeCCompletion(_ challenge: Challenge) -> Bool {
        
        // check if they slept for a total of xx hours that week?
        
        if challenge.completion {
            return false
        }
        
        return true
    }
}
