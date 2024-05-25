//
//  ProfileForm.swift
//  wedream
//
//  Created by Boyuan Jiang on 24/5/2024.
//

import SwiftUI

struct ProfileForm: View {
    
    let userVM : UserViewModel
    
    var body: some View {
        Form {
            Section(header: Text("User Settings")) {
                TextField("Name", text: Binding<String>(
                    get: { self.userVM.profileInfo?["name"] as! String },
                    set: { self.userVM.profileInfo?["name"] = $0 }
                ))
                .padding()
                Picker(selection: Binding<String>(
                    get: { self.userVM.profileInfo?["gender"] as! String },
                    set: { self.userVM.profileInfo?["gender"] = $0 }
                ), label: Text("Gender")) {
                    Text("Male").tag("Male")
                    Text("Female").tag("Female")
                    Text("Other").tag("Other")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
            }
            
            Section(header: Text("Health Information")) {
                Stepper(value: Binding<Int>(
                    get: { self.userVM.profileInfo?["sleepGoal"] as! Int },
                    set: { self.userVM.profileInfo?["sleepGoal"] = $0 }
                ), in: 0...24) {
                    Text("Sleep Goal: \(userVM.profileInfo?["sleepGoal"] as! Int)")
                }
                .padding()
            }
            
            Button {
                userVM.updateUserProfile()
            } label: {
                Text("Save Preferences")
            }
        }
    }
}

#Preview {
    ProfileForm(userVM: UserViewModel())
}
