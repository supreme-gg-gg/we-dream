//
//  ProfileForm.swift
//  wedream
//
//  Created by Boyuan Jiang on 24/5/2024.
//

import SwiftUI

struct ProfileForm: View {
    
    var userVM : UserViewModel
    @State var age: Int = 0
    @State var sleepGoal : Int = 0
    
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
            }
            
            Section(header: Text("Customise Schedule")) {
                SliderView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity) // Define maximum dimensions
                    .aspectRatio(contentMode: .fill) // Maintain aspect ratio if needed
                    .clipped()
            }
            
            Button {
                userVM.profileInfo?["age"] = age
                userVM.profileInfo?["sleep_goal"] = sleepGoal
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
