//
//  ContentView.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 08/07/25.
//

// watchOS ContentView.swift
import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var settingsManager = SettingsManager()
    @AppStorage("dailyGoal", store: UserDefaults(suiteName: SharedDataManager.appGroupID)) var dailyGoal: Double = 2500

    var progress: Double {
        let total = healthManager.totalWaterToday
        return dailyGoal > 0 ? total / dailyGoal : 0
    }

    var body: some View {
        VStack {
            HStack {
                ProgressCircleView(progress: progress).frame(width: 50, height: 50)
                VStack(alignment: .leading) {
                    Text("\(Int(healthManager.totalWaterToday)) \(settingsManager.volumeUnit.rawValue)")
                        .font(.headline).bold()
                    Text("of \(Int(dailyGoal)) \(settingsManager.volumeUnit.rawValue)")
                        .font(.caption).foregroundColor(.secondary)
                }
            }.padding(.bottom, 4)
            Divider()
            List(Drink.allDrinks) { drink in
                NavigationLink(destination: AdjustIntakeView(drink: drink)) {
                    HStack {
                        Image(systemName: drink.imageName).foregroundColor(drink.color)
                        Text(drink.name)
                    }
                }
            }.listStyle(.carousel)
        }
        .padding(.top, 1)
        .navigationTitle("Water Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear { healthManager.fetchAllTodayData() }
    }
}
