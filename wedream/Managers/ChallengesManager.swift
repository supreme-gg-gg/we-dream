//
//  Challenges.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-31.
//

import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

struct Challenge : Codable, Hashable {
    let challengeId: String
    let title: String
    let description: String
    let xp: Int
    let completion: Bool // True means completed
    let criteria: String // a code that maps to a function
}

// these functions are all for challenges
extension UserManager {
    
    private func userChallenges(userId: String) -> CollectionReference {
        userCollection.document(userId).collection("Challenges")
    }
    
    // call this once a week to update challenges
    func updateChallenges(userId: String) async throws {
        
        let userChallenges = userChallenges(userId: userId)
        
        let challengesRef = Firestore.firestore().collection("Challenges")
        
        // use a list of ids to present the total challenges
        var challenges: [String] = []
        
        // yes this is quite dumb but it dynamically gets all challenges LOL
        let querySnapshot = try await challengesRef.getDocuments()
        for document in querySnapshot.documents {
            challenges.append(document.documentID)
        }
        
        // randomly select 4
        let shuffledChallenges = challenges.shuffled()
        let selectedChallenges = Array(shuffledChallenges.prefix(4))
        
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
        let challengesRef = Firestore.firestore().collection("Challenges")
        
        var activeChallenges: [Challenge] = []
        
        let querySnapshot = try await userChallenges.getDocuments()
        for document in querySnapshot.documents {
            
            let data = document.data()
            let challenge = try await challengesRef.document(data["challenge_ref"] as! String).getDocument(as: Challenge.self, decoder: decoder)
            activeChallenges.append(challenge)
            
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
                try await userDocument(userId: user.userId).updateData(["weekly_xp": newXp ?? 0])
                
            }
        }
    }
    
}

class ChallengesCompletionHandler {
        
    static let shared = ChallengesCompletionHandler()
    
    private init() {}
    
    func checkCompletion(for challenge: Challenge) -> Bool {
        switch challenge.criteria {
            
        case "Sleep":
            return checkSleepCompletion(challenge)
            
        case "Phone":
            return checkPhoneCompletion(challenge)
            
        case "Rest":
            return checkRestCompletion(challenge)
            
        default:
            return false
            
        }
    }
    
    private func checkSleepCompletion(_ challenge: Challenge) -> Bool {
        
        // this uses Frank's code to read how much sleep the person got that night
        // finds when does the person goes to sleep ?
        // or find how long he has slept
        
        return true
    }
    
    private func checkPhoneCompletion(_ challenge: Challenge) -> Bool {
        
        // obtains the screentime during the target time
        
        return true
    }
    
    private func checkRestCompletion(_ challenge: Challenge) -> Bool {
        
        // check if they slept for a total of xx hours that week?
        
        return true
    }
}
