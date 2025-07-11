//
//  HomeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//
//
//
//
//
//  HomeView.swift
//  WaterTracker
//
//  The final, polished Home Screen with multiple progress visualizations.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var storeManager: StoreManager
    
    @StateObject private var settingsManager = SettingsManager()
    @State private var dailyGoal: Double = 0
    
    @State private var selectedDrink: Drink? = nil
    
    // This state is managed by the ViewModel, but we read it here to show the banner.
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
                    // Date Header
                    Text(Date.now.longDayMonthDayFormat)
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.top)

                    // The combined progress/body view
                    ZStack {
                        // The circular progress bar is in the background.
                        ProgressCircleView(progress: progress)
                            .frame(width: 320, height: 320)
                        
                        // The animated body is in the foreground, slightly smaller.
                        BodyFillView(progress: progress)
                            .frame(height: 250)
                        
                        // The animated intake number
                        VStack {
                            Text("\(Int(healthManager.totalWaterToday))")
                                .font(.system(size: 60, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .contentTransition(.numericText()) // Animates number changes
                            
                            Text(settingsManager.volumeUnit.rawValue)
                                .font(.title3).fontWeight(.medium)
                                .foregroundColor(.white.opacity(0.8))
                        }
                    }
                    .padding(.top, 10)
                    
                    // Progress Text
                    VStack {
                        Text(progress >= 1.0 ? "Goal Achieved! 🎉" : "Today's Progress")
                            .font(.title2).fontWeight(.bold)
                            .foregroundColor(.primaryBlue)
                        
                        Text("\(Int(progress * 100))% of your \(Int(dailyGoal)) \(settingsManager.volumeUnit.rawValue) goal")
                            .font(.subheadline).foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)

                    // "Reminders Off" Banner
                    if !remindersOn {
                        HStack {
                            Image(systemName: "bell.slash.fill")
                            Text("Reminders are turned off.")
                        }
                        .font(.caption).foregroundColor(.orange)
                        .padding(8).background(Color.orange.opacity(0.1))
                        .cornerRadius(8).transition(.opacity.combined(with: .move(edge: .top)))
                    }
                    
                    Text("Add Intake").font(.title2).fontWeight(.medium)
                    
                    // Drink Buttons
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 20) {
                            ForEach(Drink.allDrinks) { drink in
                                Button(action: { self.selectedDrink = drink }) {
                                    VStack {
                                        drink.icon
                                            .font(.largeTitle)
                                            .foregroundColor(drink.color)
                                            .frame(width: 60, height: 60)
                                            .background(Color(.systemGray6))
                                            .clipShape(Circle())
                                            .shadow(color: .black.opacity(0.1), radius: 3, x: 0, y: 2)
                                        Text(drink.name).font(.caption).foregroundColor(.primary)
                                    }
                                }
                                .accessibilityLabel("Log \(drink.name)")
                            }
                        }.padding(.horizontal)
                    }
                    .frame(height: 100) // Give the scroll view a fixed height
                }
            }
            .animation(.default, value: remindersOn)
            .sheet(item: $selectedDrink) { drink in IntakeSelectionView(drink: drink) }
            .onAppear(perform: loadSettings)
            .onReceive(NotificationCenter.default.publisher(for: .settingsDidChange)) { _ in loadSettings() }
        }
    }
    
    func loadSettings() {
        self.dailyGoal = CloudSettingsManager.shared.getDailyGoal()
    }
}
