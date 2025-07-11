//
//  WaterTrackerWatchApp.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 08/07/25.
//

import SwiftUI

@main
struct WaterTrackerWatch_Watch_AppApp: App {
    @StateObject private var healthManager = HealthKitManager()
    // Create an instance of our new, safe watch-specific settings object.
    @StateObject private var watchSettings = WatchSettings()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            // Inject the HealthKit manager and the new WatchSettings object.
            .environmentObject(healthManager)
            .environmentObject(watchSettings)
        }
    }
}
