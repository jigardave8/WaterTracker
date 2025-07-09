//
//  AppIcon.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// AppIcon.swift
// Target: WaterTracker

import Foundation

enum AppIcon: String, CaseIterable, Identifiable {
    case primary = "Default"
    case dark = "Dark"
    case orange = "Orange"
    
    var id: String { self.rawValue }
    
    var iconName: String? {
        switch self {
        case .primary:
            return nil // `nil` represents the primary icon
        case .dark:
            return "AppIcon-Dark" // Must match the name in Assets.xcassets
        case .orange:
            return "AppIcon-Orange" // Must match the name in Assets.xcassets
        }
    }
    
    var previewName: String {
        switch self {
        case .primary:
            return "AppIcon" // The default icon in the asset catalog
        case .dark:
            return "AppIcon-Dark"
        case .orange:
            return "AppIcon-Orange"
        }
    }
}
