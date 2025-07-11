//
//  AppearanceSettingsView.swift
//  WaterTracker
//
//  This is the definitive, stable version. The Picker logic has been completely
//  rewritten to be simple and guaranteed to compile.
//

import SwiftUI

struct AppearanceSettingsView: View {
    @ObservedObject var viewModel: SettingsViewModel
    @ObservedObject var storeManager: StoreManager
    
    var body: some View {
        Section(header: Text("Appearance")) {
            // We bind the Picker to the ViewModel's selectedAppIcon property.
            Picker("App Icon", selection: $viewModel.selectedAppIcon) {
                // We iterate through all the defined app icon cases.
                ForEach(AppIcon.allCases) { icon in
                    // We call a helper function to build each row.
                    // This keeps the ForEach loop itself extremely simple.
                    iconRow(for: icon)
                        .tag(icon) // The tag MUST be the icon object itself.
                }
            }
        }
    }
    
    // This helper function builds a single row for the Picker.
    // It contains all the logic, keeping the main body clean.
    @ViewBuilder
    private func iconRow(for icon: AppIcon) -> some View {
        let isProIcon = (icon == .pro)
        let isLocked = isProIcon && !storeManager.isProUser
        
        HStack {
            Image(uiImage: UIImage(named: icon.previewName) ?? UIImage())
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(RoundedRectangle(cornerRadius: 6))
            
            Text(icon.rawValue)
            
            if isProIcon {
                Spacer()
                Image(systemName: "star.fill")
                    .foregroundColor(.yellow)
                    .font(.caption)
            }
        }
        // Apply the disabled modifier here, outside the complex view hierarchy.
        .disabled(isLocked)
        // Add an overlay to visually indicate that it's locked.
        .overlay(
            ZStack {
                if isLocked {
                    // A semi-transparent gray overlay
                    Color.black.opacity(0.4)
                        .clipShape(Rectangle()) // Use Rectangle to ensure it fills the row
                    
                    // A lock icon
                    Image(systemName: "lock.fill")
                        .foregroundColor(.white)
                }
            }
        )
    }
}
