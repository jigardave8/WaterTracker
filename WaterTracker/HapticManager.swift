//
//  HapticManager.swift
//  WaterTracker
//
//  Created by BitDegree on 09/07/25.
//

// HapticManager.swift
// Targets: WaterTracker, WaterTrackerWatch

import SwiftUI

class HapticManager {
    static let shared = HapticManager()
    private init() { }
    
    func simpleSuccess() {
        #if os(iOS)
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        #elseif os(watchOS)
        WKInterfaceDevice.current().play(.success)
        #endif
    }
}
