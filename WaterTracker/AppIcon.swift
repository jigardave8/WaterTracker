//
//  AppIcon.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//
//
//  AppIcon.swift
//  WaterTracker
//
//  This is the corrected version that includes the new 'pro' case,
//  which was missing.
//

import Foundation

enum AppIcon: String, CaseIterable, Identifiable {
    // --- THIS IS THE FIX ---
    // Added the new .pro case to the enum.
    case primary = "Default"
    case dark = "Dark"
    case orange = "Orange"
    case pro = "Pro" // New exclusive icon for Pro users
    
    var id: String { self.rawValue }
    
    var iconName: String? {
        switch self {
        case .primary:
            // `nil` is the special value that tells iOS to use the primary app icon.
            return nil
            
        case .dark:
            // This string MUST EXACTLY MATCH the name in Build Settings & Assets.
            return "AppIcon-Dark"
            
        case .orange:
            // This string MUST EXACTLY MATCH the name in Build Settings & Assets.
            return "AppIcon-Orange"
            
        case .pro:
            // This string MUST EXACTLY MATCH the name of your new Pro icon asset.
            return "AppIcon-Pro"
        }
    }
    
    var previewName: String {
        // Use `iconName` for alternate icons, and the default "AppIcon" for the primary one.
        return iconName ?? "AppIcon"
    }
}
