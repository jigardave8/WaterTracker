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
//  This is the main container for the multi-page onboarding flow, shown only
//  to first-time users. It uses a TabView with a page style.
//

import SwiftUI

struct OnboardingView: View {
    // This property, when set to false, dismisses the onboarding flow.
    @Binding var isOnboarding: Bool
    
    var body: some View {
        TabView {
            // Page 1: Welcome
            OnboardingPage(
                imageName: "drop.fill",
                title: "Welcome to WaterTracker",
                description: "Your simple, beautiful companion to stay hydrated and healthy."
            )
            
            // Page 2: HealthKit Permission
            OnboardingPage(
                imageName: "heart.text.square.fill",
                title: "Integrate with Health",
                description: "We use Apple Health to securely save your data and sync across all your devices.",
                isPermissionPage: true,
                permissionAction: {
                    // Instantiating the manager triggers the permission prompt.
                    _ = HealthKitManager()
                }
            )
            
            // Page 3: Smart Goal Setup
            OnboardingGoalSetupPage(isOnboarding: $isOnboarding)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .background(Color(.systemGroupedBackground))
        .ignoresSafeArea(.all)
    }
}

// A reusable view for the informational onboarding pages
struct OnboardingPage: View {
    let imageName: String
    let title: String
    let description: String
    var isPermissionPage: Bool = false
    var permissionAction: (() -> Void)? = nil
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            Image(systemName: imageName)
                .font(.system(size: 100))
                .foregroundColor(.blue)
                .padding(.bottom, 20)
            
            Text(title)
                .font(.largeTitle)
                .fontWeight(.bold)
                .multilineTextAlignment(.center)
            
            Text(description)
                .font(.headline)
                .multilineTextAlignment(.center)
                .foregroundColor(.secondary)
            
            if isPermissionPage {
                Button(action: {
                    permissionAction?()
                }) {
                    Text("Allow Access")
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.top, 30)
            }
            Spacer()
            Spacer()
        }
        .padding(40)
    }
}

// A special wrapper view for the goal setup page during onboarding
struct OnboardingGoalSetupPage: View {
    @Binding var isOnboarding: Bool
    // Use a local state for the goal during setup
    @State private var tempGoal: Double = 2500
    
    var body: some View {
        GoalSuggestionView(dailyGoal: $tempGoal, isFromOnboarding: true) {
            // This is the completion handler. When the user saves their goal,
            // we save it to our Cloud manager and turn off the onboarding flag.
            CloudSettingsManager.shared.setDailyGoal(tempGoal)
            isOnboarding = false
        }
    }
}
