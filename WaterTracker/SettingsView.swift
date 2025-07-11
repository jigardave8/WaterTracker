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
//  This is the final, stable version. Its body is composed of dedicated
//  sub-views that exist in their own files. This guarantees compiler stability.
//

import SwiftUI
import MessageUI

struct SettingsView: View {
    @StateObject private var viewModel = SettingsViewModel()
    @EnvironmentObject var storeManager: StoreManager
    @Environment(\.presentationMode) var presentationMode
    
    // State for child views is managed here and passed as bindings.
    @State private var showingSuggestionSheet = false
    @State private var showMailView = false
    @State private var mailResult: Result<MFMailComposeResult, Error>? = nil
    
    var body: some View {
        NavigationView {
            Form {
                // Each complex section is now its own, isolated view from its own file.
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
    
    // The check for system-level notification permissions remains here.
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

// NOTE: ALL LOCAL STRUCT DEFINITIONS HAVE BEEN REMOVED FROM THIS FILE.
// THEY NOW EXIST IN THEIR OWN DEDICATED FILES.
