//
//  ContentView.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 08/07/25.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var watchSettings: WatchSettings
    @AppStorage("dailyGoal", store: UserDefaults(suiteName: SharedDataManager.appGroupID)) var dailyGoal: Double = 2500

    var progress: Double {
        let total = healthManager.totalWaterToday
        return dailyGoal > 0 ? total / dailyGoal : 0
    }

    var body: some View {
        VStack {
            HStack {
                SimpleProgressCircle(progress: progress, lineWidth: 8)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("\(Int(healthManager.totalWaterToday)) \(watchSettings.volumeUnit.rawValue)")
                        .font(.headline).bold()
                    Text("of \(Int(dailyGoal)) \(watchSettings.volumeUnit.rawValue)")
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
        // --- THIS IS THE FIX ---
        // Call the fetch function with the required completion parameter.
        .onAppear { healthManager.fetchAllTodayData(completion: nil) }
    }
}
