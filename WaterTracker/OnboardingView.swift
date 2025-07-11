//
//  OnboardingView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//
//
//  OnboardingView.swift
//  WaterTracker
//
//  A dynamic onboarding flow with state changes for user feedback.
//

import SwiftUI
import HealthKit

struct OnboardingView: View {
    @Binding var isOnboarding: Bool
    
    // State to track permission status for instant UI feedback.
    @State private var healthAccessGranted = false
    @State private var notificationAccessGranted = false
    
    init(isOnboarding: Binding<Bool>) {
        self._isOnboarding = isOnboarding
        // Check initial HealthKit status when the view is created
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        let status = HKHealthStore().authorizationStatus(for: waterType)
        if status == .sharingAuthorized {
            // Use _property = State(initialValue:) to set state in an init
            self._healthAccessGranted = State(initialValue: true)
        }
    }
    
    var body: some View {
        TabView {
            OnboardingPage(imageName: "drop.fill", title: "Welcome to WaterTracker", description: "Your simple, beautiful companion to stay hydrated and healthy.")
            
            OnboardingPage(
                imageName: "heart.text.square.fill",
                title: "Integrate with Health",
                description: "Securely save your data and sync across all your devices.",
                isPermissionPage: true,
                buttonText: healthAccessGranted ? "Access Granted" : "Allow Health Access",
                isButtonDisabled: healthAccessGranted,
                buttonIcon: healthAccessGranted ? "checkmark" : nil
            ) {
                let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
                HKHealthStore().requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
                    if success {
                        DispatchQueue.main.async { self.healthAccessGranted = true }
                    }
                }
            }
            
            OnboardingPage(
                imageName: "bell.badge.fill",
                title: "Enable Reminders",
                description: "Let us help you stay on track with periodic notifications.",
                isPermissionPage: true,
                buttonText: notificationAccessGranted ? "Reminders Enabled" : "Enable Reminders",
                isButtonDisabled: notificationAccessGranted,
                buttonIcon: notificationAccessGranted ? "checkmark" : nil
            ) {
                NotificationManager.shared.requestAuthorization { granted in
                    if granted {
                        UserDefaults.standard.set(true, forKey: "remindersOn")
                        self.notificationAccessGranted = true
                    }
                }
            }

            // --- The previously missing structs are now included ---
            OnboardingGoalSetupPage()
            
            OnboardingCompletionPage(isOnboarding: $isOnboarding)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.appBackground)
        .ignoresSafeArea(.all)
        .onAppear {
            UNUserNotificationCenter.current().getNotificationSettings { settings in
                if settings.authorizationStatus == .authorized {
                    DispatchQueue.main.async { self.notificationAccessGranted = true }
                }
            }
        }
    }
}

// Reusable Onboarding Page View
struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    var isPermissionPage: Bool = false
    var buttonText: String = "Continue"
    var isButtonDisabled: Bool = false
    var buttonIcon: String? = nil
    var permissionAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageName).font(.system(size: 100)).foregroundColor(.primaryBlue).padding(.bottom, 20)
            Text(title).font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
            Text(description).font(.headline).multilineTextAlignment(.center).foregroundColor(.secondary)
            
            if isPermissionPage {
                Button(action: { permissionAction?() }) {
                    HStack {
                        if let icon = buttonIcon { Image(systemName: icon) }
                        Text(buttonText)
                    }
                    .fontWeight(.bold).padding().frame(maxWidth: .infinity)
                    // --- THIS IS THE FIX for the color/gradient mismatch ---
                    // We now return a ShapeStyle, which can be a Color or a Gradient.
                    .background(backgroundStyle())
                    .foregroundColor(.white).cornerRadius(12)
                }
                .disabled(isButtonDisabled)
                .padding(.top, 30)
                .animation(.default, value: isButtonDisabled)
            }
            Spacer()
            Spacer()
        }.padding(40)
    }
    
    // Helper function to return the correct ShapeStyle, resolving the type mismatch.
    @ViewBuilder
    private func backgroundStyle() -> some View {
        if isButtonDisabled {
            Color.green
        } else {
            Color.accentGradient
        }
    }
}

// Wrapper for Goal Suggestion page in onboarding
struct OnboardingGoalSetupPage: View {
    @State private var tempGoal: Double = 2500
    var body: some View {
        GoalSuggestionView(dailyGoal: $tempGoal, isFromOnboarding: true) {
            CloudSettingsManager.shared.setDailyGoal(tempGoal)
        }
    }
}

// Final "You're All Set!" page
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
