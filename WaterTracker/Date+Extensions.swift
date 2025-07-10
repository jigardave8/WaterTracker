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
}
