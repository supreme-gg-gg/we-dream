//
//  Content.swift
//  wedream
//
//  Created by Jet Chiang on 2024-06-03.
//

import SwiftUI

struct Content: View {
    var body: some View {
        Text("Duration: \(formatDuration(125))")
            .padding()
    }
    
    func formatDuration(_ duration: Int) -> String {
        if duration == 0 {
            return "00:00"
        }
        let minutes = duration / 60
        let seconds = duration % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}

#Preview {
    Content()
}
