//
//  IntakeSelectionView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

import SwiftUI

struct IntakeSelectionView: View {
    let drink: Drink
    
    @EnvironmentObject var healthManager: HealthKitManager
    @Environment(\.dismiss) var dismiss

    @State private var showingCustomAmountAlert = false
    @State private var customAmountString = ""

    private let sizes: [Double] = [250, 330, 500, 750]

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Text("Log \(drink.name)")
                    .font(.largeTitle).fontWeight(.bold)
                
                drink.icon
                    .font(.system(size: 80)).foregroundColor(drink.color)

                Text("Hydration Factor: \(Int(drink.hydrationFactor * 100))%")
                    .font(.title3).foregroundColor(.secondary).padding(.bottom)
                
                Text("Select Size (ml)").font(.headline)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 20) {
                    ForEach(sizes, id: \.self) { size in
                        Button(action: {
                            logIntake(amount: size, isCustom: false)
                        }) {
                            Text("\(Int(size))")
                                .font(.title2).fontWeight(.semibold)
                                .frame(maxWidth: .infinity, minHeight: 80)
                                .background(drink.color.opacity(0.15))
                                .cornerRadius(15).foregroundColor(.primary)
                        }
                    }
                    
                    Button(action: {
                        customAmountString = ""
                        showingCustomAmountAlert = true
                    }) {
                        Image(systemName: "pencil.and.ruler.fill")
                            .font(.title)
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .background(Color.gray.opacity(0.15))
                            .cornerRadius(15).foregroundColor(.primary)
                    }
                }
                .padding()
                Spacer()
            }
            .padding(.top, 20)
            .navigationBarItems(trailing: Button("Cancel") { dismiss() })
            .navigationBarTitleDisplayMode(.inline)
            .alert("Enter Custom Amount (ml)", isPresented: $showingCustomAmountAlert) {
                TextField("e.g., 600", text: $customAmountString)
                    .keyboardType(.numberPad)
                
                Button("Log") {
                    if let amount = Double(customAmountString) {
                        logIntake(amount: amount, isCustom: true)
                    }
                }
                Button("Cancel", role: .cancel) { }
            }
        }
    }
    
    private func logIntake(amount: Double, isCustom: Bool) {
        healthManager.saveWaterIntake(drink: drink, amountInML: amount, isCustom: isCustom)
        dismiss()
    }
}
