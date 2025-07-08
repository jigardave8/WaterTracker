//
//  HistoryView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

// HistoryView.swift (New File, iOS Target)

import SwiftUI

struct HistoryView: View {
    @ObservedObject var healthManager: HealthKitManager
    
    private var dateFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter
    }

    var body: some View {
        List {
            ForEach(healthManager.history, id: \.uuid) { sample in
                HStack {
                    Image(systemName: "drop.fill")
                        .foregroundColor(.blue)
                    
                    let amount = sample.quantity.doubleValue(for: .literUnit(with: .milli))
                    Text("\(Int(amount)) ml")
                    
                    Spacer()
                    
                    Text(dateFormatter.string(from: sample.startDate))
                        .foregroundColor(.secondary)
                }
                .font(.body)
            }
            .onDelete(perform: deleteEntry)
        }
        .navigationTitle("Today's History")
        .onAppear {
            healthManager.fetchDailyHistory()
        }
    }
    
    private func deleteEntry(at offsets: IndexSet) {
        for index in offsets {
            let sampleToDelete = healthManager.history[index]
            healthManager.deleteSample(sampleToDelete)
        }
    }
}

struct HistoryView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            HistoryView(healthManager: HealthKitManager())
        }
    }
}
