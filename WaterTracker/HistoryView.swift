//
//  HistoryView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

// HistoryView.swift
// Target: WaterTracker

import SwiftUI
import HealthKit // <-- ADD THIS LINE


struct HistoryView: View {
    @ObservedObject var healthManager: HealthKitManager
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        List {
            ForEach(healthManager.history, id: \.uuid) { sample in
                historyRow(for: sample)
            }
            .onDelete(perform: deleteEntry)
        }
        .navigationTitle("Today's History")
        .onAppear {
            healthManager.fetchDailyHistory()
        }
    }
    
    // --- NEW: A dedicated function to build the row ---
    @ViewBuilder
    private func historyRow(for sample: HKQuantitySample) -> some View {
        let hydratedAmount = sample.quantity.doubleValue(for: .literUnit(with: .milli))
        
        // Read metadata
        let drinkName = sample.metadata?[HealthKitManager.MetadataKeys.drinkName] as? String ?? "Water"
        let originalVolume = sample.metadata?[HealthKitManager.MetadataKeys.originalVolume] as? Double
        
        HStack {
            Image(systemName: "drop.fill")
                .foregroundColor(.blue)
                .font(.title2)

            VStack(alignment: .leading) {
                if let originalVolume = originalVolume, drinkName != "Water" {
                    // Display both original and hydrated amounts for custom drinks
                    Text("\(Int(originalVolume))ml \(drinkName)")
                        .fontWeight(.bold)
                    Text("(\(Int(hydratedAmount))ml Hydration)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                } else {
                    // Just show the amount for plain water
                    Text("\(Int(hydratedAmount))ml Water")
                        .fontWeight(.bold)
                }
            }
            
            Spacer()
            
            Text(dateFormatter.string(from: sample.startDate))
                .foregroundColor(.secondary)
        }
        .padding(.vertical, 8)
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            healthManager.deleteSample(healthManager.history[index])
        }
    }
}
