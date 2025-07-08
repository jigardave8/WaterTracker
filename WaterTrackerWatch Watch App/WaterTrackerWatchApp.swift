//
//  WaterTrackerWatchApp.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 08/07/25.
//
// WaterTrackerWatch Watch App.swift
// Target: WaterTrackerWatch

import SwiftUI

@main
struct WaterTrackerWatch_Watch_AppApp: App {
    // --- NEW ---
    // Create the manager here to be the single source of truth for the watch app
    @StateObject private var healthManager = HealthKitManager()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                ContentView()
            }
            // --- NEW ---
            // Inject the manager into the environment
            .environmentObject(healthManager)
        }
    }
}
