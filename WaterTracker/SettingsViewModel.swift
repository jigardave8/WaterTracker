//
//  SettingsViewModel.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//
//
//
//
//  SettingsViewModel.swift
//  WaterTracker
//
//  This is the definitive, stable version of the ViewModel. It separates state loading
//  from side-effects (like scheduling notifications) to prevent crashes.
//

import SwiftUI
import Combine

class SettingsViewModel: ObservableObject {
    // MARK: - Published Properties
    
    @Published var dailyGoal: Double
    @Published var volumeUnit: VolumeUnit
    
    // The didSet blocks now ONLY save to UserDefaults. No more side-effects here.
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
    
    @Published var soundName: String {
        didSet { UserDefaults.standard.set(soundName, forKey: "soundName") }
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
        self.soundName = "default"
        
        loadAllSettings()
        
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
    
    // This is the single, safe entry point for scheduling. It's called explicitly by the view.
    func handleReminderSettingsChange(isPro: Bool) {
        NotificationManager.shared.scheduleAdvancedReminders(
            isPro: isPro,
            isEnabled: remindersOn,
            startTime: startTime,
            endTime: endTime,
            intervalInMinutes: interval,
            soundName: soundName
        )
    }
    
    // MARK: - Private Helper Methods
    
    private func loadAllSettings() {
        dailyGoal = CloudSettingsManager.shared.getDailyGoal()
        volumeUnit = CloudSettingsManager.shared.getVolumeUnit()
        remindersOn = UserDefaults.standard.bool(forKey: "remindersOn")
        
        // Safely create default dates and use nil-coalescing (`??`) to prevent crashes.
        let defaultStartTime = Calendar.current.date(from: DateComponents(hour: 8)) ?? Date()
        let savedStartTime = UserDefaults.standard.double(forKey: "reminderStartTime")
        startTime = savedStartTime > 0 ? Date(timeIntervalSince1970: savedStartTime) : defaultStartTime
        
        let defaultEndTime = Calendar.current.date(from: DateComponents(hour: 22)) ?? Date()
        let savedEndTime = UserDefaults.standard.double(forKey: "reminderEndTime")
        endTime = savedEndTime > 0 ? Date(timeIntervalSince1970: savedEndTime) : defaultEndTime
        
        let savedInterval = UserDefaults.standard.integer(forKey: "reminderInterval")
        interval = savedInterval > 0 ? savedInterval : 120
        
        soundName = UserDefaults.standard.string(forKey: "soundName") ?? "default"
        
        if let iconName = UIApplication.shared.alternateIconName {
            selectedAppIcon = AppIcon.allCases.first { $0.iconName == iconName } ?? .primary
        } else {
            selectedAppIcon = .primary
        }
    }
}
