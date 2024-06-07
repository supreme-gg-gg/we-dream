//
//  player.swift
//  testhr
//
//  Created by zyf on 2024-06-02.
//

import Foundation
import Combine

// I quite like this simple structure for fetching the players
// Found a way to keep it by modifying the return value from backend code instead

struct Player: Identifiable, Codable {
    var id: String
    var name: String
    var xp: Int
}

class PlayersViewModel: ObservableObject {
    @Published var players: [Player] = []

    private var cancellables = Set<AnyCancellable>()

    init() {
        fetchPlayers()
    }

    func fetchPlayers() {
        guard let url = URL(string: "http://localhost:3000/leaderboard") else {
            return
        }

        URLSession.shared.dataTaskPublisher(for: url)
            .map { $0.data }
            .decode(type: [Player].self, decoder: JSONDecoder())
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("Error fetching players: \(error)")
                }
            }, receiveValue: { [weak self] players in
                self?.players = players
            })
            .store(in: &cancellables)
    }
}
