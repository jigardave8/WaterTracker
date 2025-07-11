//
//  AdjustIntakeView.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 09/07/25.
//

import SwiftUI
import HealthKit

struct AdjustIntakeView: View {
    let drink: Drink
    @EnvironmentObject var healthManager: HealthKitManager
    // Use the correct, watch-safe settings object.
    @EnvironmentObject var watchSettings: WatchSettings
    @Environment(\.dismiss) var dismiss
    
    @State private var amountInML: Double = 250
    
    var displayAmount: Int {
        let quantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amountInML)
        // Use the property from the correct object.
        return Int(quantity.doubleValue(for: watchSettings.volumeUnit.healthKitUnit))
    }

    var body: some View {
        VStack(spacing: 16) {
            Text(drink.name).font(.title3).fontWeight(.semibold).foregroundColor(drink.color)
            // Use the property from the correct object.
            Text("\(displayAmount) \(watchSettings.volumeUnit.rawValue)")
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
