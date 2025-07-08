//
//  ContentView.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 08/07/25.
//

// WaterTrackerWatch/ContentView.swift
// Target: WaterTrackerWatch

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @AppStorage("dailyGoal", store: UserDefaults(suiteName: SharedDataManager.appGroupID)) var dailyGoal: Double = 2500

    var progress: Double {
        dailyGoal > 0 ? healthManager.totalWaterToday / dailyGoal : 0
    }
    
    // Default log amount for the watch
    private let defaultLogAmount: Double = 250

    var body: some View {
        VStack {
            // Progress Header
            HStack {
                ProgressCircleView(progress: progress)
                    .frame(width: 50, height: 50)
                
                VStack(alignment: .leading) {
                    Text("\(Int(healthManager.totalWaterToday)) ml")
                        .font(.headline).bold()
                    Text("of \(Int(dailyGoal)) ml")
                        .font(.caption).foregroundColor(.secondary)
                }
            }
            .padding(.bottom, 4)

            Divider()

            // --- NEW: List of drinks for logging ---
            List(Drink.allDrinks) { drink in
                Button(action: {
                    // Log the selected drink with the default amount
                    healthManager.saveWaterIntake(drink: drink, amountInML: defaultLogAmount)
                }) {
                    HStack {
                        Image(systemName: drink.imageName)
                            .foregroundColor(drink.color)
                        Text(drink.name)
                        Spacer()
                        Text("+\(Int(defaultLogAmount))")
                            .foregroundColor(.secondary)
                    }
                }
            }
            .listStyle(.carousel) // A great list style for watchOS
        }
        .padding(.top, 1) // Reduce top padding
        .navigationTitle("Water Tracker")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            healthManager.fetchAllTodayData()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            ContentView().environmentObject(HealthKitManager())
        }
    }
}
