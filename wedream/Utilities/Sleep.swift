//
//  Sleep.swift
//  wedream
//
//  Created by Jet Chiang on 2024-06-05.
//

import Foundation

// Original structure used by version 1 (calculateSleep)
struct Sleep {
    var totalDuration : TimeInterval
    var deepSleepDuration : TimeInterval
    var date : Date
}

// new structure used by version 2 (fetchSleepData)
struct SleepData {
    
    var totalDuration: TimeInterval
    var todayDuration: TimeInterval
    
}
