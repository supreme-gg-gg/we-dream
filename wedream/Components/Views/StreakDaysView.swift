//
//  StreakDaysView.swift
//  HK
//
//  Created by zyf on 2024-06-10.
//

import SwiftUI
import HealthKit

struct StreakDaysView: View {
    @State private var healthStore = HealthStore()
    @State private var sleepDates: [Date] = []
    @State private var errorMessage: String?

    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                HStack{
                    Text("\(sleepDates.count) Days Streak")
                    Image(systemName: "flame")
                        .foregroundColor(.orange)
                }
            }
        }
        .onAppear {
            Task {
                await fetchSleepDaysData()
            }
        }
    }
    
    private func fetchSleepDaysData() async {
        let calendar = Calendar(identifier: .gregorian)
        guard let startDate = calendar.date(from: DateComponents(year: 2024, month: 1, day: 1)) else { return }
        let endDate = Date()
        
        await healthStore.requestAuthorization()
        
        for date in stride(from: startDate, to: endDate, by: 86400) {
            do {
                let sleepHours = try await healthStore.calculateSleep(for: date)
                if sleepHours > 8 {
                    sleepDates.append(date)
                }
            } catch {
                errorMessage = error.localizedDescription
                break
            }
        }
    }
}
