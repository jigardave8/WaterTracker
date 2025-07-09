//
//  GoalSuggestionView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// GoalSuggestionView.swift
import SwiftUI
import HealthKit // <-- ADD THIS LINE


struct GoalSuggestionView: View {
    @Binding var dailyGoal: Double
    @Environment(\.dismiss) var dismiss
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var weightInKg: Double = 70.0
    @State private var activityLevel: ActivityLevel = .light
    
    var suggestedGoal: Double {
        let goalInML = GoalCalculator.suggestGoal(weightInKg: weightInKg, activityLevel: activityLevel)
        // Convert the ML goal to the user's preferred unit for display
        return HKQuantity(unit: .literUnit(with: .milli), doubleValue: goalInML).doubleValue(for: settingsManager.volumeUnit.healthKitUnit)
    }
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Your Details")) {
                    Stepper("Weight: \(Int(weightInKg)) kg", value: $weightInKg, in: 30...200, step: 1)
                    Picker("Activity Level", selection: $activityLevel) {
                        ForEach(ActivityLevel.allCases) { level in
                            Text(level.rawValue).tag(level)
                        }
                    }
                }
                Section(header: Text("Suggested Goal")) {
                    HStack {
                        Text("\(Int(suggestedGoal)) \(settingsManager.volumeUnit.rawValue)")
                            .font(.title).fontWeight(.bold)
                        Spacer()
                    }
                }
                Button(action: {
                    dailyGoal = suggestedGoal
                    dismiss()
                }) {
                    HStack { Spacer(); Text("Accept and Save").fontWeight(.bold); Spacer() }
                }.tint(.blue)
            }
            .navigationTitle("Smart Goal")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
            }
        }
    }
}
