//
//  ContentView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthManager = HealthKitManager()
    @StateObject private var awardsManager = AwardsManager()
    
    @AppStorage("isOnboarding") private var isOnboarding: Bool = true

    var body: some View {
        // Use a Group to apply modifiers to the conditional content
        Group {
            if isOnboarding {
                OnboardingView(isOnboarding: $isOnboarding)
            } else {
                MainTabView()
            }
        }
        .environmentObject(healthManager)
        .environmentObject(awardsManager)
        .onAppear {
            // Link the managers together when the app appears
            healthManager.awardsManager = awardsManager
            awardsManager.healthManager = healthManager
        }
    }
}
