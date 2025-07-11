//
//  AwardsView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//
//
//  AwardsView.swift
//  WaterTracker
//
//  This is the corrected version of the AwardsView. The complex grid has been
//  extracted into its own computed property to ensure compiler stability.
//

import SwiftUI

struct AwardsView: View {
    // The ViewModel for our awards. It defines and manages earned status.
    @StateObject private var awardsManager = AwardsManager()
    
    // Define the column layout for the grid.
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 120))]
    
    // The main body is now simple and clean.
    var body: some View {
        NavigationView {
            awardsGrid
                .navigationTitle("Awards")
        }
        .navigationViewStyle(.stack) // Use stack style for better compatibility
    }
    
    // The complex grid is now its own computed property.
    private var awardsGrid: some View {
        // Use a background color that matches the rest of the app
        ZStack {
            Color.appBackground.ignoresSafeArea()
            
            ScrollView {
                // The LazyVGrid displays all awards from the manager.
                LazyVGrid(columns: columns, spacing: 20) {
                    // We now iterate over a sorted array of the award values for a stable order.
                    ForEach(awardsManager.allAwards.values.sorted(by: { $0.name < $1.name })) { award in
                        VStack(spacing: 8) {
                            Image(systemName: award.imageName)
                                .font(.system(size: 44))
                                .foregroundColor(award.isEarned ? .yellow : .gray.opacity(0.5))
                            
                            VStack {
                                Text(award.name)
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .lineLimit(1)
                                    .minimumScaleFactor(0.8)
                                
                                Text(award.description)
                                    .font(.caption2)
                                    .foregroundColor(.secondary)
                                    .lineLimit(2)
                                    .fixedSize(horizontal: false, vertical: true) // Allow text to wrap
                            }
                            .multilineTextAlignment(.center)
                            
                        }
                        .padding(10)
                        .frame(minHeight: 150, alignment: .top) // Align content to the top
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                        .opacity(award.isEarned ? 1.0 : 0.6)
                        .scaleEffect(award.isEarned ? 1.0 : 0.95)
                        // Animate the change when an award is earned.
                        .animation(.spring(), value: award.isEarned)
                    }
                }
                .padding()
            }
        }
    }
}

struct AwardsView_Previews: PreviewProvider {
    static var previews: some View {
        AwardsView()
    }
}
