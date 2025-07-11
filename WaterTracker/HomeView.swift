//
//  HomeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//
//
//
//  HomeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var storeManager: StoreManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var dailyGoal: Double = 0
    // This state variable tracks which drink was tapped to show the correct sheet.
    @State private var selectedDrink: Drink? = nil
    
    @AppStorage("remindersOn") private var remindersOn: Bool = true
    
    var progress: Double {
        let total = healthManager.totalWaterToday
        return dailyGoal > 0 ? total / dailyGoal : 0
    }
    
    var body: some View {
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 16) {
                    Text(Date.now.longDayMonthDayFormat)
                        .font(.headline).fontWeight(.semibold).foregroundColor(.secondary).padding(.top)

                    ZStack {
                        ProgressCircleView(progress: progress)
                            .frame(width: 320, height: 320)
                        
                        BodyFillView(progress: progress)
                            .frame(height: 250)
                        
                        VStack {
                            Text("\(Int(healthManager.totalWaterToday))")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .contentTransition(.numericText())
                            
                            Text(settingsViewModel.volumeUnit.rawValue)
                                .font(.title3).fontWeight(.medium)
                        }
                        .foregroundColor(.white)
                        .background(
                            Circle()
                                .fill(.black.opacity(0.3))
                                .frame(width: 180, height: 180)
                                .blur(radius: 20)
                                .opacity(progress > 0.5 ? 1 : 0)
                                .animation(.easeIn, value: progress)
                        )
                    }
                    .padding(.top, 10)
                    
                    VStack {
                        Text(progress >= 1.0 ? "Goal Achieved! 🎉" : "Today's Progress")
                            .font(.title2).fontWeight(.bold).foregroundColor(.primaryBlue)
                        
                        Text("\(Int(progress * 100))% of your \(Int(dailyGoal)) \(settingsViewModel.volumeUnit.rawValue) goal")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)
                    
                    // --- START OF NEW/RESTORED CODE ---
                    Text("Add Intake").font(.title2).fontWeight(.medium)
                    
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            ForEach(Drink.allDrinks) { drink in
                                Button(action: {
                                    // Set the selected drink to trigger the sheet
                                    self.selectedDrink = drink
                                }) {
                                    DrinkButtonView(drink: drink)
                                }
                            }
                        }
                        .padding(.horizontal)
                    }
                    .frame(height: 100)
                    // --- END OF NEW/RESTORED CODE ---
                }
            }
            // The sheet modifier is now correctly triggered when `selectedDrink` is not nil.
            .sheet(item: $selectedDrink) { drink in
                IntakeSelectionView(drink: drink)
                    // Pass the environment objects down to the sheet
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
