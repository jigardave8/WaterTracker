//
//  ChartsView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

//
//  ChartsView.swift
//  WaterTracker
//
//  This view displays the user's intake over the last 7 days in an
//  interactive bar chart, respecting the user's unit preference.
//

import SwiftUI
import Charts

struct ChartsView: View {
    @ObservedObject var healthManager: HealthKitManager
    @StateObject private var settingsManager = SettingsManager()
    
    // State for the interactive chart "scrubber".
    @State private var selectedDate: Date?
    
    // Computed property to find the data for the selected date.
    var selectedIntake: DailyIntake? {
        guard let selectedDate = selectedDate else { return nil }
        return healthManager.weeklyIntakeData.first {
            Calendar.current.isDate($0.date, inSameDayAs: selectedDate)
        }
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last 7 Days")
                .font(.title).fontWeight(.bold).padding()
            
            Chart {
                ForEach(healthManager.weeklyIntakeData) { day in
                    BarMark(
                        x: .value("Day", day.date, unit: .day),
                        y: .value("Intake", day.intake)
                    )
                    .foregroundStyle(Color.blue.gradient)
                    .cornerRadius(6)
                }
                
                // RuleMark to show the scrubber line when interacting.
                if let selectedIntake = selectedIntake {
                    RuleMark(x: .value("Selected", selectedIntake.date, unit: .day))
                        .foregroundStyle(.gray.opacity(0.5))
                        .offset(y: -10)
                        .zIndex(-1)
                        .annotation(position: .top, alignment: .center, spacing: 8) {
                            // Annotation view showing the value.
                            VStack(spacing: 2) {
                                Text(selectedIntake.date, format: .dateTime.month().day())
                                    .font(.caption).foregroundColor(.secondary)
                                Text("\(Int(selectedIntake.intake)) \(settingsManager.volumeUnit.rawValue)")
                                    .font(.headline).fontWeight(.bold)
                            }
                            .padding(8)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(Color(.systemBackground))
                                    .shadow(radius: 3)
                            )
                        }
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine(); AxisTick()
                    if let ml = value.as(Double.self) {
                        AxisValueLabel {
                            // Display the correct unit on the Y-axis.
                            Text("\(Int(ml)) \(settingsManager.volumeUnit.rawValue)")
                        }
                    }
                }
            }
            // Gesture to capture tap/drag for interactivity.
            .chartOverlay { proxy in
                GeometryReader { geometry in
                    Rectangle().fill(.clear).contentShape(Rectangle())
                        .gesture(
                            DragGesture(minimumDistance: 0)
                                .onChanged { value in
                                    let location = value.location
                                    if let date: Date = proxy.value(atX: location.x) {
                                        selectedDate = date
                                    }
                                }
                                .onEnded { _ in selectedDate = nil }
                        )
                }
            }
            .padding()
            Spacer()
        }
        .onAppear {
            healthManager.fetchWeeklyIntake()
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView(healthManager: HealthKitManager())
    }
}
