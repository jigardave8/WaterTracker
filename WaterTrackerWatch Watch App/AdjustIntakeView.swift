//
//  AdjustIntakeView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// watchOS AdjustIntakeView.swift
import SwiftUI
import HealthKit

struct AdjustIntakeView: View {
    let drink: Drink
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var settingsManager = SettingsManager()
    @Environment(\.dismiss) var dismiss
    
    @State private var amountInML: Double = 250
    
    var displayAmount: Int {
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amountInML)
        return Int(quantity.doubleValue(for: settingsManager.volumeUnit.healthKitUnit))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(drink.name).font(.title3).fontWeight(.semibold).foregroundColor(drink.color)
            Text("\(displayAmount) \(settingsManager.volumeUnit.rawValue)")
                .font(.largeTitle).fontWeight(.bold)
                .focusable(true)
                #if !targetEnvironment(simulator)
                .digitalCrownRotation($amountInML, from: 50, through: 2000, by: 10, sensitivity: .medium, isContinuous: false, isHapticFeedbackEnabled: true)
                #endif
            
            Button("Log Intake") {
                healthManager.saveWaterIntake(drink: drink, amountInML: amountInML)
                dismiss()
            }.tint(drink.color).buttonStyle(.borderedProminent)
        }
        .navigationTitle("Adjust").navigationBarTitleDisplayMode(.inline)
    }
}
