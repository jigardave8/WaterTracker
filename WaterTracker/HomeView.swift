//
//  HomeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//
//
//  HomeView.swift
//  WaterTracker
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var dailyGoal: Double = 0
    
    @State private var showingSettings = false
    @State private var selectedDrink: Drink? = nil

    var progress: Double {
        let total = healthManager.totalWaterToday
        return dailyGoal > 0 ? total / dailyGoal : 0
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                NavigationLink(destination: HistoryView()) {
                    Text("View Today's History")
                }.padding(.top)

                Text("Today's Progress")
                    .font(.title2).fontWeight(.medium)

                ZStack {
                    ProgressCircleView(progress: progress)
                        .frame(width: 200, height: 200)
                    VStack {
                        Text("\(Int(healthManager.totalWaterToday)) \(settingsManager.volumeUnit.rawValue)")
                            .font(.largeTitle).fontWeight(.bold)
                        Text("of \(Int(dailyGoal)) \(settingsManager.volumeUnit.rawValue)")
                            .foregroundColor(.secondary)
                    }
                    .accessibilityElement(children: .combine)
                    .accessibilityLabel("Daily Progress")
                    .accessibilityValue("\(Int(healthManager.totalWaterToday)) of \(Int(dailyGoal)) \(settingsManager.volumeUnit.rawValue)")
                }
                .padding(.bottom, 30)
                
                Text("Add Intake").font(.title2).fontWeight(.medium)
                
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 20) {
                        ForEach(Drink.allDrinks) { drink in
                            Button(action: { self.selectedDrink = drink }) {
                                VStack {
                                    drink.icon
                                        .font(.largeTitle)
                                        .foregroundColor(drink.color)
                                        .frame(width: 60, height: 60)
                                        .background(drink.color.opacity(0.15))
                                        .clipShape(Circle())
                                    Text(drink.name).font(.caption).foregroundColor(.primary)
                                }
                            }
                            .accessibilityLabel("Log \(drink.name)")
                        }
                    }.padding(.horizontal)
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
            // --- THIS IS THE CORRECTED PRESENTATION ---
            // SettingsView is presented without any parameters. It handles its own state.
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .sheet(item: $selectedDrink) { drink in
                IntakeSelectionView(drink: drink)
            }
            .onAppear(perform: loadSettings)
            .onReceive(NotificationCenter.default.publisher(for: .settingsDidChange)) { _ in
                loadSettings()
            }
        }
    }
    
    func loadSettings() {
        self.dailyGoal = CloudSettingsManager.shared.getDailyGoal()
    }
}
