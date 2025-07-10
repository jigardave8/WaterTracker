//
//  Award.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  Award.swift
//  WaterTracker
//

import Foundation
import SwiftUI

struct Award: Identifiable {
    let id: AwardID // Use the safe enum for the ID
    let name: String
    let description: String
    let imageName: String
    var isEarned: Bool = false // Default to not earned
}
