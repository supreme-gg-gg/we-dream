//
//  Functions.swift
//  wedream
//
//  Created by Jet Chiang on 2024-05-31.
//

import Foundation

func dateOneWeekFromToday() -> Date {
    // Get the current date
    let currentDate = Date()
    
    // Create a date component for 1 week from today
    var dateComponents = DateComponents()
    dateComponents.day = 7 // Add 7 days
    
    // Get the calendar and add the date component to the current date
    let calendar = Calendar.current
    if let oneWeekFromDate = calendar.date(byAdding: dateComponents, to: currentDate) {
        return oneWeekFromDate
    } else {
        // Return current date in case of error
        return currentDate
    }
}

func formatDuration(_ duration: Int?) -> String {
    let duration = duration ?? 0
    if duration == 0 {
        return "00:00"
    }
    let minutes = duration / 60
    let seconds = duration % 60
    return String(format: "%02d:%02d", minutes, seconds)
}
