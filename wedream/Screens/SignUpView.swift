//
//  SignUpView.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-31.
//

import SwiftUI

struct SignUpView: View {
    @Binding var showSignUpView: Bool
    @EnvironmentObject var userVM: UserViewModel
        
    var body: some View {
        VStack {
            ProfileForm(userVM: userVM)
        }
    }
}

#Preview {
    SignUpView(showSignUpView: .constant(true))
        .environmentObject(UserViewModel())
}
