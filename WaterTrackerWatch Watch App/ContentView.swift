//
//  ContentView.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 08/07/25.
//

// WaterTrackerWatch/ContentView.swift

import SwiftUI

struct ContentView: View {
    @StateObject private var healthManager = HealthKitManager()
    // Read the goal from AppStorage, which syncs from the phone
    @AppStorage("dailyGoal") private var dailyGoal: Double = 2500

    var progress: Double {
        dailyGoal > 0 ? healthManager.totalWaterToday / dailyGoal : 0
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                ProgressCircleView(progress: progress)
                    .frame(width: 80, height: 80)
                
                VStack(spacing: 0) {
                    Text("\(Int(progress * 100))%")
                        .font(.system(.headline, design: .rounded))
                        .bold()
                    Text("\(Int(healthManager.totalWaterToday)) ml")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }
            
            HStack {
                Button(action: { healthManager.saveWaterIntake(amount: 250) }) {
                    Text("+250ml")
                }
                .tint(.blue)
            }
        }
        .padding()
        .onAppear {
            healthManager.fetchTodayWaterIntake()
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
