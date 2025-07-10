//
//  SettingsViewModel.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//
//
//  SettingsViewModel.swift
//  WaterTracker
//
//  This is the definitive, stable version of the ViewModel. It has been rewritten
//  to be 100% crash-proof by removing all force unwraps from its initialization.
//

import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var dailyGoal: Double
    @Published var volumeUnit: VolumeUnit
    
    @Published var remindersOn: Bool {
        didSet { UserDefaults.standard.set(remindersOn, forKey: "remindersOn") }
    }
    
    @Published var startTime: Date {
        didSet { UserDefaults.standard.set(startTime.timeIntervalSince1970, forKey: "reminderStartTime") }
    }
    
    @Published var endTime: Date {
        didSet { UserDefaults.standard.set(endTime.timeIntervalSince1970, forKey: "reminderEndTime") }
    }
    
    @Published var interval: Int {
        didSet { UserDefaults.standard.set(interval, forKey: "reminderInterval") }
    }
    
    @Published var selectedAppIcon: AppIcon {
        didSet { UIApplication.shared.setAlternateIconName(selectedAppIcon.iconName) }
    }
    
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Initialization
    
    init() {
        // Initialize properties with default values BEFORE loading from storage.
        // This ensures the object is in a valid state from the very beginning.
        self.dailyGoal = 2500
        self.volumeUnit = .milliliters
        self.remindersOn = false
        self.startTime = Date()
        self.endTime = Date()
        self.interval = 120
        self.selectedAppIcon = .primary
        
        // Now, safely load all settings from storage.
        loadAllSettings()
        
        // Set up the listener for changes from iCloud.
        NotificationCenter.default.publisher(for: .settingsDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.loadAllSettings()
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    func setVolumeUnit(_ unit: VolumeUnit) {
        CloudSettingsManager.shared.setVolumeUnit(unit)
        self.volumeUnit = unit
    }
    
    func setDailyGoal(_ goal: Double) {
        CloudSettingsManager.shared.setDailyGoal(goal)
        self.dailyGoal = goal
    }
    
    func scheduleNotifications() {
        NotificationManager.shared.scheduleAdvancedReminders(
            isEnabled: remindersOn,
            startTime: startTime,
            endTime: endTime,
            intervalInMinutes: interval
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func loadAllSettings() {
        dailyGoal = CloudSettingsManager.shared.getDailyGoal()
        volumeUnit = CloudSettingsManager.shared.getVolumeUnit()
        remindersOn = UserDefaults.standard.bool(forKey: "remindersOn")
        
        // --- THIS IS THE CRASH FIX ---
        // We now safely create default dates and use nil-coalescing (`??`)
        // to ensure we NEVER have a nil value.
        let defaultStartTime = Calendar.current.date(from: DateComponents(hour: 8)) ?? Date()
        let defaultEndTime = Calendar.current.date(from: DateComponents(hour: 22)) ?? Date()

        let savedStartTime = UserDefaults.standard.double(forKey: "reminderStartTime")
        startTime = savedStartTime > 0 ? Date(timeIntervalSince1970: savedStartTime) : defaultStartTime
        
        let savedEndTime = UserDefaults.standard.double(forKey: "reminderEndTime")
        endTime = savedEndTime > 0 ? Date(timeIntervalSince1970: savedEndTime) : defaultEndTime
        
        let savedInterval = UserDefaults.standard.integer(forKey: "reminderInterval")
        interval = savedInterval > 0 ? savedInterval : 120
        
        if let iconName = UIApplication.shared.alternateIconName {
            selectedAppIcon = AppIcon.allCases.first { $0.iconName == iconName } ?? .primary
        } else {
            selectedAppIcon = .primary
        }
    }
}
