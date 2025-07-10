//
//  GoalSuggestionView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//
//
//  GoalSuggestionView.swift
//  WaterTracker
//
//  This view calculates a suggested goal and can be used in two contexts:
//  1. From the Settings sheet (with a dismiss button).
//  2. As part of the onboarding flow (with a completion handler).
//

import SwiftUI
import HealthKit

struct GoalSuggestionView: View {
    @Binding var dailyGoal: Double
    @Environment(\.dismiss) var dismiss
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var weightInKg: Double = 70.0
    @State private var activityLevel: ActivityLevel = .light
    
    // Optional properties to adapt the view for the onboarding flow.
    var isFromOnboarding: Bool = false
    var onComplete: (() -> Void)? = nil
    
    var suggestedGoal: Double {
        let goalInML = GoalCalculator.suggestGoal(weightInKg: weightInKg, activityLevel: activityLevel)
        // Convert the ML goal to the user's preferred unit for display
        return HKQuantity(unit: .literUnit(with: .milli), doubleValue: goalInML).doubleValue(for: settingsManager.volumeUnit.healthKitUnit)
    }
    
    var body: some View {
        let content = Form {
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
                        .font(.title)
                        .fontWeight(.bold)
                    Spacer()
                }
            }
            
            Button(action: {
                dailyGoal = suggestedGoal
                if isFromOnboarding {
                    onComplete?() // Call the completion handler to dismiss onboarding
                } else {
                    dismiss() // Dismiss the sheet if opened from settings
                }
            }) {
                HStack {
                    Spacer()
                    Text(isFromOnboarding ? "Set Goal & Finish" : "Accept and Save")
                        .fontWeight(.bold)
                    Spacer()
                }
            }.tint(.blue)
        }
        
        // Conditionally wrap the content in a NavigationView or a simpler VStack
        // depending on where it's being presented from.
        if isFromOnboarding {
            VStack {
                Text("Set Your Daily Goal")
                    .font(.largeTitle).fontWeight(.bold).padding(.top, 60)
                Text("We've calculated a starting point based on common health recommendations. You can always change this later in Settings.")
                    .font(.headline).multilineTextAlignment(.center)
                    .foregroundColor(.secondary).padding(.horizontal)
                
                content
            }
        } else {
            NavigationView {
                content
                    .navigationTitle("Smart Goal")
                    .toolbar {
                        ToolbarItem(placement: .navigationBarLeading) { Button("Cancel") { dismiss() } }
                    }
            }
        }
    }
}
