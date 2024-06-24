//
//  StreakView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

import SwiftUI
import HealthKit

struct StreakView: View {
    
    @State private var healthStore = HealthStore()
    
    @EnvironmentObject var userVM: UserViewModel
    
    @State private var date = Date.now
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    @State private var sleepArr: [Date: Double] = [:]
    @State private var sleepDates: [Date] = []
    
    @State private var limit: Double = 0.0
    
    @State private var sleepData: SleepData? = nil
    
    var body: some View {
        
        var status: Bool {
            let today = Calendar.current.startOfDay(for: Date())
            return (sleepArr[today] ?? 0.0) >= limit
        }
        
        VStack {
            HStack {
                VStack(alignment: .leading, spacing: 5) {
                    
                    Text("\(sleepDates.count)")
                        .font(.largeTitle)
                        .foregroundColor(.white)
                    
                    Text("Days Streak")
                        .font(.subheadline)
                        .foregroundColor(.white)
                    
                }
                .padding(.leading, 20)
                
                Spacer()
                
                Image(systemName: "flame")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 36, height: 36)
                    .foregroundColor(.white)
                    .padding(.trailing, 20)
            }
            .padding(.vertical, 10)
            
            // Reminder Block
            VStack {
                Text(status ? "Great work beating your sleep goal!" : "Don't forget to complete your streak!")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(status ? Color.blue : Color.blue.opacity(0.5))
                    )
                    .fixedSize(horizontal: false, vertical: true) // Allow multiline text
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .background(status ? Color.orange : Color.gray.opacity(0.3))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding()
        .onAppear {
            Task {
                sleepDates = []
                await getSleepDaysData()
            }
        }
        
        VStack {
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .fontWeight(.black)
                        .foregroundStyle(.blue)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach(days, id: \.self) { day in
                    if day.monthInt != date.monthInt {
                        Text("")
                    } else {
                        let sleepHours = sleepArr[day] ?? 0.0
                        let colour = getColor(for: sleepHours)
                        
                        Button(day.formatted(.dateTime.day())) {
                            
                            Task {
                                self.sleepData = await HealthStore.shared.fetchSleepData(forDate: day)
                            }
                            
                        }
                        .fontWeight(.bold)
                        .foregroundStyle(.secondary)
                        .frame(maxWidth: .infinity, minHeight: 40)
                        .background(
                            Circle()
                                .foregroundStyle(
                                    Date.now.startOfDay == day.startOfDay
                                        ? colour.opacity(0.3)
                                    : colour.opacity(0.3)
                                )
                        )
                    }
                }
            }
        }
        .padding()
        .onAppear {
            days = date.calendarDisplayDays
            limit = Double(userVM.user?.sleepGoal ?? 0)
            Task {
                await getSleepData()
            }
        }
        .onChange(of: date) { newDate in
            days = newDate.calendarDisplayDays
            Task {
                await getSleepData()
            }
        }
        
        if let sleepData = sleepData {
            VStack (spacing: 10){
                Text("Last Night's Sleep: \(formattedTime(duration: sleepData.todayDuration))")
                    .foregroundColor(getColor(for: sleepData.todayDuration))
                    .font(.headline)
                
                Text("Total Sleep This Week: \(formattedTime(duration: sleepData.totalDuration))")
                    .foregroundColor(getColor(for: sleepData.todayDuration))
                    .font(.headline)
            }
            .padding()
        }
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
    
    private func getColor(for sleepHours: Double) -> Color {
        switch sleepHours {
        case _ where sleepHours >= limit:
            return .green
        case _ where sleepHours >= (limit * 0.8):
            return .yellow
        default:
            return .red
        }
    }
    
    // these two functions are extremely inefficient, can we combine them and try to run it only once at the beginning of loading the page and then just do a search? since the data will never change its just static why loading it repeatedly like it's dynamic lol
    
    func getSleepData() async {
        let healthStore = HealthStore()
        for day in days {
            let sleepHours = await healthStore.fetchSleepData(forDate: day)
            sleepArr[day] = (sleepHours?.todayDuration ?? 0.0) / 3600
        }
    }
    
    func getSleepDaysData() async {
        
        // avoid hardcoding the start date!
        let calendar = Calendar(identifier: .gregorian)
        let currentYear = calendar.component(.year, from: Date())
        let startOfYearComponents = DateComponents(year: currentYear, month: 1, day: 1)
        
        guard let startDate = calendar.date(from: startOfYearComponents) else { return }
        
        let endDate = Date()
        
        await healthStore.requestAuthorization()
        
        for date in stride(from: startDate, to: endDate, by: 86400) {
            
            let sleepHours = await healthStore.fetchSleepData(forDate: date)
            if sleepHours?.todayDuration ?? 0.0 > 8 {
                sleepDates.append(date)
            }
            
        }
    }
}

#Preview {
    StreakView().environmentObject(UserViewModel())
}


