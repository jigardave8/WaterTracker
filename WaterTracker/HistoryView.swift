//
//  HistoryView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

//
//  HistoryView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

import SwiftUI
import HealthKit

struct HistoryView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
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
    
    @ViewBuilder
    private func historyRow(for sample: HKQuantitySample) -> some View {
        let currentUnit = settingsViewModel.volumeUnit
        let hydratedAmount = sample.quantity.doubleValue(for: currentUnit.healthKitUnit)
        
        let drinkName = sample.metadata?[HealthKitManager.MetadataKeys.drinkName] as? String ?? "Water"
        let originalVolumeML = sample.metadata?[HealthKitManager.MetadataKeys.originalVolume] as? Double
        
        HStack {
            Image(systemName: "drop.fill").foregroundColor(.blue).font(.title2)
            VStack(alignment: .leading) {
                if let originalVolumeML = originalVolumeML, drinkName != "Water" {
                    let originalVolume = HKQuantity(unit: .literUnit(with: .milli), doubleValue: originalVolumeML).doubleValue(for: currentUnit.healthKitUnit)
                    Text("\(Int(originalVolume)) \(currentUnit.rawValue) \(drinkName)")
                        .fontWeight(.bold)
                    Text("(\(Int(hydratedAmount)) \(currentUnit.rawValue) Hydration)")
                        .font(.caption).foregroundColor(.secondary)
                } else {
                    Text("\(Int(hydratedAmount)) \(currentUnit.rawValue) Water")
                        .fontWeight(.bold)
                }
            }
            Spacer()
            Text(dateFormatter.string(from: sample.startDate)).foregroundColor(.secondary)
        }.padding(.vertical, 8)
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            healthManager.deleteSample(healthManager.history[index])
        }
    }
}
