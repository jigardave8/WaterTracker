//
//  BodyFillView.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  BodyFillView.swift
//  WaterTracker
//
//  A custom view that displays an animated body graphic which fills with
//  water based on the user's hydration progress.
//

import SwiftUI

struct BodyFillView: View {
    var progress: Double // A value between 0.0 and 1.0

    var body: some View {
        ZStack {
            // The background outline of the body.
            Image("body_outline")
                .resizable()
                .scaledToFit()
                .foregroundColor(.gray.opacity(0.2))

            // The water fill, which is masked by the body shape.
            GeometryReader { geometry in
                let fillHeight = geometry.size.height * CGFloat(progress)
                
                VStack {
                    Spacer() // Pushes the fill to the bottom
                    
                    Rectangle()
                        .fill(Color.accentGradient)
                        .frame(height: fillHeight)
                }
                // Animate the height change smoothly.
                .animation(.easeInOut(duration: 1.0), value: progress)
            }
            .mask(
                Image("body_outline")
                    .resizable()
                    .scaledToFit()
            )
        }
    }
}
