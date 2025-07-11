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

import SwiftUI

struct ReminderSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var storeManager: StoreManager
    
    @State private var showingDisableAlert = false
    
    #if DEBUG
    let intervals = [5, 60, 90, 120, 180, 240]
    #else
    let intervals = [60, 90, 120, 180, 240]
    #endif
    
    var body: some View {
        Section(header: Text("Reminders")) {
            Toggle("Enable Reminders", isOn: $viewModel.remindersOn)
                .onChange(of: viewModel.remindersOn) {
                    handleReminderToggle(isNowEnabled: viewModel.remindersOn)
                }
            
            if viewModel.remindersOn {
                DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    .onChange(of: viewModel.startTime) {
                        viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                    }
                
                DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                    .onChange(of: viewModel.endTime) {
                        viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                    }
                
                Picker("Frequency", selection: $viewModel.interval) {
                    ForEach(intervals, id: \.self) { mins in
                        if mins == 5 {
                            Text("Every 5 seconds (Debug)").tag(mins)
                        } else {
                            Text(mins < 120 ? "Every \(mins) minutes" : "Every \(mins/60) hours").tag(mins)
                        }
                    }
                }
                .onChange(of: viewModel.interval) {
                    viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                }
                
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
                .onChange(of: viewModel.soundName) {
                    viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                }
            }
        }
        .alert("Disable Reminders?", isPresented: $showingDisableAlert, actions: {
            Button("Keep On", role: .cancel) { viewModel.remindersOn = true }
            Button("Turn Off", role: .destructive) { viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
        }, message: { Text("Staying hydrated is key to your well-being. Are you sure you want to turn off reminders?") })
    }
    
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
