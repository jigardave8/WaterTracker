//
//  SettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
//
//
//  SettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    // Receives the shared SettingsViewModel from the environment.
    @EnvironmentObject var viewModel: SettingsViewModel
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.presentationMode) var presentationMode
    
    // State for child views is managed here and passed as bindings.
    @State private var showingSuggestionSheet = false
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        NavigationView {
            Form {
                GoalAndUnitsSettingsView(viewModel: viewModel, showingSuggestionSheet: $showingSuggestionSheet)
                
                PermissionsSettingsView()
                
                ReminderSettingsView(viewModel: viewModel, storeManager: storeManager)
                
                AppearanceSettingsView(viewModel: viewModel, storeManager: storeManager)
                
                SupportSettingsView(showMailView: $showMailView)
            }
            .navigationTitle("Settings")
            .toolbar {
                if presentationMode.wrappedValue.isPresented {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Done") {
                            presentationMode.wrappedValue.dismiss()
                        }.fontWeight(.bold)
                    }
                }
            }
        }
        .navigationViewStyle(.stack)
        .onAppear(perform: checkSystemNotificationStatus)
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            checkSystemNotificationStatus()
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

    private func checkSystemNotificationStatus() {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized && viewModel.remindersOn {
                    print("System permissions are off. Forcing toggle to off state.")
                    viewModel.remindersOn = false
                    viewModel.handleReminderSettingsChange(isPro: storeManager.isProUser)
                }
            }
        }
    }
}
