//
//  Drink.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
//
//  Drink.swift
//  WaterTracker
//

import Foundation
import SwiftUI

struct Drink: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let hydrationFactor: Double
    let imageName: String
    let color: Color
    
    // --- NEW: A computed property to handle the icon availability ---
    var icon: Image {
        // The `juice.fill` symbol is only available on iOS 16 and later.
        if self.imageName == "juice.fill" {
            if #available(iOS 16.0, *) {
                return Image(systemName: "juice.fill")
            } else {
                // Fallback for older iOS versions.
                return Image(systemName: "cup.and.saucer.fill")
            }
        }
        return Image(systemName: self.imageName)
    }
    
    static let allDrinks: [Drink] = [
        Drink(name: "Water", hydrationFactor: 1.0, imageName: "drop.fill", color: .blue),
        Drink(name: "Coffee", hydrationFactor: 0.8, imageName: "cup.and.saucer.fill", color: .brown),
        Drink(name: "Tea", hydrationFactor: 0.9, imageName: "mug.fill", color: .green),
        Drink(name: "Juice", hydrationFactor: 0.85, imageName: "juice.fill", color: .orange)
    ]
}
