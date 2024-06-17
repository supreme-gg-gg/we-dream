//
//  HealthStore.swift
//  HK
//
//  Created by zyf on 2024-05-12.
//
/*
import Foundation
import HealthKit
import Observation

enum HealthError: Error {
    case healthDataNotAvailable
}

@Observable
class HealthStore {
    
    var sleepData: Sleep?
    var healthStore: HKHealthStore?
    var lastError: Error?
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            lastError = HealthError.healthDataNotAvailable
        }
    }
    
    func calculateSleep() async throws {
        guard let healthStore = self.healthStore else { return }
        
        let calendar = Calendar(identifier: .gregorian)
        guard let startDate = calendar.date(byAdding: .hour, value: -20, to: calendar.startOfDay(for: Date())) else { return }
        let endDate = Date()
        
        let sleepSampleType = HKCategoryType(.sleepAnalysis)
        let sleepPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let sleepQuery = HKSampleQuery(sampleType: sleepSampleType, predicate: sleepPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                self.lastError = error
                return
            }
            
            guard let results = results as? [HKCategorySample] else { return }
            
            var totalSleepDuration: TimeInterval = 0
            var deepSleepDuration: TimeInterval = 0
            
            for result in results {
                let sleepDuration = result.endDate.timeIntervalSince(result.startDate)
                totalSleepDuration += sleepDuration
                
                if result.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue {
                    deepSleepDuration += sleepDuration
                }
            }
            
            self.sleepData = Sleep(totalDuration: totalSleepDuration, deepSleepDuration: deepSleepDuration, date: startDate)
        }
        
        healthStore.execute(sleepQuery)
    }
    
    func requestAuthorization() async {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else { return }
        guard let healthStore = self.healthStore else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [sleepType])
        } catch {
            lastError = error
        }
    }
}
*/
import Foundation
import HealthKit
import Observation

enum HealthError: Error {
    case healthDataNotAvailable
}

@Observable
class HealthStore {
    
    var sleep: Sleep? // Sleep is not being used anymore
    var sleepData: SleepData?
    var healthStore: HKHealthStore?
    var lastError: Error?
    
    static let shared = HealthStore()
    
    init() {
        if HKHealthStore.isHealthDataAvailable() {
            healthStore = HKHealthStore()
        } else {
            lastError = HealthError.healthDataNotAvailable
        }
    }
    
    // Function to determine the start and end date for the current week
    func getWeekStartAndEndDates(forDate: Date?) -> (start: Date, end: Date, now: Date)? {
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        // Get the current date
        
        var now: Date
        
        // the user can choose to specify a date or just use today
        if let d = forDate {
            now = d
        } else {
            now = Date()
        }
        
        // Find the previous Sunday at 5:00 PM
        let components = calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: now)
        guard let startOfWeek = calendar.date(from: components),
              let startDate = calendar.date(byAdding: .hour, value: 17, to: startOfWeek) else {
            return nil
        }
        
        // Add 7 days to find the next Sunday at 5:00 PM
        guard let endDate = calendar.date(byAdding: .day, value: 7, to: startDate) else {
            return nil
        }
        
        return (startDate, endDate, now)
    }

    /// Function to query HealthKit for sleep data within the specified time range. Returns both TODAY's sleep time (from yesterday 5pm to today 5pm) and THIS WEEK's total sleep time from Sunday (5pm) to the coming Sunday (5pm). Note that it uses completion instead of return.
    func fetchSleepData(forDate: Date? = nil) async -> SleepData? {
        
        guard let healthStore = self.healthStore else {
            return nil
        }
        
        guard let sleepType = HKObjectType.categoryType(forIdentifier: .sleepAnalysis),
              let dates = getWeekStartAndEndDates(forDate: forDate) else {
            return nil
        }
        
        let weeklyPredicate = HKQuery.predicateForSamples(withStart: dates.start, end: dates.end, options: .strictStartDate)
        
        var calendar = Calendar.current
        calendar.timeZone = TimeZone.current
        
        // Calculate the start and end times for today (from yesterday's 5:00 PM to today's 5:00 PM)
        guard let startOfYesterday = calendar.date(byAdding: .day, value: -1, to: dates.now),
                  let startOfToday = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: startOfYesterday),
                  let endOfToday = calendar.date(bySettingHour: 17, minute: 0, second: 0, of: dates.now) else {
            return nil
            }
        
        let todayPredicate = HKQuery.predicateForSamples(withStart: startOfToday, end: endOfToday, options: .strictStartDate)
        
        // var totalSleepDuration: TimeInterval?
        // var todaySleepDuration: TimeInterval?
        
            /*
        let query = HKSampleQuery(sampleType: sleepType, predicate: weeklyPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if error != nil {
                        return
                }
                
                let totalSleepDuration = results?.compactMap { sample -> Double? in
                    guard let categorySample = sample as? HKCategorySample else { return nil }
                    return categorySample.endDate.timeIntervalSince(categorySample.startDate)
                }.reduce(0, +)
                
                self.sleepData = SleepData(totalDuration: totalSleepDuration ?? 0.0, todayDuration: 0.0)
            }
        
        healthStore.execute(query)
        
        let todayQuery = HKSampleQuery(sampleType: sleepType, predicate: todayPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (todayQuery, todayResults, todayError) in
                if todayError != nil {
                        return
                }
                
                let todaySleepDuration = todayResults?.compactMap { sample -> Double? in
                        guard let categorySample = sample as? HKCategorySample else { return nil }
                        return categorySample.endDate.timeIntervalSince(categorySample.startDate)
                    }.reduce(0, +)
                
                self.sleepData?.todayDuration = todaySleepDuration ?? 0.0
            
            print("Inside closure \(String(describing: self.sleepData))")
            }
    
        healthStore.execute(todayQuery)
        
        print("Before return \(String(describing: sleepData))")
        
        return sleepData */
        
        // NOTE that the closure is a completion here (omg we've never used them!) they are like async but you cannot await them (lmao) so everything outside will run first then at last the closure (lmao)?? This is why you need to tell the fetch func to WAIT don't return yet until the queries are finished!
        
        // Helper function to perform query and await the result
        func performQuery(predicate: NSPredicate) async -> Double {
            await withCheckedContinuation { continuation in
                let query = HKSampleQuery(sampleType: sleepType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (_, results, error) in
                    if error != nil {
                        continuation.resume(returning: 0.0)
                        return
                    }
                    
                    let totalDuration = results?.compactMap { sample -> Double? in
                        guard let categorySample = sample as? HKCategorySample else { return nil }
                        return categorySample.endDate.timeIntervalSince(categorySample.startDate)
                    }.reduce(0, +) ?? 0.0
                    
                    continuation.resume(returning: totalDuration)
                }
                healthStore.execute(query)
            }
        }

        // Perform the weekly and today's queries
        let totalSleepDuration = await performQuery(predicate: weeklyPredicate)
        let todaySleepDuration = await performQuery(predicate: todayPredicate)

        // Update and return the sleepData
        self.sleepData = SleepData(totalDuration: totalSleepDuration, todayDuration: todaySleepDuration)

        print("After queries completion \(String(describing: self.sleepData))")
        
        return self.sleepData
        
    }
    
    /// gets the total sleep and deep sleep in the Sleep structure format for the given date (still debugging the date). This uses normal return with the Sleep struct.
    /*
    func calculateSleep(for date: Date) async throws -> Sleep? {
        guard let healthStore = self.healthStore else { return nil }
        
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return nil }
        
        let sleepSampleType = HKCategoryType(.sleepAnalysis)
        let sleepPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        let sleepQuery = HKSampleQuery(sampleType: sleepSampleType, predicate: sleepPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
            if let error = error {
                self.lastError = error
                return
            }
            
            guard let results = results as? [HKCategorySample] else { return }
            
            var totalSleepDuration: TimeInterval = 0
            var deepSleepDuration: TimeInterval = 0
            
            for result in results {
                let sleepDuration = result.endDate.timeIntervalSince(result.startDate)
                totalSleepDuration += sleepDuration
                
                if result.value == HKCategoryValueSleepAnalysis.asleepDeep.rawValue {
                    deepSleepDuration += sleepDuration
                }
            }
            
            self.sleep = Sleep(totalDuration: totalSleepDuration, deepSleepDuration: deepSleepDuration, date: startDate)
        }
        
        healthStore.execute(sleepQuery)
        
        return sleep
    }
     */
    func calculateSleep(for date: Date) async throws -> Double {
        guard let healthStore = self.healthStore else { return 0.0 }
        
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return 0.0 }
        
        let sleepSampleType = HKCategoryType(.sleepAnalysis)
        let sleepPredicate = HKQuery.predicateForSamples(withStart: startDate, end: endDate)
        
        return try await withCheckedThrowingContinuation { continuation in
            let sleepQuery = HKSampleQuery(sampleType: sleepSampleType, predicate: sleepPredicate, limit: HKObjectQueryNoLimit, sortDescriptors: nil) { (query, results, error) in
                if let error = error {
                    continuation.resume(throwing: error)
                    return
                }
                
                guard let results = results as? [HKCategorySample] else {
                    continuation.resume(returning: 0.0)
                    return
                }
                
                var totalSleepDuration: TimeInterval = 0
                
                for result in results {
                    totalSleepDuration += result.endDate.timeIntervalSince(result.startDate)
                }
                
                let totalHours = totalSleepDuration / 3600.0
                continuation.resume(returning: totalHours)
            }
            
            healthStore.execute(sleepQuery)
        }
    }
    
    
    func requestAuthorization() async {
        guard let sleepType = HKObjectType.categoryType(forIdentifier: HKCategoryTypeIdentifier.sleepAnalysis) else { return }
        guard let healthStore = self.healthStore else { return }
        
        do {
            try await healthStore.requestAuthorization(toShare: [], read: [sleepType])
        } catch {
            lastError = error
        }
    }
}
