import SwiftUI
import HealthKit

struct ChartView: View {
    @State private var healthStore = HealthStore()
    @State private var sleepData: [Date: Double] = [:]
    @State private var errorMessage: String? = nil
    
    var body: some View {
        VStack {
            if let errorMessage = errorMessage {
                Text("Error: \(errorMessage)")
                    .foregroundColor(.red)
            } else {
                BarChartView(data: sleepData)
                    .frame(height: 250)
                    .scaledToFit()
            }
        }
        .onAppear {
            Task {
                do {
                    try await healthStore.requestAuthorization()
                    sleepData = try await fetchSleepDataForLast7Days()
                } catch {
                    errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    private func fetchSleepDataForLast7Days() async throws -> [Date: Double] {
        var sleepData: [Date: Double] = [:]
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        
        for dayOffset in 0..<7 {
            guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }
            let sleepHours = try await healthStore.fetchSleepData(forDate: date)
            sleepData[date] = (sleepHours?.todayDuration ?? 0.0) / 3600
        }
        
        return sleepData
    }
}

struct BarChartView: View {
    let data: [Date: Double]
    
    var body: some View {
        
        /*
        VStack {
            Text("Recent 7 Days")
                .font(.headline)
                .padding(.bottom, 4)
            
            
        }*/
        
        HStack(alignment: .bottom, spacing: 8) {
            ForEach(data.sorted(by: { $0.key < $1.key }), id: \.key) { date, hours in
                VStack {
                    Text("\(String(format: "%.1f", hours)) h")
                        .font(.caption2)
                        .frame(minWidth: 30)
                    Rectangle()
                        .fill(Color.blue.opacity(0.8))
                        .frame(width: 30, height: CGFloat(hours) * 15)
                    Text(formattedDate(date))
                        .font(.caption2)
                        .frame(minWidth: 35)
                }
            }
        }
    }
    
    // Helper function to format date
    private func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM-dd"  // Format: "MM-dd"
        return dateFormatter.string(from: date)
    }
}

struct ChartView_Previews: PreviewProvider {
    static var previews: some View {
        ChartView()
    }
}
