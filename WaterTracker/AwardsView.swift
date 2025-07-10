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

import SwiftUI

struct AwardsView: View {
    // Use the new manager as the source of truth.
    @StateObject private var awardsManager = AwardsManager()
    let columns = [GridItem(.adaptive(minimum: 100, maximum: 120))]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(awardsManager.awards) { award in
                        VStack {
                            Image(systemName: award.imageName)
                                .font(.system(size: 44))
                                .foregroundColor(award.isEarned ? .yellow : .gray.opacity(0.5))
                            
                            Text(award.name)
                                .font(.caption).fontWeight(.bold).multilineTextAlignment(.center)
                            
                            Text(award.description)
                                .font(.caption2).foregroundColor(.secondary).multilineTextAlignment(.center)
                        }
                        .padding()
                        .frame(minHeight: 150)
                        .background(Color(.secondarySystemGroupedBackground))
                        .cornerRadius(12)
                        .opacity(award.isEarned ? 1.0 : 0.6)
                        .scaleEffect(award.isEarned ? 1.0 : 0.95)
                        .animation(.spring(), value: award.isEarned)
                    }
                }
                .padding()
            }
            .navigationTitle("Awards")
        }
    }
}
