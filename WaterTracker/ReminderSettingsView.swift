//
//  ReminderSettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

import SwiftUI

struct ReminderSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var storeManager: StoreManager
    
    @State private var showingDisableAlert = false
    
    // Add the 1-minute interval for debugging
    #if DEBUG
    let intervals = [1, 5, 60, 90, 120, 180, 240]
    #else
    let intervals = [60, 90, 120, 180, 240]
    #endif
    
    var body: some View {
        Section(header: Text("Reminders")) {
            // The Toggle now binds to a separate onChange function for cleaner logic
            Toggle("Enable Reminders", isOn: $viewModel.remindersOn)
                .onChange(of: viewModel.remindersOn) { _, isNowEnabled in
                    handleReminderToggle(isNowEnabled: isNowEnabled)
                }
            
            if viewModel.remindersOn {
                DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                    .onChange(of: viewModel.startTime) { _,_ in
                        viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                    }
                
                DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                    .onChange(of: viewModel.endTime) { _,_ in
                        viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                    }
                
                Picker("Frequency", selection: $viewModel.interval) {
                    ForEach(intervals, id: \.self) { mins in
                        // Special text for debug intervals
                        if mins == 1 {
                            Text("Every 1 minute (Debug)").tag(mins)
                        } else if mins == 5 {
                            Text("Every 5 seconds (Debug)").tag(mins)
                        } else {
                            Text(mins < 120 ? "Every \(mins) minutes" : "Every \(mins/60) hours").tag(mins)
                        }
                    }
                }
                .onChange(of: viewModel.interval) { _,_ in
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
                .onChange(of: viewModel.soundName) { _,_ in
                    viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                }
            }
        }
        .alert("Disable Reminders?", isPresented: $showingDisableAlert, actions: {
            Button("Keep On", role: .cancel) {
                // If user cancels, revert the toggle state back to ON
                viewModel.remindersOn = true
            }
            Button("Turn Off", role: .destructive) {
                // If user confirms, now we schedule the update (which will cancel all notifications)
                viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
            }
        }, message: { Text("Staying hydrated is key. Are you sure you want to turn off reminders?") })
    }
    
    // --- REFINED LOGIC for handling the toggle ---
    private func handleReminderToggle(isNowEnabled: Bool) {
        if isNowEnabled {
            // If turning ON, request permissions first.
            NotificationManager.shared.requestAuthorization { granted in
                if granted {
                    // If permission granted, schedule the notifications.
                    viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                } else {
                    // If permission is denied, immediately revert the toggle back to OFF.
                    viewModel.remindersOn = false
                }
            }
        } else {
            // If turning OFF, just show the confirmation alert.
            // The alert's buttons will handle the next step.
            showingDisableAlert = true
        }
    }
}
