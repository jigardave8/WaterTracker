//
//  ContentView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
// ContentView.swift (The new TabView manager)

import SwiftUI

struct ContentView: View {
    // Create the HealthKitManager here, so it can be shared with all tabs.
    @StateObject private var healthManager = HealthKitManager()

    var body: some View {
        TabView {
            // Tab 1: Home
            HomeView()
                .tabItem {
                    Label("Today", systemImage: "house.fill")
                }
            
            // Tab 2: Charts
            ChartsView(healthManager: healthManager)
                .tabItem {
                    Label("Charts", systemImage: "chart.bar.xaxis")
                }
        }
        // Inject the healthManager into the environment for all child views (like HomeView).
        .environmentObject(healthManager)
        .onAppear {
            // Fetch initial data when the app starts
            NotificationManager.shared.requestAuthorization()
            healthManager.fetchAllTodayData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
