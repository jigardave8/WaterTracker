//
//  SettingsManager.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

//
//  SettingsManager.swift
//  WaterTracker
//
//  This class acts as an observable bridge between our SwiftUI views and the
//  CloudSettingsManager. It listens for changes from iCloud and updates its
//  published properties, causing the UI to refresh.
//

import Foundation
import HealthKit
import Combine

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
    @Published var volumeUnit: VolumeUnit
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        self.volumeUnit = CloudSettingsManager.shared.getVolumeUnit()
        
        // Listen for the custom notification from our CloudSettingsManager.
        NotificationCenter.default.publisher(for: .settingsDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.updateFromCloud()
            }
            .store(in: &cancellables)
    }
    
    // Called when data has changed on another device.
    func updateFromCloud() {
        self.volumeUnit = CloudSettingsManager.shared.getVolumeUnit()
    }
    
    // Called when the user changes a setting in the UI.
    func setVolumeUnit(_ unit: VolumeUnit) {
        CloudSettingsManager.shared.setVolumeUnit(unit)
        // Manually update the published property to reflect the change immediately.
        self.volumeUnit = unit
    }
}
