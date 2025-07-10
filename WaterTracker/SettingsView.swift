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
    @StateObject private var viewModel = SettingsViewModel()
    
    @Environment(\.dismiss) var dismiss
    @State private var showingSuggestionSheet = false
    
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    let intervals = [60, 90, 120, 180, 240]

    var body: some View {
        NavigationView {
            formContent
                .navigationTitle("Settings")
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") { dismiss() }.fontWeight(.bold)
                    }
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
    
    private var formContent: some View {
        Form {
            Section(header: Text("Goal & Units")) {
                Stepper("\(Int(viewModel.dailyGoal)) \(viewModel.volumeUnit.rawValue)", value: $viewModel.dailyGoal, in: 500...10000, step: 50)
                    .onChange(of: viewModel.dailyGoal) { newValue in
                        viewModel.setDailyGoal(newValue)
                    }
                
                Picker("Volume Unit", selection: $viewModel.volumeUnit) {
                    ForEach(VolumeUnit.allCases) { unit in
                        Text(unit.rawValue).tag(unit)
                    }
                }
                .onChange(of: viewModel.volumeUnit) { newValue in
                    viewModel.setVolumeUnit(newValue)
                }
                
                Button(action: { showingSuggestionSheet = true }) {
                    Label("Calculate a Smart Goal", systemImage: "brain.head.profile")
                }.foregroundColor(.primary)
            }
            
            Section(header: Text("Permissions")) {
                Button("Manage Health Access") {
                    if let url = URL(string: "x-apple-health://sources/bitdegree.WaterTracker") {
                        UIApplication.shared.open(url)
                    }
                }
                .foregroundColor(.primary)
            }
            
            Section(header: Text("Reminders")) {
                Toggle("Enable Reminders", isOn: $viewModel.remindersOn)
                    // --- THE FIX IS HERE ---
                    // We now explicitly call scheduleNotifications when the user changes a setting.
                    // This is clear, intentional, and avoids race conditions.
                    .onChange(of: viewModel.remindersOn) { _ in viewModel.scheduleNotifications() }
                
                if viewModel.remindersOn {
                    DatePicker("Start Time", selection: $viewModel.startTime, displayedComponents: .hourAndMinute)
                        .onChange(of: viewModel.startTime) { _ in viewModel.scheduleNotifications() }
                    
                    DatePicker("End Time", selection: $viewModel.endTime, displayedComponents: .hourAndMinute)
                        .onChange(of: viewModel.endTime) { _ in viewModel.scheduleNotifications() }

                    Picker("Frequency", selection: $viewModel.interval) {
                        ForEach(intervals, id: \.self) { mins in
                            Text(mins < 120 ? "Every \(mins) minutes" : "Every \(mins/60) hours").tag(mins)
                        }
                    }
                    .onChange(of: viewModel.interval) { _ in viewModel.scheduleNotifications() }
                }
            }

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
    }
}
