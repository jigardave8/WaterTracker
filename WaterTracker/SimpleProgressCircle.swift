//
//  SimpleProgressCircle.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//
//  A simple, shared progress circle for the watchOS and Widget targets.
//

import SwiftUI

struct SimpleProgressCircle: View {
    let progress: Double
    let lineWidth: CGFloat
    
    var body: some View {
        ZStack {
            // Background circle
            Circle()
                .stroke(lineWidth: lineWidth)
                .opacity(0.3)
                .foregroundColor(.blue)
            
            // Progress circle
            Circle()
                .trim(from: 0.0, to: min(progress, 1.0))
                .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .rotationEffect(Angle(degrees: 270.0)) // Start from the top
                .animation(.linear, value: progress)
        }
    }
}
