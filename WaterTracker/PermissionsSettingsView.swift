//
//  PermissionsSettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

//
//  PermissionsSettingsView.swift
//  WaterTracker
//

import SwiftUI

struct PermissionsSettingsView: View {
    var body: some View {
        Section(header: Text("Permissions")) {
            Button("Manage Health Access") {
                // IMPORTANT: Ensure your bundle ID here is correct.
                if let url = URL(string: "x-apple-health://sources/bitdegree.WaterTracker") {
                    UIApplication.shared.open(url)
                }
            }.foregroundColor(.primary)
        }
    }
}
