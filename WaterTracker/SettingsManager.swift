//
//  SettingsManager.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// SettingsManager.swift
// Targets: WaterTracker, WaterTrackerWatch

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

class SettingsManager: ObservableObject {
    @Published var volumeUnit: VolumeUnit {
        didSet {
            UserDefaults.standard.set(volumeUnit.rawValue, forKey: "volumeUnit")
        }
    }
    
    init() {
        let storedUnit = UserDefaults.standard.string(forKey: "volumeUnit") ?? VolumeUnit.milliliters.rawValue
        self.volumeUnit = VolumeUnit(rawValue: storedUnit) ?? .milliliters
    }
}
