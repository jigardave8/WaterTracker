//
//  GoalCalculator.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// GoalCalculator.swift
// Target: WaterTracker

import Foundation

// Enum to represent different activity levels
enum ActivityLevel: String, CaseIterable, Identifiable {
    case sedentary = "Sedentary"
    case light = "Lightly Active"
    case moderate = "Moderately Active"
    case veryActive = "Very Active"
    
    var id: String { self.rawValue }
    
    // Multiplier for the calculation
    var multiplier: Double {
        switch self {
        case .sedentary:
            return 0.0
        case .light:
            return 350.0 // Add ~12 oz
        case .moderate:
            return 700.0 // Add ~24 oz
        case .veryActive:
            return 1050.0 // Add ~36 oz
        }
    }
}

class GoalCalculator {
    // A common formula is to take half the user's weight in pounds to get ounces.
    // Then we convert that to milliliters and add an activity bonus.
    static func suggestGoal(weightInKg: Double, activityLevel: ActivityLevel) -> Double {
        // 1. Convert kg to pounds
        let weightInLbs = weightInKg * 2.20462
        
        // 2. Calculate base intake in ounces (half of weight in lbs)
        let baseIntakeInOz = weightInLbs / 2.0
        
        // 3. Convert base intake to milliliters (1 oz ≈ 29.5735 ml)
        let baseIntakeInMl = baseIntakeInOz * 29.5735
        
        // 4. Add the activity level bonus (in ml)
        let totalIntake = baseIntakeInMl + activityLevel.multiplier
        
        // 5. Round to a clean number (e.g., to the nearest 50ml)
        let roundedIntake = (totalIntake / 50.0).rounded() * 50.0
        
        return roundedIntake
    }
}
