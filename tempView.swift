
import SwiftUI

struct tempView: View {
    @State private var healthStore = HealthStore()
    @State private var selectedDate = Date()
    @State private var sleepData: Sleep?

    var body: some View {
        VStack {
            DatePicker("Select Date", selection: $selectedDate, displayedComponents: .date)
                .datePickerStyle(GraphicalDatePickerStyle())
                .padding()
                
            
            Button("Fetch Sleep Data") {
                Task {
                    do {
                        try await healthStore.calculateSleep(for: selectedDate)
                        sleepData = healthStore.sleepData
                    } catch {
                        print("Error fetching sleep data: \(error)")
                    }
                }
            }
            .padding()
            
            if let sleepData = sleepData {
                VStack {
                    Text("Date: \(sleepData.date, formatter: dateFormatter)")
                        .foregroundColor(getColor(for: sleepData))
                    Text("Total Sleep: \(formattedTime(duration: sleepData.totalDuration))")
                        .foregroundColor(getColor(for: sleepData))
                    Text("Deep Sleep: \(formattedTime(duration: sleepData.deepSleepDuration))")
                        .foregroundColor(getColor(for: sleepData))
                }
            }
        }
        .onAppear {
            Task {
                await healthStore.requestAuthorization()
            }
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
    
    private func getColor(for sleepData: Sleep?) -> Color {
        guard let sleepData = sleepData else {
            return .gray
        }
        
        let sleepHours = sleepData.totalDuration / 3600
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
    tempView()
}


