//
//  SettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
//
//
//
//  SettingsView.swift
//  WaterTracker
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    // The ViewModel is the single source of truth for all state and logic.
    @StateObject private var viewModel = SettingsViewModel()
    // The StoreManager is passed via the environment to check for Pro status.
    @EnvironmentObject var storeManager: StoreManager
    
    // We get the presentationMode to know if this view was presented as a sheet.
    @Environment(\.presentationMode) var presentationMode
    
    // Local state for this view's sheets and alerts.
    @State private var showingSuggestionSheet = false
    @State private var showingDisableAlert = false
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    // Static data for the picker.
    let intervals = [60, 90, 120, 180, 240]

    var body: some View {
        NavigationView {
            formContent
                .navigationTitle("Settings")
                .toolbar {
                    // Only show the "Done" button if the view is presented modally (like a sheet).
                    if presentationMode.wrappedValue.isPresented {
                        ToolbarItem(placement: .navigationBarTrailing) {
                            Button("Done") {
                                presentationMode.wrappedValue.dismiss()
                            }
                            .fontWeight(.bold)
                        }
                    }
                }
        }
        // This style is better for iPad layouts within a TabView.
        .navigationViewStyle(.stack)
    }
    
    // The entire Form is extracted into its own computed property for stability and readability.
    private var formContent: some View {
        Form {
            // MARK: - Goal & Units Section
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
            
            // MARK: - Permissions Section
            Section(header: Text("Permissions")) {
                Button("Manage Health Access") {
                    if let url = URL(string: "x-apple-health://sources/bitdegree.WaterTracker") {
                        UIApplication.shared.open(url)
                    }
                }.foregroundColor(.primary)
            }
            
            // MARK: - Reminders Section
            Section(header: Text("Reminders")) {
                Toggle("Enable Reminders", isOn: $viewModel.remindersOn)
                    .onChange(of: viewModel.remindersOn) { isEnabled in
                        if !isEnabled {
                            showingDisableAlert = true
                        } else {
                            viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                        }
                    }
                
                if viewModel.remindersOn {
                    DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: viewModel.startTime) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
                    
                    DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: viewModel.endTime) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }

                    Picker("Frequency", selection: $viewModel.interval) {
                        ForEach(intervals, id: \.self) { mins in Text(mins < 120 ? "Every \(mins) minutes" : "Every \(mins/60) hours").tag(mins) }
                    }
                    .onChange(of: viewModel.interval) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
                    
                    if storeManager.isProUser {
                        Picker("Notification Sound", selection: $viewModel.soundName) {
                            Text("Default").tag("default")
                            Text("Droplet").tag("droplet.caf")
                            Text("Chime").tag("chime.caf")
                            Text("Bubbles").tag("bubbles.caf")
                        }
                        .onChange(of: viewModel.soundName) { _ in viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
                    } else {
                        HStack {
                            Text("Notification Sound")
                            Spacer()
                            Text("Pro Feature ✨")
                                .font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            .alert("Disable Reminders?", isPresented: $showingDisableAlert, actions: {
                Button("Keep On", role: .cancel) { viewModel.remindersOn = true }
                Button("Turn Off", role: .destructive) { viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser) }
            }, message: { Text("Staying hydrated is key to your well-being. Are you sure you want to turn off reminders?") })

            // MARK: - Appearance Section
            Section(header: Text("Appearance")) {
                if UIApplication.shared.supportsAlternateIcons {
                    Picker("App Icon", selection: $viewModel.selectedAppIcon) {
                        ForEach(AppIcon.allCases) { icon in
                            HStack {
                                Image(uiImage: UIImage(named: icon.previewName) ?? UIImage())
                                    .resizable().frame(width: 30, height: 30)
                                    .clipShape(RoundedRectangle(cornerRadius: 6))
                                Text(icon.rawValue)
                            }.tag(icon)
                        }
                    }
                }
            }
            
            // MARK: - Support & Feedback Section
            Section(header: Text("Support & Feedback")) {
                Button("Rate on the App Store") {
                    if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789?action=write-review") {
                        UIApplication.shared.open(url)
                    }
                }
                
                Button("Contact Support") {
                    if MFMailComposeViewController.canSendMail() {
                        self.showMailView = true
                    }
                }
                
                Link("Privacy Policy", destination: URL(string: "https://www.apple.com")!)
            }
            .foregroundColor(.primary)
        }
        .sheet(isPresented: $showingSuggestionSheet) {
            GoalSuggestionView(dailyGoal: $viewModel.dailyGoal) {
                showingSuggestionSheet = false
            }
        }
        .sheet(isPresented: $showMailView) {
            MailView(result: self.$mailResult)
        }
    }
}
