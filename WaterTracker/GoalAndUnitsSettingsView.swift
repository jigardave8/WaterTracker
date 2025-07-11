//
//  GoalAndUnitsSettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//
//
//  GoalAndUnitsSettingsView.swift
//  WaterTracker
//

import SwiftUI

struct GoalAndUnitsSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @Binding var showingSuggestionSheet: Bool
    
    var body: some View {
        Section(header: Text("Goal & Units")) {
            Stepper("\(Int(viewModel.dailyGoal)) \(viewModel.volumeUnit.rawValue)", value: $viewModel.dailyGoal, in: 500...10000, step: 50)
                // --- MODERN .onChange SYNTAX ---
                .onChange(of: viewModel.dailyGoal) {
                    viewModel.setDailyGoal(viewModel.dailyGoal)
                }
            
            Picker("Volume Unit", selection: $viewModel.volumeUnit) {
                ForEach(VolumeUnit.allCases) { unit in Text(unit.rawValue).tag(unit) }
            }
            // --- MODERN .onChange SYNTAX ---
            .onChange(of: viewModel.volumeUnit) {
                viewModel.setVolumeUnit(viewModel.volumeUnit)
            }
            
            Button(action: { showingSuggestionSheet = true }) {
                Label("Calculate a Smart Goal", systemImage: "brain.head.profile")
            }.foregroundColor(.primary)
        }
    }
}
