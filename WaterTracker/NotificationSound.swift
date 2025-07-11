//
//  NotificationSound.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

//
//  NotificationSound.swift
//  WaterTracker
//
//  This file defines the data model for our custom notification sounds.
//  It includes the display name for the UI, the actual file name in the app bundle,
//  and whether the sound requires a Pro purchase to use.
//

import Foundation

struct NotificationSound: Identifiable, Hashable {
    let id: String // The file name can serve as the unique ID
    let displayName: String
    let fileName: String
    let isPro: Bool
    
    // --- The Definitive List of All Available Sounds ---
    // This is the single source of truth for sounds in the app.
    static let allSounds: [NotificationSound] = [
        // Free Sounds
        .init(id: "default", displayName: "Default", fileName: "default", isPro: false),
        .init(id: "droplet.caf", displayName: "Droplet", fileName: "droplet.caf", isPro: false),
        
        // Pro Sounds
        .init(id: "bubbles.caf", displayName: "Bubbles", fileName: "bubbles.caf", isPro: true),
        .init(id: "chime.caf", displayName: "Chime", fileName: "chime.caf", isPro: true)
        
        // Add more sounds here in the future as needed.
        // Remember to also add the sound file to the project bundle.
    ]
}
