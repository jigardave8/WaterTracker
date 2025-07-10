//
//  IntakeSelectionView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
//
//
//  IntakeSelectionView.swift
//  WaterTracker
//

import SwiftUI

struct IntakeSelectionView: View {
    let drink: Drink
    
    @EnvironmentObject var healthManager: HealthKitManager
    @Environment(\.dismiss) var dismiss

    private let sizes: [Double] = [250, 330, 500, 750]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Log \(drink.name)")
                    .font(.largeTitle).fontWeight(.bold)
                
                // --- MODIFIED: Use the new .icon property ---
                drink.icon
                    .font(.system(size: 80)).foregroundColor(drink.color)

                Text("Hydration Factor: \(Int(drink.hydrationFactor * 100))%")
                    .font(.title3).foregroundColor(.secondary).padding(.bottom)
                
                Text("Select Size").font(.headline)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(sizes, id: \.self) { size in
                        Button(action: {
                            healthManager.saveWaterIntake(drink: drink, amountInML: size)
                            dismiss()
                        }) {
                            Text("\(Int(size)) ml")
                                .font(.title2).fontWeight(.semibold)
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(drink.color.opacity(0.15))
                                .cornerRadius(15).foregroundColor(.primary)
                        }
                    }
                }
                .padding()
                Spacer()
            }
            .padding(.top, 20)
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}
