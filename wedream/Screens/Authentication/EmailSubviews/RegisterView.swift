//
//  RegisterView.swift
//  wedream
//
//  Created by Boyuan Jiang on 4/6/2024.
//

import SwiftUI

@MainActor
final class RegisterViewModel: ObservableObject {
    
    @Published var email : String = ""
    @Published var password : String = ""
    @Published var sleepGoal : Int = 0
    @Published var profileInfo = [
        "name" : "",
        "age" : 0,
        "gender" : ""
    ]
    
    func signUp() async throws {
        guard !email.isEmpty, !password.isEmpty else {
            print("No email or password is found") // need real alert
            return
        }
        
        let authDataResult = try await AuthManager.shared.createUser(email: email, password: password)
        
        let user = DBUser(auth: authDataResult, sleepGoal: sleepGoal)
        
        try await UserManager.shared.createNewUser(user: user, profileInfo: profileInfo)
        
        // try await UserManager.shared.createNewUser(auth: authDataResult)
        
    }
    
}

/// RegisterView is just an overlay on top of LogIn View!! All navigation to point to login view and use the button below to come to register view if necessary
struct RegisterView: View {
    
    // @State private var confirmPassword = "" // not yet done
    @StateObject var viewModel = RegisterViewModel()
    @Binding var showSignInView: Bool
    @Environment(\.dismiss) var dismiss
    @State var name: String = ""
    @State var sleepGoal: Int = 0
    @State var age: Int = 0
    @State var gender: String = ""
    
    var body: some View {
        
        ScrollView {
            
            VStack {
                
                Image("logo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 150, height: 100)
                    .padding(.vertical, 32)
                
                VStack(spacing: 24) {
                    InputView(text: $viewModel.email, title: "Email Address", placeholder: "name@example.com")
                    
                    InputView(text: $name, title: "Name", placeholder: "Enter your name")
                    
                    Picker(selection: $gender, label: Text("Gender")) {
                        Text("Male").tag("Male")
                        Text("Female").tag("Female")
                        Text("Other").tag("Other")
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Stepper(value: $sleepGoal, in: 0...24) {
                        Text("Sleep Goal: \(sleepGoal)")
                            .padding(.bottom, 5)
                        Text("Sleep goal will be used to set the criteria of the streak")
                            .font(.caption)
                    }
                    .padding()
                    Stepper(value: $age, in: 1...100) {
                        Text("Age: \(age)")
                    }
                    .padding()
                    
                    InputView(text: $viewModel.password, title: "Password", placeholder: "Enter your password", isSecureField: true)
                    
                    // ignore confirm password for now
                    /*
                    InputView(text: $confirmPassword, title: "Confirm Password", placeholder: "Confirm your password", isSecureField: false)*/
                }
                .padding(.horizontal)
                .padding(.top, 12)
                
                Button {
                    
                    /*
                    if viewModel.password != confirmPassword {
                        
                        Alert(title: Text("Password does not match! Retry!"))
                        
                        return
                    } */
                    
                    viewModel.sleepGoal = sleepGoal
                    
                    viewModel.profileInfo = [
                        "name" : name,
                        "gender" : gender,
                        "age" : age,
                        "sleep_goal" : sleepGoal
                    ]
                    
                    Task {
                        do {
                            try await viewModel.signUp()
                            showSignInView = false
                            return
                        } catch {
                            print(error)
                        }
                    }
                } label: {
                    HStack {
                        Text("Sign up")
                            .font(.headline)
                        Image(systemName: "arrow.right")
                    }
                    
                }
                .foregroundColor(.white)
                .frame(width: UIScreen.main.bounds.width - 32, height: 50)
                .background(Color.blue)
                .cornerRadius(10)
                .padding(.top, 24)
                
                Spacer()
                
                Button {
                    dismiss()
                } label: {
                    HStack(spacing: 3) {
                        Text("Already have an account?")
                        Text("Log in")
                            .fontWeight(.bold)
                    }
                }
                .padding(.top, 15)
            }
        }
    }
}

#Preview {
    RegisterView(showSignInView: .constant(true))
}
