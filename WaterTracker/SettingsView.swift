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

import SwiftUI

// This view is presented modally for app settings.
struct SettingsView: View {
    @Binding var dailyGoal: Double
    @Binding var notificationsEnabled: Bool
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Daily Goal")) {
                    Stepper("\(Int(dailyGoal)) ml", value: $dailyGoal, in: 500...10000, step: 250)
                }
                
                Section(header: Text("Reminders")) {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                }
            }
            .navigationTitle("Settings")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .fontWeight(.bold)
                }
            }
        }
    }
}

struct SettingsView_Previews: PreviewProvider {
    static var previews: some View {
        // Use .constant for previewing views with @Binding
        SettingsView(dailyGoal: .constant(2500), notificationsEnabled: .constant(false))
    }
}
