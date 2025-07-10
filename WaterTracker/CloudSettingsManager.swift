//
//  CloudSettingsManager.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  CloudSettingsManager.swift
//  WaterTracker
//
//  This manager is the single source of truth for settings that need to sync
//  across a user's devices via iCloud. It gracefully falls back to local
//  UserDefaults if iCloud is unavailable.
//

import Foundation

class CloudSettingsManager {
    static let shared = CloudSettingsManager()
    
    // Use iCloud's key-value store if available, otherwise use local defaults.
    private let store = NSUbiquitousKeyValueStore.default
    private let localStore = UserDefaults.standard
    
    // Define unique keys for our synced settings.
    private struct Keys {
        static let dailyGoal = "iCloud_dailyGoal"
        static let volumeUnit = "iCloud_volumeUnit"
    }
    
    init() {
        // Observe changes coming from iCloud from other devices.
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(storeDidChange(_:)),
                                               name: NSUbiquitousKeyValueStore.didChangeExternallyNotification,
                                               object: store)
        // Trigger an initial sync to get the latest data from iCloud on launch.
        store.synchronize()
    }
    
    // When iCloud data changes externally, post our own custom notification
    // to let the app's UI know it needs to update.
    @objc private func storeDidChange(_ notification: Notification) {
        DispatchQueue.main.async {
            NotificationCenter.default.post(name: .settingsDidChange, object: nil)
        }
    }
    
    // --- Daily Goal ---
    func setDailyGoal(_ goal: Double) {
        store.set(goal, forKey: Keys.dailyGoal)
        localStore.set(goal, forKey: Keys.dailyGoal) // Also save locally as a backup
        store.synchronize() // Tell iCloud to sync this change
    }
    
    func getDailyGoal() -> Double {
        // Prioritize the value from iCloud. If it doesn't exist (returns 0),
        // try the local store. If that doesn't exist, use a default value.
        let cloudGoal = store.double(forKey: Keys.dailyGoal)
        if cloudGoal > 0 { return cloudGoal }
        
        let localGoal = localStore.double(forKey: Keys.dailyGoal)
        if localGoal > 0 { return localGoal }
        
        return 2500 // Default value
    }
    
    // --- Volume Unit ---
    func setVolumeUnit(_ unit: VolumeUnit) {
        store.set(unit.rawValue, forKey: Keys.volumeUnit)
        localStore.set(unit.rawValue, forKey: Keys.volumeUnit)
        store.synchronize()
    }
    
    func getVolumeUnit() -> VolumeUnit {
        let storedValue = store.string(forKey: Keys.volumeUnit) ?? localStore.string(forKey: Keys.volumeUnit)
        return VolumeUnit(rawValue: storedValue ?? VolumeUnit.milliliters.rawValue) ?? .milliliters
    }
}

// A custom Notification name our app can use to observe settings changes.
extension Notification.Name {
    static let settingsDidChange = Notification.Name("com.bitdegree.watertracker.settingsDidChange")
}
