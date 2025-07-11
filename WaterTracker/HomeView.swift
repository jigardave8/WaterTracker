//
//  HomeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//
//  A simplified, stable version using a reliable progress circle.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var dailyGoal: Double = 0
    @State private var selectedDrink: Drink? = nil
    
    var progress: Double {
        let total = healthManager.totalWaterToday
        return dailyGoal > 0 ? (total / dailyGoal) : 0
    }
    
    // Capped progress for the circle (0.0 to 1.0)
    var cappedProgress: Double {
        min(progress, 1.0)
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    Text(Date.now.longDayMonthDayFormat)
                        .font(.headline).fontWeight(.semibold).foregroundColor(.secondary).padding(.top)

                    // --- REVERTED TO A RELIABLE ZSTACK WITH SimpleProgressCircle ---
                    ZStack {
                        // The reliable, shared progress circle
                        SimpleProgressCircle(progress: cappedProgress, lineWidth: 25)
                            .frame(width: 300, height: 300)

                        // The intake values and units, clearly displayed in the center
                        VStack {
                            Text("\(Int(healthManager.totalWaterToday))")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.primary)
                                .contentTransition(.numericText())
                            
                            Text(settingsViewModel.volumeUnit.rawValue)
                                .font(.title3).fontWeight(.medium)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding(.top, 10)
                    
                    // The text below the circle, as before
                    VStack {
                        Text(progress >= 1.0 ? "Goal Achieved! 🎉" : "Today's Progress")
                            .font(.title2).fontWeight(.bold).foregroundColor(.primaryBlue)
                        
                        Text("\(Int(progress * 100))% of your \(Int(dailyGoal)) \(settingsViewModel.volumeUnit.rawValue) goal")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                    
                    // The intake section, as before
                    VStack {
                        Text("Add Intake").font(.title2).fontWeight(.medium)
                        
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack(spacing: 12) {
                                ForEach(Drink.allDrinks) { drink in
                                    Button(action: { self.selectedDrink = drink }) {
                                        DrinkButtonView(drink: drink)
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }
                        .frame(height: 100)
                    }
                }
            }
            .sheet(item: $selectedDrink) { drink in
                IntakeSelectionView(drink: drink)
                    .environmentObject(healthManager)
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
