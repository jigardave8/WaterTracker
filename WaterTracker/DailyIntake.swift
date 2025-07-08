//
//  DailyIntake.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// DailyIntake.swift

import Foundation

struct DailyIntake: Identifiable {
    let id = UUID()
    let date: Date
    let intake: Double
}
