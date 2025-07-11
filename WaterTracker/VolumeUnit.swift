//
//  VolumeUnit.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

//
//  VolumeUnit.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//
//  This is a shared data model, available to all targets.
//

import Foundation
import HealthKit

enum VolumeUnit: String, CaseIterable, Identifiable {
    case milliliters = "ml"
    case fluidOunces = "oz (US)"
    
    var id: String { self.rawValue }
    
    var healthKitUnit: HKUnit {
        switch self {
        case .milliliters:
            return .literUnit(with: .milli)
        case .fluidOunces:
            return .fluidOunceUS()
        }
    }
}
