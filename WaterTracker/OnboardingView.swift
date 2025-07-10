//
//  OnboardingView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//
//
//
//  OnboardingView.swift
//  WaterTracker
//
//  A complete onboarding flow with permissions and a final completion page.
//

import SwiftUI

struct OnboardingView: View {
    @Binding var isOnboarding: Bool
    
    var body: some View {
        TabView {
            // Page 1: Welcome
            OnboardingPage(imageName: "drop.fill", title: "Welcome to WaterTracker", description: "Your simple, beautiful companion to stay hydrated and healthy.")
            
            // Page 2: HealthKit Permission
            OnboardingPage(imageName: "heart.text.square.fill", title: "Integrate with Health", description: "Securely save your data and sync across all your devices.", isPermissionPage: true, buttonText: "Allow Health Access") {
                _ = HealthKitManager()
            }
            
            // Page 3: Notification Permission
            OnboardingPage(imageName: "bell.badge.fill", title: "Enable Reminders", description: "Let us help you stay on track with periodic notifications.", isPermissionPage: true, buttonText: "Enable Reminders") {
                NotificationManager.shared.requestAuthorization { granted in
                    // If granted, we can turn the reminders on by default.
                    if granted {
                        UserDefaults.standard.set(true, forKey: "remindersOn")
                    }
                }
            }

            // Page 4: Smart Goal Setup
            OnboardingGoalSetupPage()
            
            // Page 5: Completion
            OnboardingCompletionPage(isOnboarding: $isOnboarding)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color.appBackground)
        .ignoresSafeArea(.all)
    }
}

// Reusable Onboarding Page View
struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    var isPermissionPage: Bool = false
    var buttonText: String = "Continue"
    var permissionAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageName).font(.system(size: 100)).foregroundColor(.primaryBlue).padding(.bottom, 20)
            Text(title).font(.largeTitle).fontWeight(.bold).multilineTextAlignment(.center)
            Text(description).font(.headline).multilineTextAlignment(.center).foregroundColor(.secondary)
            
            if isPermissionPage {
                Button(action: { permissionAction?() }) {
                    Text(buttonText).fontWeight(.bold).padding().frame(maxWidth: .infinity).background(Color.accentGradient).foregroundColor(.white).cornerRadius(12)
                }.padding(.top, 30)
            }
            Spacer()
            Spacer()
        }.padding(40)
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
