//
//  WatchSettings.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

//
//  WatchSettings.swift
//  WaterTrackerWatch Watch App
//
//  Created by BitDegree on 11/07/25.
//

import Foundation
import Combine

// This is a lightweight observable object just for the watch UI.
class WatchSettings: ObservableObject {
    @Published var volumeUnit: VolumeUnit
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        // Load the initial value from the shared cloud manager.
        self.volumeUnit = CloudSettingsManager.shared.getVolumeUnit()
        
        // Listen for the notification that settings have changed (e.g., from the iPhone)
        NotificationCenter.default.publisher(for: .settingsDidChange)
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                // When changes happen, reload the value.
                self?.volumeUnit = CloudSettingsManager.shared.getVolumeUnit()
            }
            .store(in: &cancellables)
    }
}
