//
//  StreakView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//


import SwiftUI
import HealthKit

struct StreakDaysView: View {
    // @State private var healthStore = HealthStore()
    @State private var selectedDate = Date()
    @State private var sleepData: SleepData?
    @State private var todaySleep : TimeInterval?
    @State private var weekSleep : TimeInterval?

    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
            
            Button("Fetch Sleep Data") {
                Task {
                    self.sleepData = await HealthStore.shared.fetchSleepData(forDate: selectedDate)
                    
                    /*
                    HealthStore.shared.fetchSleepData(forDate: selectedDate) { totalSleepDuration, todaySleepDuration, error in
                        if let error = error {
                            print("Error fetching sleep data: \(error.localizedDescription)")
                        } else {
                            if let totalSleepDuration = totalSleepDuration {
                                print("Total sleep duration this week (in seconds): \(totalSleepDuration)")
                                self.weekSleep = totalSleepDuration
                            }
                            
                            if let todaySleepDuration = todaySleepDuration {
                                print("Sleep duration today (in seconds): \(todaySleepDuration)")
                                self.todaySleep = todaySleepDuration
                            }
                        }
                    } */
                    // try await healthStore.calculateSleep(for: selectedDate)
                    // sleepData = healthStore.sleepData
                }
            }
        }
        .padding()
        
        if let sleepData = sleepData {
            VStack {
                Text("Date: \(selectedDate, formatter: dateFormatter)")
                    .foregroundColor(getColor(for: sleepData.todayDuration))
                Text("Last Night's Sleep: \(formattedTime(duration: sleepData.todayDuration))")
                    .foregroundColor(getColor(for: sleepData.todayDuration))
                Text("Total Sleep This Week: \(formattedTime(duration: sleepData.totalDuration))")
                    .foregroundColor(getColor(for: sleepData.todayDuration))
            }
        }
        
        /*
        if let todaySleep = todaySleep, let weekSleep = weekSleep {
            VStack {
                Text("Date: \(selectedDate, formatter: dateFormatter)")
                    .foregroundColor(getColor(for: todaySleep))
                Text("Total sleep this week: \(formattedTime(duration: weekSleep))")
                    .foregroundColor(getColor(for: todaySleep))
                Text("Last night's sleep: \(formattedTime(duration: todaySleep))")
                    .foregroundColor(getColor(for: todaySleep))
            }
        } */
    }

    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }
    
    private func formattedTime(duration: TimeInterval) -> String {
        let hours = Int(duration) / 3600
        let minutes = Int(duration) % 3600 / 60
        return String(format: "%02d:%02d", hours, minutes)
    }
    
    private func getColor(for duration: TimeInterval) -> Color {
        
        let sleepHours = duration / 3600
        let threshold = 8.0 * 0.8
        
        if sleepHours >= threshold {
            return .green
        }
        else if sleepHours >= 8.0 * 0.5 {
            return .yellow
        }
        else {
            return .red
        }
    }
}

#Preview {
    StreakDaysView()
}



