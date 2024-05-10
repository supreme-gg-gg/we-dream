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
    
    var body: some View {
        Button {
            print("pressed")
        } label: {
            Label(title, systemImage: imageName)
        }
        .buttonStyle(.bordered)
        .controlSize(.extraLarge)
        .foregroundColor(Color("blue_light"))
        .tint(Color("blue_dark"))
    }
}

#Preview {
    LargeButton(title: "Test title", imageName: "book.fill")
}
