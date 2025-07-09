//
//  SettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

//
//  SettingsView.swift
//  WaterTracker
//
//  This is the main settings hub for the app, allowing users to configure their
//  goal, units, notifications, and app icon.
//

import SwiftUI

struct SettingsView: View {
    @Binding var dailyGoal: Double
    @Environment(\.dismiss) var dismiss
    @StateObject private var settingsManager = SettingsManager()
    
    @State private var showingSuggestionSheet = false
    
    // State for advanced reminders, saved in UserDefaults.
    @AppStorage("remindersOn") private var remindersOn = false
    @AppStorage("reminderStartTime") private var startTime = Calendar.current.date(byAdding: .hour, value: 8, to: Date.now.startOfDay)!
    @AppStorage("reminderEndTime") private var endTime = Calendar.current.date(byAdding: .hour, value: 22, to: Date.now.startOfDay)!
    @AppStorage("reminderInterval") private var interval = 120 // in minutes
    
    let intervals = [60, 90, 120, 180, 240]
    
    // State for App Icon selection.
    @State private var selectedAppIcon = AppIcon.primary
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Goal & Units")) {
                    Stepper("\(Int(dailyGoal)) \(settingsManager.volumeUnit.rawValue)", value: $dailyGoal, in: 500...10000, step: 50)
                    Picker("Volume Unit", selection: $settingsManager.volumeUnit) {
                        ForEach(VolumeUnit.allCases) { unit in
                            Text(unit.rawValue).tag(unit)
                        }
                    }
                    Button(action: { showingSuggestionSheet = true }) {
                        Label("Calculate a Smart Goal", systemImage: "brain.head.profile")
                    }.foregroundColor(.primary)
                }
                
                Section(header: Text("Reminders")) {
                    Toggle("Enable Reminders", isOn: $remindersOn)
                    if remindersOn {
                        DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                        DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                        Picker("Frequency", selection: $interval) {
                            ForEach(intervals, id: \.self) { mins in
                                Text(mins < 120 ? "Every \(mins) minutes" : "Every \(mins/60) hours").tag(mins)
                            }
                        }
                    }
                }
                .onChange(of: remindersOn) { _ in scheduleNotifications() }
                .onChange(of: startTime) { _ in scheduleNotifications() }
                .onChange(of: endTime) { _ in scheduleNotifications() }
                .onChange(of: interval) { _ in scheduleNotifications() }

                Section(header: Text("Appearance")) {
                    if UIApplication.shared.supportsAlternateIcons {
                        Picker("App Icon", selection: $selectedAppIcon) {
                            ForEach(AppIcon.allCases) { icon in
                                HStack {
                                    Image(uiImage: UIImage(named: icon.previewName) ?? UIImage())
                                        .resizable().frame(width: 30, height: 30)
                                        .clipShape(RoundedRectangle(cornerRadius: 6))
                                    Text(icon.rawValue)
                                }.tag(icon)
                            }
                        }
                        .onChange(of: selectedAppIcon) { newValue in
                            UIApplication.shared.setAlternateIconName(newValue.iconName)
                        }
                    }
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") { dismiss() }.fontWeight(.bold)
                }
            }
            .sheet(isPresented: $showingSuggestionSheet) {
                GoalSuggestionView(dailyGoal: $dailyGoal)
            }
            .onAppear(perform: loadInitialSettings)
        }
    }
    
    private func scheduleNotifications() {
        NotificationManager.shared.scheduleAdvancedReminders(isEnabled: remindersOn, startTime: startTime, endTime: endTime, intervalInMinutes: interval)
    }
    
    private func loadInitialSettings() {
        // Load the currently active app icon to set the picker's state.
        if let iconName = UIApplication.shared.alternateIconName {
            selectedAppIcon = AppIcon.allCases.first { $0.iconName == iconName } ?? .primary
        } else {
            selectedAppIcon = .primary
        }
    }
}

// Helper extension to get the start of the day.
extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }
}
