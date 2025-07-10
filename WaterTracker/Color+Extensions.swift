//
//  Color+Extensions.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  Color+Extensions.swift
//  WaterTracker
//
//  This file defines the app's central color scheme for a consistent look.
//

import SwiftUI

extension Color {
    // A very light gray for the main background.
    static let appBackground = Color("AppBackgroundColor")
    
    // The primary accent blue color.
    static let primaryBlue = Color("PrimaryBlueColor")
    
    // A reusable gradient for buttons and fills.
    static let accentGradient = LinearGradient(
        gradient: Gradient(colors: [Color.primaryBlue, Color.blue.opacity(0.8)]),
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

// ACTION: In your Assets.xcassets, create two new "Color Sets":
// 1. Name: "AppBackgroundColor" -> Set its "Any Appearance" to a light gray (e.g., System Gray 6).
// 2. Name: "PrimaryBlueColor" -> Set its "Any Appearance" to a vibrant blue (e.g., #0A84FF).
