//
//    Date+Extensions.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  Date+Extensions.swift
//  WaterTracker
//
//  This file adds helpful extensions to built-in Swift types.
//

import Foundation

extension Date {
    // A computed property to get the very beginning of the day (00:00:00).
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
    
    // --- THIS IS THE FIX ---
    // A new computed property that safely formats the date into a readable string
    // like "Friday, June 21". This is 100% compatible.
    var longDayMonthDayFormat: String {
        let formatter = DateFormatter()
        // "EEEE" gives the full day name (e.g., "Friday").
        // "MMMM" gives the full month name (e.g., "June").
        // "d" gives the day of the month (e.g., "21").
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: self)
    }
}
