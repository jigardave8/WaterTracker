//
//  ContentView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
// ContentView.swift (The new TabView manager)
//
//  ContentView.swift
//  WaterTracker
//

import SwiftUI

struct ContentView: View {
    @StateObject private var healthManager = HealthKitManager()
    @AppStorage("isOnboarding") private var isOnboarding: Bool = true

    var body: some View {
        if isOnboarding {
            OnboardingView(isOnboarding: $isOnboarding)
        } else {
            MainTabView()
                .environmentObject(healthManager)
        }
    }
}
