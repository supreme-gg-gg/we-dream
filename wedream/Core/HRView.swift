
//
//  PlayersView.swift
//  testhr
//
//  Created by zyf on 2024-06-02.
//
/*
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
 */
//
//  CombinedLeaderboardView.swift
//  testhr
//
//  Created by zyf on 2024-06-02.
//

import SwiftUI

struct LeaderboardView: View {
    @StateObject private var viewModel = PlayersViewModel()

    var body: some View {
        NavigationView {
            List(viewModel.players.indices, id: \.self) { index in
                let player = viewModel.players[index]
                let rank = index + 1
                
                NavigationLink(destination: LazyProfileView(userId: player.id)) {
                    HStack {
                        Text(rankSymbol(for: rank))
                            .font(.system(size: 20))
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Text(player.name)
                            .font(.system(size: 20))
                            .padding(.leading, 10)
                        
                        Spacer()
                        
                        Text("\(player.score)")
                            .font(.system(size: 20))
                            .padding(.trailing, 10)
                    }
                    .frame(maxWidth: .infinity, minHeight: 60)
                    .background(
                        RoundedRectangle(cornerRadius: 15)
                            .fill(Color.white)
                            .shadow(color: shadowColor(for: rank), radius: 5, x: 0, y: 5)
                    )
                    .padding(.horizontal)
                    .padding(.vertical, 5)
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Leaderboard")
        }
        .onAppear {
            viewModel.fetchPlayers()
        }
    }

    private func rankSymbol(for rank: Int) -> String {
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return " \(rank)"
        }
    }

    private func shadowColor(for rank: Int) -> Color {
        switch rank {
        case 1: return .yellow
        case 2: return .blue
        case 3: return .orange
        default: return .gray.opacity(0.3)
        }
    }
}

#Preview {
    LeaderboardView()
}


