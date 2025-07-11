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
                .onChange(of: viewModel.dailyGoal) { newValue in viewModel.setDailyGoal(newValue) }
            
            Picker("Volume Unit", selection: $viewModel.volumeUnit) {
                ForEach(VolumeUnit.allCases) { unit in Text(unit.rawValue).tag(unit) }
            }
            .onChange(of: viewModel.volumeUnit) { newValue in viewModel.setVolumeUnit(newValue) }
            
            Button(action: { showingSuggestionSheet = true }) {
                Label("Calculate a Smart Goal", systemImage: "brain.head.profile")
            }.foregroundColor(.primary)
        }
    }
}
