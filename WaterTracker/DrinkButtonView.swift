//
//  DrinkButtonView.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

//
//  DrinkButtonView.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//
//  A reusable button view for each drink type on the Home screen.
//

import SwiftUI

struct DrinkButtonView: View {
    let drink: Drink
    
    var body: some View {
        VStack(spacing: 8) {
            // The drink's icon, styled within a circle
            drink.icon
                .font(.title2)
                .foregroundColor(drink.color)
                .frame(width: 60, height: 60)
                .background(drink.color.opacity(0.15))
                .clipShape(Circle())
            
            // The drink's name
            Text(drink.name)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.primary)
        }
        .padding(.horizontal, 8)
    }
}

struct DrinkButtonView_Previews: PreviewProvider {
    static var previews: some View {
        DrinkButtonView(drink: Drink.allDrinks.first!)
            .padding()
    }
}
