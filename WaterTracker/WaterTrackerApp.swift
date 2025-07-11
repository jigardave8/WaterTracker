//
//  WaterTrackerApp.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

//
//  WaterTrackerApp.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

import SwiftUI

@main
struct WaterTrackerApp: App {
    // Create a single instance of the SettingsViewModel for the entire app.
    @StateObject private var settingsViewModel = SettingsViewModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                // Inject the view model into the environment so all subviews can access it.
                .environmentObject(settingsViewModel)
        }
    }
}
