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
//  This is the main "Today" screen for the iOS app.
//

import SwiftUI
import HealthKit

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var settingsManager = SettingsManager()
    
    @AppStorage("dailyGoal") private var dailyGoal: Double = 2500
    
    @State private var showingSettings = false
    @State private var selectedDrink: Drink? = nil

    var progress: Double {
        let total = healthManager.totalWaterToday
        // We use the raw dailyGoal value for calculation, as both are now in the same unit.
        return dailyGoal > 0 ? total / dailyGoal : 0
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // --- FIX 1: Remove the healthManager argument ---
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
                }
                .padding(.bottom, 30)
                
                Text("Add Intake").font(.title2).fontWeight(.medium)
                
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
            .sheet(isPresented: $showingSettings) {
                SettingsView(dailyGoal: $dailyGoal)
            }
            // --- FIX 2: Remove the healthManager argument ---
            .sheet(item: $selectedDrink) { drink in
                IntakeSelectionView(drink: drink)
            }
        }
    }
}
