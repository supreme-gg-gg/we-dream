//
//  StreakView.swift
//  wedream
//
//  Created by Boyuan Jiang on 9/5/2024.
//

/*
import SwiftUI
import HealthKit

struct StreakView: View {
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
                    
                    print("Streak View \(String(describing: sleepData))")
                    
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
    StreakView()
}
*/

import SwiftUI
import HealthKit

struct StreakView: View {
    @State private var color: Color = .blue
    @State private var date = Date.now
    let daysOfWeek = Date.capitalizedFirstLettersOfWeekdays
    let columns = Array(repeating: GridItem(.flexible()), count: 7)
    @State private var days: [Date] = []
    @State private var sleepData: [Date: Double] = [:]
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
        VStack {
            HStack {
                ForEach(daysOfWeek.indices, id: \.self) { index in
                    Text(daysOfWeek[index])
                        .fontWeight(.black)
                        .foregroundStyle(color)
                        .frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: columns) {
                ForEach(days, id: \.self) { day in
                    if day.monthInt != date.monthInt {
                        Text("")
                    } else {
                        let sleepHours = sleepData[day] ?? 0.0
                        
                        if sleepHours >= 6.4 {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(
                                            Date.now.startOfDay == day.startOfDay
                                                ? .green.opacity(0.3)
                                            : .green.opacity(0.3)
                                        )
                                )
                        } else if sleepHours >= 4.0 {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(
                                            Date.now.startOfDay == day.startOfDay
                                                ? .yellow.opacity(0.3)
                                            : .yellow.opacity(0.3)
                                        )
                                )
                        } else {
                            Text(day.formatted(.dateTime.day()))
                                .fontWeight(.bold)
                                .foregroundStyle(.secondary)
                                .frame(maxWidth: .infinity, minHeight: 40)
                                .background(
                                    Circle()
                                        .foregroundStyle(
                                            Date.now.startOfDay == day.startOfDay
                                                ? .red.opacity(0.3)
                                            : .red.opacity(0.3)
                                        )
                                )
                        }
                    }
                }
            }
        }
        .padding()
        .onAppear {
            days = date.calendarDisplayDays
            Task {
                await fetchSleepData()
            }
        }
        .onChange(of: date) { newDate in
            days = newDate.calendarDisplayDays
            Task {
                await fetchSleepData()
            }
        }
        NotificationViewControllerRepresentable() // Embedding the UIViewController
                       .frame(width: 0, height: 0)
    }
    
    func fetchSleepData() async {
        let healthStore = HealthStore()
        do {
            for day in days {
                let sleepHours = try await healthStore.calculateSleep(for: day)
                sleepData[day] = sleepHours
            }
        } catch {
            print("Failed to fetch sleep data: \(error)")
        }
    }
    func fetchSleepDaysData() async {
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



#Preview {
    StreakView()
}


