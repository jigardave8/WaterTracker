//
//  OnboardingView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

import SwiftUI
import HealthKit

struct OnboardingView: View {
    @Binding var isOnboarding: Bool
    
    @State private var healthAccessGranted = false
    @State private var notificationAccessGranted = false
    @State private var showHealthDeniedAlert = false
    @State private var showNotificationDeniedAlert = false
    @State private var isGoalSet = false
    
    init(isOnboarding: Binding<Bool>) {
        self._isOnboarding = isOnboarding
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let status = HKHealthStore().authorizationStatus(for: waterType)
        if status == .sharingAuthorized {
            self._healthAccessGranted = State(initialValue: true)
        }
    }
    
    var body: some View {
        TabView {
            OnboardingPage(imageName: "drop.fill", title: "Welcome to WaterTracker", description: "Your companion to stay hydrated and healthy.")
            
            OnboardingPage(
                imageName: "heart.text.square.fill",
                title: "Integrate with Health",
                description: "Securely save your data and sync across devices.",
                isPermissionPage: true,
                buttonText: healthAccessGranted ? "Access Granted" : "Allow Health Access",
                isButtonDisabled: healthAccessGranted,
                buttonIcon: healthAccessGranted ? "checkmark" : nil
            )
            .onAppear(perform: requestHealthPermission)
            
            OnboardingPage(
                imageName: "bell.badge.fill",
                title: "Enable Reminders",
                description: "Let us help you stay on track with periodic notifications.",
                isPermissionPage: true,
                buttonText: notificationAccessGranted ? "Reminders Enabled" : "Enable Reminders",
                isButtonDisabled: notificationAccessGranted,
                buttonIcon: notificationAccessGranted ? "checkmark" : nil
            )
            .onAppear(perform: requestNotificationPermission)

            OnboardingGoalSetupPage(isGoalSet: $isGoalSet)
            
            OnboardingCompletionPage(isOnboarding: $isOnboarding)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.appBackground.ignoresSafeArea())
        .alert("Health Access Required", isPresented: $showHealthDeniedAlert) {
            Button("Go to Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("To save and track your water intake, WaterTracker needs permission to access Health data. Please enable it in Settings.")
        }
        .alert("Enable Notifications?", isPresented: $showNotificationDeniedAlert) {
            Button("Go to Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Maybe Later", role: .cancel) {}
        } message: {
            Text("To send helpful reminders, WaterTracker needs permission to send notifications. You can enable this in Settings.")
        }
    }
    
    private func requestHealthPermission() {
        guard !healthAccessGranted else { return }
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        HKHealthStore().requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
            DispatchQueue.main.async {
                if success {
                    self.healthAccessGranted = true
                } else {
                    self.showHealthDeniedAlert = true
                }
            }
        }
    }
    
    private func requestNotificationPermission() {
        guard !notificationAccessGranted else { return }
        NotificationManager.shared.requestAuthorization { granted in
            DispatchQueue.main.async {
                if granted {
                    UserDefaults.standard.set(true, forKey: "remindersOn")
                    self.notificationAccessGranted = true
                } else {
                    self.showNotificationDeniedAlert = true
                }
            }
        }
    }
}

// --- ONBOARDING PAGE SUB-VIEWS ---

struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    var isPermissionPage: Bool = false
    var buttonText: String = "Continue"
    var isButtonDisabled: Bool = false
    var buttonIcon: String? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageName).font(.system(size: 100)).foregroundColor(.primaryBlue).padding(.bottom, 20)
            Text(title).font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
            Text(description).font(.headline).multilineTextAlignment(.center).foregroundColor(.secondary)
            
            if isPermissionPage {
                Button(action: {}) {
                    HStack {
                        if let icon = buttonIcon { Image(systemName: icon) }
                        Text(buttonText)
                    }
                    .fontWeight(.bold).padding().frame(maxWidth: .infinity)
                    // --- THIS IS THE FIX ---
                    // The .background modifier now calls a helper function that returns a View.
                    .background(buttonBackgroundStyle())
                    .foregroundColor(.white).cornerRadius(12)
                }
                .disabled(true)
                .padding(.top, 30)
                .animation(.default, value: isButtonDisabled)
            }
            Spacer()
            Spacer()
        }.padding(40)
    }
    
    // This helper function uses @ViewBuilder to return the correct background style,
    // resolving the type mismatch error.
    @ViewBuilder
    private func buttonBackgroundStyle() -> some View {
        if isButtonDisabled {
            Color.green
        } else {
            Color.accentGradient
        }
    }
}

struct OnboardingGoalSetupPage: View {
    @Binding var isGoalSet: Bool
    @State private var tempGoal: Double = 2500

    var body: some View {
        GoalSuggestionView(
            dailyGoal: $tempGoal,
            isFromOnboarding: true,
            isCompleted: $isGoalSet
        ) {
            CloudSettingsManager.shared.setDailyGoal(tempGoal)
            isGoalSet = true
        }
    }
}

struct OnboardingCompletionPage: View {
    @Binding var isOnboarding: Bool
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: "checkmark.circle.fill").font(.system(size: 100)).foregroundColor(.green)
            Text("You're All Set!").font(.largeTitle).fontWeight(.bold)
            Text("Let's start your hydration journey together.").font(.headline).foregroundColor(.secondary)
            Button(action: { isOnboarding = false }) {
                Text("Get Started").fontWeight(.bold).padding().frame(maxWidth: .infinity).background(Color.accentGradient).foregroundColor(.white).cornerRadius(12)
            }.padding(.top, 30)
            Spacer()
            Spacer()
        }.padding(40)
    }
}
