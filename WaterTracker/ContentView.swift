//
//  ContentView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

// ContentView.swift (iOS App)

//
//  ContentView.swift
//  WaterTracker
//
//  This is the main view of the app, responsible for displaying progress
//  and navigating to other features.
//

import SwiftUI

struct ContentView: View {
    // MARK: - Properties
    
    @StateObject private var healthManager = HealthKitManager()
    
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
    
    // MARK: - Body
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: HistoryView(healthManager: healthManager)) {
                    Text("View Today's History")
                        .font(.headline)
                }
                .padding(.top)

                // MARK: Progress Circle
                Text("Today's Progress")
                    .font(.title2)
                    .fontWeight(.medium)

                ZStack {
                    ProgressCircleView(progress: progress)
                        .frame(width: 200, height: 200)
                    
                    VStack {
                        Text("\(Int(healthManager.totalWaterToday)) ml")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        Text("of \(Int(dailyGoal)) ml")
                            .foregroundColor(.secondary)
                    }
                }
                .padding(.bottom, 30)

                // MARK: Drink Selection
                Text("Add Intake")
                    .font(.title2)
                    .fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Drink.allDrinks) { drink in
                            Button(action: {
                                self.selectedDrink = drink
                            }) {
                                VStack {
                                    Image(systemName: drink.imageName)
                                        .font(.largeTitle)
                                        .foregroundColor(drink.color)
                                        .frame(width: 60, height: 60)
                                        .background(drink.color.opacity(0.15))
                                        .clipShape(Circle())
                                    Text(drink.name)
                                        .font(.caption)
                                        .foregroundColor(.primary)
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
                        Image(systemName: "gearshape.fill")
                            .font(.title3)
                    }
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView(dailyGoal: $dailyGoal, notificationsEnabled: $notificationsEnabled)
            }
            .sheet(item: $selectedDrink) { drink in
                IntakeSelectionView(drink: drink, healthManager: healthManager)
            }
            .onAppear {
                NotificationManager.shared.requestAuthorization()
                healthManager.fetchAllTodayData()
            }
        }
    }
}

// MARK: - Previews

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
