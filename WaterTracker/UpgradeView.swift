//
//  UpgradeView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  UpgradeView.swift
//  WaterTracker
//
//  This view is shown to non-pro users when they try to access a pro feature.
//

import SwiftUI

struct UpgradeView: View {
    @EnvironmentObject var storeManager: StoreManager
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "sparkles")
                .font(.system(size: 80))
                .foregroundColor(.yellow)
            
            Text("Unlock WaterTracker Pro")
                .font(.largeTitle).fontWeight(.bold)
            
            VStack(alignment: .leading, spacing: 15) {
                FeatureRow(icon: "star.fill", text: "Earn achievements and stay motivated")
                FeatureRow(icon: "chart.pie.fill", text: "Get detailed insights and statistics")
                FeatureRow(icon: "ipad.and.iphone", text: "Sync and use on your iPad")
            }
            
            Spacer()
            
            if let proProduct = storeManager.products.first {
                Button(action: {
                    Task {
                        try? await storeManager.purchase(proProduct)
                    }
                }) {
                    Text("Upgrade Now for \(proProduct.displayPrice)")
                        .font(.headline)
                        .fontWeight(.bold)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
            } else {
                Text("Loading...")
                    .font(.headline)
            }
        }
        .padding(30)
    }
}

struct FeatureRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .font(.headline)
                .foregroundColor(.blue)
                .frame(width: 30)
            Text(text)
                .font(.body)
        }
    }
}
