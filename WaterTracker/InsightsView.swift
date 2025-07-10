//
//  InsightsView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  InsightsView.swift
//  WaterTracker
//
//  A Pro-exclusive view for advanced, interactive statistics. This version is
//  architected correctly to support interactive chart selection.
//

import SwiftUI
import Charts

// A model for the drink breakdown pie chart.
// We remove Plottable conformance as it's not needed with the correct selection pattern.
struct DrinkStat: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var value: Double
    let color: Color
}

// A reusable view for a row of statistics
struct StatRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.title)
                .foregroundColor(color)
                .frame(width: 50)
            
            VStack(alignment: .leading) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.secondary)
                Text(value)
                    .font(.headline)
                    .fontWeight(.bold)
            }
            Spacer()
        }
    }
}


struct InsightsView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var settingsManager = SettingsManager()
    
    // --- THIS IS THE FIX: We select the drink's NAME (a String), not the whole object. ---
    @State private var selectedDrinkName: String?
    
    // Example data
    @State private var drinkStats: [DrinkStat] = [
        .init(name: "Water", value: 65, color: .blue),
        .init(name: "Coffee", value: 25, color: .brown),
        .init(name: "Tea", value: 10, color: .green)
    ]
    
    let averageIntake: Double = 2850
    let mostCommonTime = "Morning (6am - 12pm)"
    
    // A computed property to find the full DrinkStat object based on the selected name.
    var selectedDrinkStat: DrinkStat? {
        guard let selectedDrinkName = selectedDrinkName else { return nil }
        return drinkStats.first { $0.name == selectedDrinkName }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    // MARK: - Drink Breakdown Chart
                    VStack(alignment: .leading) {
                        Text("Drink Breakdown")
                            .font(.title2).fontWeight(.bold)
                        
                        Chart(drinkStats) { stat in
                            SectorMark(
                                angle: .value("Percentage", stat.value),
                                innerRadius: .ratio(0.618),
                                angularInset: 2.0
                            )
                            .foregroundStyle(by: .value("Drink", stat.name)) // Use foregroundStyle(by:)
                            .cornerRadius(8)
                            .opacity(selectedDrinkName == nil ? 1.0 : (selectedDrinkName == stat.name ? 1.0 : 0.5))
                        }
                        // Bind the selection to our String? state variable.
                        .chartAngleSelection(value: $selectedDrinkName)
                        .chartForegroundStyleScale(domain: drinkStats.map { $0.name }, range: drinkStats.map { $0.color })
                        .frame(height: 250)
                        .chartBackground { chartProxy in
                            GeometryReader { geometry in
                                // Use the computed property to display info for the selected stat.
                                if let selectedDrinkStat = selectedDrinkStat {
                                    let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                                    VStack {
                                        Text(selectedDrinkStat.name)
                                            .font(.headline)
                                        Text("\(Int(selectedDrinkStat.value))%")
                                            .font(.largeTitle).fontWeight(.bold)
                                    }
                                    .position(center)
                                }
                            }
                        }
                        // The legend is now generated automatically by the chart.
                        .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                        .animation(.default, value: selectedDrinkName)
                    }
                    
                    Divider()
                    
                    // MARK: - Key Statistics
                    VStack(alignment: .leading) {
                        Text("Key Statistics")
                            .font(.title2).fontWeight(.bold)
                        
                        StatRow(
                            icon: "scalemass.fill",
                            label: "30-Day Average",
                            value: "\(Int(averageIntake)) \(settingsManager.volumeUnit.rawValue)/day",
                            color: .indigo
                        )
                        
                        StatRow(
                            icon: "clock.fill",
                            label: "Most Active Time",
                            value: mostCommonTime,
                            color: .orange
                        )
                    }
                }
                .padding()
            }
            .navigationTitle("Insights")
        }
        .navigationViewStyle(.stack)
    }
}

struct InsightsView_Previews: PreviewProvider {
    static var previews: some View {
        InsightsView()
    }
}
