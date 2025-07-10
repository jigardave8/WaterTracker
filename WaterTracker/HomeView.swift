//
//  HomeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//
//
//
//
//  HomeView.swift
//  WaterTracker
//
//  The main "Today" screen, featuring both the animated body graphic and a circular progress bar.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var storeManager: StoreManager
    
    @StateObject private var settingsManager = SettingsManager()
    @State private var dailyGoal: Double = 0
    
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
                        .font(.headline)
                        .fontWeight(.semibold)
                        .foregroundColor(.secondary)
                        .padding(.top)

                    // --- THIS IS THE FIX: Both views are now present ---
                    ZStack {
                        // The circular progress bar is in the background.
                        ProgressCircleView(progress: progress)
                            .frame(width: 250, height: 250)
                        
                        // The animated body is in the foreground, slightly smaller.
                        BodyFillView(progress: progress)
                            .frame(height: 200)
                    }
                    .padding(.top, 20)
                    
                    VStack {
                        Text("\(Int(healthManager.totalWaterToday)) / \(Int(dailyGoal)) \(settingsManager.volumeUnit.rawValue)")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundColor(.primaryBlue)
                        Text("Today's Progress")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.bottom, 20)

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
