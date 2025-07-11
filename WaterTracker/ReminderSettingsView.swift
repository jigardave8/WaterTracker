//
//  ReminderSettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

//
//  ReminderSettingsView.swift
//  WaterTracker
//
//  This dedicated view encapsulates all UI and logic for the Reminders section,
//  solving the compiler performance issues by isolating the complexity.
//

import SwiftUI

struct ReminderSettingsView: View {
    // This view receives the ViewModel and StoreManager from its parent (SettingsView).
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var storeManager: StoreManager
    
    // The alert is now managed locally within this specific view.
    @State private var showingDisableAlert = false
    
    #if DEBUG
    let intervals = [5, 60, 90, 120, 180, 240]
    #else
    let intervals = [60, 90, 120, 180, 240]
    #endif
    
    var body: some View {
        Section(header: Text("Reminders")) {
            Toggle("Enable Reminders", isOn: $viewModel.remindersOn)
                .onChange(of: viewModel.remindersOn, perform: handleReminderToggle)
            
            if viewModel.remindersOn {
                // The details are now cleanly contained here.
                DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    .onChange(of: viewModel.startTime) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
                
                DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                    .onChange(of: viewModel.endTime) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
                
                Picker("Frequency", selection: $viewModel.interval) {
                    ForEach(intervals, id: \.self) { mins in
                        if mins == 5 {
                            Text("Every 5 seconds (Debug)").tag(mins)
                        } else {
                            Text(mins < 120 ? "Every \(mins) minutes" : "Every \(mins/60) hours").tag(mins)
                        }
                    }
                }
                .onChange(of: viewModel.interval) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
                
                Picker("Notification Sound", selection: $viewModel.soundName) {
                    ForEach(NotificationSound.allSounds) { sound in
                        HStack {
                            Text(sound.displayName)
                            if sound.isPro {
                                Spacer()
                                Image(systemName: "star.fill").foregroundColor(.yellow).font(.caption)
                            }
                        }
                        .tag(sound.fileName)
                        .disabled(sound.isPro && !storeManager.isProUser)
                    }
                }
                .onChange(of: viewModel.soundName) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
            }
        }
        .alert("Disable Reminders?", isPresented: $showingDisableAlert, actions: {
            Button("Keep On", role: .cancel) { viewModel.remindersOn = true }
            Button("Turn Off", role: .destructive) { viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
        }, message: { Text("Staying hydrated is key to your well-being. Are you sure you want to turn off reminders?") })
    }
    
    // The toggle logic now lives here, close to the UI it controls.
    private func handleReminderToggle(isNowEnabled: Bool) {
        if isNowEnabled {
            NotificationManager.shared.requestAuthorization { granted in
                if granted {
                    viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                } else {
                    viewModel.remindersOn = false
                }
            }
        } else {
            showingDisableAlert = true
        }
    }
}
