//
//  InputView.swift
//  wedream
//
//  Created by Boyuan Jiang on 4/6/2024.
//

import SwiftUI

struct InputView: View {
    
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack (alignment: .leading, spacing: 12) {
            
            Text(title)
                .foregroundStyle(Color(.darkGray))
                .fontWeight(.semibold)
                .font(.footnote)
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .textContentType(.none)
                    .font(.system(size: 14))
            } else {
                TextField(placeholder, text: $text)
                    .textContentType(.none)
                    .font(.system(size: 14))
            }
            
            Divider()
        }
    }
}

#Preview {
    InputView(text: .constant(""), title: "Hi", placeholder: "Something")
}
