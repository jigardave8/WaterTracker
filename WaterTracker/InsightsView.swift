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
//  Created by BitDegree on 10/07/25.
//

import SwiftUI
import Charts

struct DrinkStat: Identifiable, Equatable {
    let id = UUID()
    let name: String
    var value: Double
    let color: Color
}

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
    @EnvironmentObject var settingsViewModel: SettingsViewModel
    
    @State private var selectedDrinkName: String?
    
    @State private var drinkStats: [DrinkStat] = [
        .init(name: "Water", value: 65, color: .blue),
        .init(name: "Coffee", value: 25, color: .brown),
        .init(name: "Tea", value: 10, color: .green)
    ]
    
    let averageIntake: Double = 2850
    let mostCommonTime = "Morning (6am - 12pm)"
    
    var selectedDrinkStat: DrinkStat? {
        guard let selectedDrinkName = selectedDrinkName else { return nil }
        return drinkStats.first { $0.name == selectedDrinkName }
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading) {
                        Text("Drink Breakdown")
                            .font(.title2).fontWeight(.bold)
                        
                        Chart(drinkStats) { stat in
                            SectorMark(
                                angle: .value("Percentage", stat.value),
                                innerRadius: .ratio(0.618),
                                angularInset: 2.0
                            )
                            .foregroundStyle(by: .value("Drink", stat.name))
                            .cornerRadius(8)
                            .opacity(selectedDrinkName == nil ? 1.0 : (selectedDrinkName == stat.name ? 1.0 : 0.5))
                        }
                        .chartAngleSelection(value: $selectedDrinkName)
                        .chartForegroundStyleScale(domain: drinkStats.map { $0.name }, range: drinkStats.map { $0.color })
                        .frame(height: 250)
                        .chartBackground { chartProxy in
                            GeometryReader { geometry in
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
                        .chartLegend(position: .bottom, alignment: .center, spacing: 20)
                        .animation(.default, value: selectedDrinkName)
                    }
                    
                    Divider()
                    
                    VStack(alignment: .leading) {
                        Text("Key Statistics")
                            .font(.title2).fontWeight(.bold)
                        
                        StatRow(
                            icon: "scalemass.fill",
                            label: "30-Day Average",
                            value: "\(Int(averageIntake)) \(settingsViewModel.volumeUnit.rawValue)/day",
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
