
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
            List(viewModel.players) { player in
//                NavigationLink(destination: LazyProfileView(userId: player.id)) {//
                    HStack {
                        Text(player.name)
                        Spacer()
                        Text("\(player.score)")
                    }
//                }//
            }
            .navigationTitle("Leaderboard")
        }
    }
}

#Preview {
    HRView()
}
