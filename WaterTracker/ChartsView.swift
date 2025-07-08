//
//  ChartsView.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// ChartsView.swift

import SwiftUI
import Charts

struct ChartsView: View {
    @ObservedObject var healthManager: HealthKitManager
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Last 7 Days")
                .font(.title)
                .fontWeight(.bold)
                .padding()

            // The main Chart view
            Chart(healthManager.weeklyIntakeData) { day in
                // Each day is represented by a BarMark
                BarMark(
                    x: .value("Day", day.date, unit: .day),
                    y: .value("Intake (ml)", day.intake)
                )
                .foregroundStyle(Color.blue.gradient)
                .cornerRadius(6)
            }
            .chartXAxis {
                // Customize the labels on the X-axis to be more readable
                AxisMarks(values: .stride(by: .day)) { value in
                    AxisGridLine()
                    AxisTick()
                    AxisValueLabel(format: .dateTime.weekday(.narrow), centered: true)
                }
            }
            .chartYAxis {
                // Customize the Y-axis
                AxisMarks { value in
                    AxisGridLine()
                    AxisTick()
                    if let ml = value.as(Double.self) {
                        AxisValueLabel {
                            Text("\(Int(ml)) ml")
                        }
                    }
                }
            }
            .padding()
            
            Spacer()
        }
        .onAppear {
            // Fetch the data when the view appears
            healthManager.fetchWeeklyIntake()
        }
    }
}

struct ChartsView_Previews: PreviewProvider {
    static var previews: some View {
        ChartsView(healthManager: HealthKitManager())
    }
}
