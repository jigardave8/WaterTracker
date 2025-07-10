//
//  ContentView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
// ContentView.swift (The new TabView manager)

// ContentView.swift
// Target: WaterTracker

import SwiftUI

struct ContentView: View {
    @StateObject private var healthManager = HealthKitManager()
    
    // --- NEW: Flag to control onboarding visibility ---
    @AppStorage("isOnboarding") private var isOnboarding: Bool = true

    var body: some View {
        if isOnboarding {
            OnboardingView(isOnboarding: $isOnboarding)
        } else {
            // The existing TabView structure
            TabView {
                HomeView()
                    .tabItem { Label("Today", systemImage: "house.fill") }
                
                ChartsView(healthManager: healthManager)
                    .tabItem { Label("Charts", systemImage: "chart.bar.xaxis") }
            }
            .environmentObject(healthManager)
            .onAppear {
                NotificationManager.shared.requestAuthorization()
                healthManager.fetchAllTodayData()
            }
        }
    }
}
