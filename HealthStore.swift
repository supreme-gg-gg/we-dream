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
    
    func calculateSleep(for date: Date) async throws {
        guard let healthStore = self.healthStore else { return }
        
        let calendar = Calendar(identifier: .gregorian)
        let startDate = calendar.startOfDay(for: date)
        guard let endDate = calendar.date(byAdding: .day, value: 1, to: startDate) else { return }
        
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

