//
//  SharedDataManager.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// SharedDataManager.swift
// Targets: WaterTracker, WaterTrackerWatch, WaterWidgetExtension

import Foundation

struct SharedData: Codable {
    let totalToday: Double
    let dailyGoal: Double
}

class SharedDataManager {
    // IMPORTANT: Replace with the App Group ID you created!
    static let appGroupID = "group.bitdegree.WaterTracker"
    
    static let shared = SharedDataManager()
    private let userDefaults: UserDefaults

    private init() {
        guard let defaults = UserDefaults(suiteName: SharedDataManager.appGroupID) else {
            fatalError("Could not initialize UserDefaults with App Group ID.")
        }
        self.userDefaults = defaults
    }
    
    func save(data: SharedData) {
        let encoder = JSONEncoder()
        if let encodedData = try? encoder.encode(data) {
            userDefaults.set(encodedData, forKey: "sharedData")
        }
    }
    
    func load() -> SharedData? {
        if let savedData = userDefaults.data(forKey: "sharedData") {
            let decoder = JSONDecoder()
            if let loadedData = try? decoder.decode(SharedData.self, from: savedData) {
                return loadedData
            }
        }
        return nil
    }
}
