//
//  ProfileForm.swift
//  wedream
//
//  Created by Boyuan Jiang on 24/5/2024.
//

import SwiftUI

struct ProfileForm: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var name: String = ""
    @State var sleepGoal: Int = 0
    @State var age: Int = 0
    @State var gender: String = ""
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                
                Section(header: Text("User Settings")) {
                    
                    TextField("Your name", text: $name)
                    .padding()
                    
                    VStack(alignment: .leading) {
                        Text("Pick your gender")
                            .font(.caption)
                            .foregroundStyle(Color(.gray))
                            .padding(.bottom, 10)
                        Picker(selection: $gender, label: Text("Gender")) {
                            Text("Male").tag("Male")
                            Text("Female").tag("Female")
                            Text("Other").tag("Other")
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding()
                    
                    Stepper(value: $age, in: 1...100) {
                        Text("Age: \(age)")
                    }
                    .padding()
                    
                }
                
                Section(header: Text("Health Information")) {
                    
                    Stepper(value: $sleepGoal, in: 0...24) {
                        Text("Sleep Goal: \(sleepGoal)")
                            .padding(.bottom, 5)
                        Text("Sleep goal will be used to set the criteria of the streak")
                            .font(.caption)
                    }
                    .padding()
                    
                    Text("More to come including customised start and end sleep time and other customisation features")
                        .font(.caption)
                        .padding()
                    
                    /* SliderView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity) // Define maximum dimensions
                        .aspectRatio(contentMode: .fill) // Maintain aspect ratio if needed
                        .clipped() */
                    
                }
                
                Button {
                    
                    // first update local data
                    userVM.profileInfo?["name"] = name
                    userVM.profileInfo?["gender"] = gender
                    userVM.profileInfo?["age"] = age
                    userVM.user?.sleepGoal = sleepGoal
                    
                    guard let userId = userVM.user?.userId else {
                        print("Invalid User ID")
                        return
                    }
                    
                    // then update database record
                    UserManager.shared.updateDatabase(userId: userId, key: "sleep_goal", newValue: sleepGoal)
                    
                    if let profileInfo = userVM.profileInfo {
                        UserManager.shared.updateDatabase(userId: userId, key: "profile_info", newValue: profileInfo)
                    } else {
                        print("Profile info is nil")
                    }
                    
                    // local updating is fully working, there is no need to fetch again from database!!! Let's do sth similar with the xp system and we're done!
                
                } label: {
                    Text("Save Preferences")
                }
            }
            .navigationTitle("Profile Update")
            .onAppear {
                if let profileInfo = userVM.profileInfo {
                    name = profileInfo["name"] as? String ?? ""
                    age = profileInfo["age"] as? Int ?? 0
                    gender = profileInfo["gender"] as? String ?? ""
                }
                
                if let user = userVM.user {
                    sleepGoal = user.sleepGoal ?? 0
                }
            }
        }
    }
}

struct EmailUpdateForm: View {
    
    @EnvironmentObject var userVM: UserViewModel
    @State var email: String = ""
    @State var password: String = ""
    
    var body: some View {
        
        NavigationStack {
            
            Form {
                    
                TextField("New email", text: $email)
                    .padding()
                
                SecureField("New password", text: $password)
                    .padding()
                    
                Text("You would not be immediately logged out but changes will take effect next time you log in.")
                    .font(.caption)
                    .padding()
                
                Button {
                    
                    userVM.updateEmail(to: email)
                    
                    guard let userId = userVM.user?.userId else {
                        print("Invalid User ID")
                        return
                    }
                    
                    Task {
                        try await AuthManager.shared.updateEmail(email: email)
                        try await AuthManager.shared.updatePassword(password: password)
                    }
                    
                    // then update database record
                    UserManager.shared.updateDatabase(userId: userId, key: "email", newValue: email)
                
                } label: {
                    Text("Update email or password")
                }
            }
            .navigationTitle("Email and Password Update")
            .onAppear {
                if let user = userVM.user {
                    self.email = user.email ?? ""
                }
            }
            
        }
    }
}

#Preview {
    ProfileForm()
    // EmailUpdateForm()
        .environmentObject(UserViewModel())
}
