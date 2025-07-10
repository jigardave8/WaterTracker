//
//  MainTabView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  MainTabView.swift
//  WaterTracker
//

import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var storeManager = StoreManager()
    
    @Environment(\.horizontalSizeClass) var sizeClass

    @State private var showingUpgradeSheet = false
    
    var body: some View {
        if sizeClass == .compact {
            iphoneLayout
                .environmentObject(storeManager)
        } else {
            ipadLayout
                .environmentObject(storeManager)
        }
    }
    
    var iphoneLayout: some View {
        TabView {
            HomeView()
                .tabItem { Label("Today", systemImage: "house.fill") }
            
            ChartsView(healthManager: healthManager)
                .tabItem { Label("Charts", systemImage: "chart.bar.xaxis") }

            proTab(AwardsView(), title: "Awards", icon: "star.fill")
            proTab(InsightsView(), title: "Insights", icon: "chart.pie.fill")

            SettingsView()
                .tabItem { Label("Settings", systemImage: "gearshape.fill") }
        }
        .onAppear(perform: onAppAppear)
        .sheet(isPresented: $showingUpgradeSheet, content: upgradeSheet)
    }
    
    var ipadLayout: some View {
        NavigationSplitView {
            List {
                Label("Today", systemImage: "house.fill")
                Label("Charts", systemImage: "chart.bar.xaxis")
                Label("Awards", systemImage: "star.fill")
                Label("Insights", systemImage: "chart.pie.fill")
                Label("Settings", systemImage: "gearshape.fill")
            }
            .listStyle(.sidebar)
            .navigationTitle("WaterTracker")
        } detail: {
            HomeView()
        }
        .onAppear(perform: onAppAppear)
        .sheet(isPresented: $showingUpgradeSheet, content: upgradeSheet)
    }
    
    @ViewBuilder
    private func proTab<Content: View>(_ content: Content, title: String, icon: String) -> some View {
        if storeManager.isProUser {
            content
                .tabItem { Label(title, systemImage: icon) }
        } else {
            VStack {
                Button("Unlock \(title) with Pro") {
                    showingUpgradeSheet = true
                }
                .buttonStyle(.borderedProminent)
            }
            .tabItem { Label(title, systemImage: icon) }
        }
    }
    
    private func onAppAppear() {
        Task {
            await storeManager.updatePurchasedStatus()
            if !storeManager.isProUser {
                await storeManager.loadProducts()
            }
        }
    }
    
    @ViewBuilder
    private func upgradeSheet() -> some View {
        UpgradeView()
    }
}
