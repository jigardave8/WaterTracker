//
//  HomeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// HomeView.swift (This contains the old ContentView logic)

import SwiftUI

struct HomeView: View {
    // We get the healthManager from the environment, which the TabView will provide.
    @EnvironmentObject var healthManager: HealthKitManager
    
    // All other properties from the old ContentView go here.
    @AppStorage("dailyGoal") private var dailyGoal: Double = 2500
    @AppStorage("notificationsEnabled") private var notificationsEnabled: Bool = false {
        didSet {
            if notificationsEnabled {
                NotificationManager.shared.scheduleWaterReminders()
            } else {
                NotificationManager.shared.cancelAllNotifications()
            }
        }
    }
    
    @State private var showingSettings = false
    @State private var selectedDrink: Drink? = nil

    var progress: Double {
        dailyGoal > 0 ? healthManager.totalWaterToday / dailyGoal : 0
    }
    
    var body: some View {
        NavigationView {
            // The entire VStack from your old ContentView.swift's body goes here.
            VStack(spacing: 20) {
                NavigationLink(destination: HistoryView(healthManager: healthManager)) {
                    Text("View Today's History")
                        .font(.headline)
                }
                .padding(.top)

                Text("Today's Progress")
                    .font(.title2)
                    .fontWeight(.medium)

                ZStack {
                    ProgressCircleView(progress: progress)
                        .frame(width: 200, height: 200)
                    
                    VStack {
                        Text("\(Int(healthManager.totalWaterToday)) ml")
                            .font(.largeTitle).fontWeight(.bold)
                        Text("of \(Int(dailyGoal)) ml")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 30)
                
                Text("Add Intake")
                    .font(.title2)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Drink.allDrinks) { drink in
                            Button(action: { self.selectedDrink = drink }) {
                                VStack {
                                    Image(systemName: drink.imageName).font(.largeTitle)
                                        .foregroundColor(drink.color)
                                        .frame(width: 60, height: 60)
                                        .background(drink.color.opacity(0.15))
                                        .clipShape(Circle())
                                    Text(drink.name).font(.caption).foregroundColor(.primary)
                                }
                            }
                        }
                    }
                    .padding(.horizontal)
                }
                
                Spacer()
            }
            .padding(.vertical)
            .navigationTitle("Water Tracker 💧")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: { showingSettings = true }) {
                        Image(systemName: "gearshape.fill").font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(dailyGoal: $dailyGoal, notificationsEnabled: $notificationsEnabled)
            }
            .sheet(item: $selectedDrink) { drink in
                IntakeSelectionView(drink: drink, healthManager: healthManager)
            }
        }
    }
}
