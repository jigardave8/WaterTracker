//
//  ProgressCircleView.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

// ProgressCircleView.swift
// Make sure this file is a member of both the iOS and watchOS targets.

import SwiftUI

struct ProgressCircleView: View {
    let progress: Double
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: 20)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: 20, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0)) // Start from the top
                .animation(.linear, value: progress)
        }
    }
}

struct ProgressCircleView_Previews: PreviewProvider {
    static var previews: some View {
        ProgressCircleView(progress: 0.65)
            .padding(40)
    }
}
