//
//  MotivationManager.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  MotivationManager.swift
//  WaterTracker
//
//  This manager provides dynamic, motivational content for notifications.
//

import Foundation

class MotivationManager {
    static let shared = MotivationManager()
    
    private let proFacts: [String] = [
        "Did you know? Dehydration can lead to fatigue and headaches.",
        "Your brain is about 75% water. Keep it happy!",
        "Proper hydration helps regulate body temperature.",
        "Water is essential for nutrient absorption.",
        "Staying hydrated can improve your mood and cognitive function.",
        "A 2% drop in body water can cause a small but critical shrinkage of the brain.",
        "Drinking water can help boost your metabolism.",
        "Hydration is key for healthy skin and hair."
    ]
    
    private let defaultMessages: [String] = [
        "Time for a water break! 💧",
        "Stay hydrated to keep your energy levels up.",
        "A quick sip can make a big difference. Let's log some water."
    ]
    
    // Returns a random message, providing more variety for Pro users.
    func getMotivationalMessage(isPro: Bool) -> String {
        if isPro, !proFacts.isEmpty {
            return proFacts.randomElement()!
        }
        return defaultMessages.randomElement()!
    }
}
