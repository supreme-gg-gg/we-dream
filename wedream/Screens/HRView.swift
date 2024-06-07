
//
//  PlayersView.swift
//  testhr
//
//  Created by zyf on 2024-06-02.
//
import SwiftUI

struct HRView: View {
    @StateObject private var viewModel = PlayersViewModel()

    var body: some View {
        NavigationView {
            List {
                ForEach(viewModel.players, id: \.id) { player in
                    NavigationLink(destination: LazyProfileView(userId: player.id)) {
                        HStack {
                            Text(player.name)
                            Spacer()
                            Text("\(player.xp)")
                        }
                    }
                }
            }
            .navigationTitle("Leaderboard")
        }
        .onAppear {
            viewModel.fetchPlayers() // Fetch leaderboard data when view appears
        }
    }
}

#Preview {
    HRView()
}
