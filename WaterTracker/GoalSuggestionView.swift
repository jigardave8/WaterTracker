//
//  GoalSuggestionView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

import SwiftUI
import HealthKit

struct GoalSuggestionView: View {
    @Binding var dailyGoal: Double
    @Environment(\.dismiss) var dismiss
    
    @State private var weightInKg: Double = 70.0
    @State private var activityLevel: ActivityLevel = .light
    
    // Properties to adapt the view for the onboarding flow.
    var isFromOnboarding: Bool = false
    @Binding var isCompleted: Bool // Binding to control the button's appearance
    var onComplete: (() -> Void)? = nil
    
    // A custom initializer to provide a default value for the new binding,
    // which prevents errors when calling this view from the Settings page.
    init(
        dailyGoal: Binding<Double>,
        isFromOnboarding: Bool = false,
        isCompleted: Binding<Bool> = .constant(false), // Default value
        onComplete: (() -> Void)? = nil
    ) {
        self._dailyGoal = dailyGoal
        self.isFromOnboarding = isFromOnboarding
        self._isCompleted = isCompleted
        self.onComplete = onComplete
    }
    
    var suggestedGoal: Double {
        let goalInML = GoalCalculator.suggestGoal(weightInKg: weightInKg, activityLevel: activityLevel)
        let currentUnit = CloudSettingsManager.shared.getVolumeUnit()
        return HKQuantity(unit: .literUnit(with: .milli), doubleValue: goalInML).doubleValue(for: currentUnit.healthKitUnit)
    }
    
    var body: some View {
        let content = Form {
            Section(header: Text("Your Details")) {
                Stepper("Weight: \(Int(weightInKg)) kg", value: $weightInKg, in: 30...200, step: 1)
                
                Picker("Activity Level", selection: $activityLevel) {
                    ForEach(ActivityLevel.allCases) { level in Text(level.rawValue).tag(level) }
                }
            }
            
            Section(header: Text("Suggested Goal")) {
                HStack {
                    Text("\(Int(suggestedGoal)) \(CloudSettingsManager.shared.getVolumeUnit().rawValue)")
                        .font(.title).fontWeight(.bold)
                    Spacer()
                }
            }
            
            Button(action: {
                // If it's from onboarding, don't allow setting it more than once.
                if isFromOnboarding && isCompleted { return }
                
                dailyGoal = suggestedGoal
                if isFromOnboarding {
                    onComplete?() // This will set isGoalSet to true in the parent
                } else {
                    dismiss() // Dismiss the sheet if opened from settings
                }
            }) {
                HStack {
                    Spacer()
                    // UI changes based on whether the goal has been set
                    if isFromOnboarding && isCompleted {
                        Image(systemName: "checkmark")
                        Text("Goal Set")
                    } else {
                        Text(isFromOnboarding ? "Set Goal & Continue" : "Accept and Save")
                    }
                    Spacer()
                }
                .fontWeight(.bold)
            }
            .tint(isCompleted && isFromOnboarding ? .green : .blue)
            .animation(.default, value: isCompleted)
        }
        
        // This logic determines how the view is presented
        if isFromOnboarding {
            VStack {
                Text("Set Your Daily Goal")
                    .font(.largeTitle).fontWeight(.bold).padding(.top, 60)
                Text("Let's calculate a starting point. You can always change this later.")
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
