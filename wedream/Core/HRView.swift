
//
//  PlayersView.swift
//  HRView
//
//  Created by zyf on 2024-06-02.
//
import SwiftUI

struct HRView: View { // build a view in swiftui
    @StateObject private var viewModel = PlayersViewModel() // call playersviewmodel to show players' data

    var body: some View {
        NavigationView {
            //use a nevigation to show the leaderboard
            List {
                ForEach(viewModel.players.indices, id: \.self) { index in
                    let player = viewModel.players[index]
                    let rank = index + 1 // use index to show players' rank

                    NavigationLink(destination: LazyProfileView(userId: player.id)) {// press and go to profile page
                        HStack {
                            Text(rankSymbol(for: rank)) //show players' rank
                                .font(.system(size: 20))
                                .padding(.leading, 10)
                            
                            Spacer()
                            
                            Text(player.name) //show players' name
                                .font(.system(size: 20))
                                .padding(.leading, 10)
                            
                            Spacer()
                            
                            Text("\(player.xp)") //show player's xp / score
                                .font(.system(size: 20))
                                .padding(.trailing, 10)
                        }
                        .frame(maxWidth: .infinity, minHeight: 60)
                        .background(
                            RoundedRectangle(cornerRadius: 15) //a rectangle background
                                .fill(Color.white)
                                .shadow(color: shadowColor(for: rank), radius: 5, x: 0, y: 5) //shadow to make the leaderboard much more beautiful
                        )
                        .padding(.horizontal)
                        .padding(.vertical, 5)
                    }
                }
            }
            .listStyle(PlainListStyle())
            .navigationTitle("Leaderboard")
        }
        .onAppear {
            viewModel.fetchPlayers() // Fetch leaderboard data when view appears
        }
    }

    private func rankSymbol(for rank: Int) -> String { // 1st - 3rd special rank symbol
        switch rank {
        case 1: return "🥇"
        case 2: return "🥈"
        case 3: return "🥉"
        default: return "\(rank)"
        }
    }

    private func shadowColor(for rank: Int) -> Color { // 1st - 3rd special color
        switch rank {
        case 1: return .yellow
        case 2: return .blue
        case 3: return .orange
        default: return .gray.opacity(0.3)
        }
    }
}


#Preview {
    HRView()
}
