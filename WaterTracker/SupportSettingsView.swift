//
//  SupportSettingsView.swift
//  WaterTracker
//
//  Created by BitDegree on 11/07/25.
//

//
//  SupportSettingsView.swift
//  WaterTracker
//
//  This dedicated view encapsulates the logic for the Support section.
//

import SwiftUI
import MessageUI

struct SupportSettingsView: View {
    // We use @Binding here to communicate with the parent view's state.
    @Binding var showMailView: Bool
    
    var body: some View {
        Section(header: Text("Support & Feedback")) {
            Button("Rate on the App Store") {
                // IMPORTANT: Replace 123456789 with your real App Store ID.
                if let url = URL(string: "itms-apps://itunes.apple.com/app/id123456789?action=write-review") {
                    UIApplication.shared.open(url)
                }
            }
            
            Button("Contact Support") {
                if MFMailComposeViewController.canSendMail() {
                    self.showMailView = true
                } else {
                    // This is a good place for an alert in a real app.
                    print("Cannot send mail")
                }
            }
            
            Link("Privacy Policy", destination: URL(string: "https://www.apple.com")!)
        }
        .foregroundColor(.primary)
    }
}
