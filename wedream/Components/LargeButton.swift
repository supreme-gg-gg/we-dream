//
//  LargeButton.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI

struct LargeButton: View {
    
    var title: String
    var imageName: String
    var destination: AnyView?
    
    var body: some View {
        NavigationLink (destination: destination ?? AnyView(HomeView(showSignInView: .constant(false)))){
            Button {
                print("pressed")
            } label: {
                Label(title, systemImage: imageName)
            }
            .buttonStyle(.bordered)
            .controlSize(.extraLarge)
            .foregroundColor(Color("blue_dark"))
            .tint(Color(.white))
        }
    }
}

#Preview {
    LargeButton(title: "Test title", imageName: "book.fill", destination: AnyView(HomeView(showSignInView: .constant(false))))
}
