//
//  Drink.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

// Drink.swift (New File, Shared Target)

import Foundation
import SwiftUI

struct Drink: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let hydrationFactor: Double // e.g., Water is 1.0, Coffee is 0.8
    let imageName: String
    let color: Color
    
    static let allDrinks: [Drink] = [
        Drink(name: "Water", hydrationFactor: 1.0, imageName: "drop.fill", color: .blue),
        Drink(name: "Coffee", hydrationFactor: 0.8, imageName: "cup.and.saucer.fill", color: .brown),
        Drink(name: "Tea", hydrationFactor: 0.9, imageName: "mug.fill", color: .green),
        Drink(name: "Juice", hydrationFactor: 0.85, imageName: "juice.fill", color: .orange) // Requires SF Symbols 4
    ]
}

// A custom symbol for Juice if you don't have SF Symbols 4
// Just for demonstration, use a real symbol if available.
struct JuiceSymbol: View {
    var body: some View {
        ZStack {
            Image(systemName: "square.fill")
            Image(systemName: "leaf.fill").foregroundColor(.white)
        }
    }
}
