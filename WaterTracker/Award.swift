//
//  Award.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//
//  This file contains the complete and final data model for all awards.
//

import Foundation
import SwiftUI

// The safe, typed way to identify all awards.
enum AwardID: String, CaseIterable {
    // Daily
    case firstSip, morningHydrator, middayHydrator, eveningHydrator, nightOwl, perfectDay
    // Streaks
    case threeDayStreak, sevenDayStreak, fourteenDayStreak, thirtyDayStreak, hundredDayStreak, yearStreak
    // Total Intake (Liters)
    case total10L, total50L, total100L, total250L, total500L, total1000L, total5000L
    // Drink Specific (Count)
    case coffee5, coffee25, coffee100
    case tea5, tea25, tea100
    case juice5, juice25, juice100
    // Variety
    case varietyFirst, varietyAll
    // Goal
    case goalSetter, goalAchiever5, goalAchiever25
    // Other Milestones
    case firstWeek, firstMonth, weekendWarrior, weekdayWarrior
    case log100, log500, log1000
    case customIntake, appPro
}


// The data structure for a single award.
struct Award: Identifiable {
    let id: AwardID // Uses the safe enum for the ID
    let name: String
    let description: String
    let imageName: String
    var isEarned: Bool = false // Default to not earned
}
