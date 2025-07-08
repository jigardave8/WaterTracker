//
//  NotificationManager.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

// NotificationManager.swift

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification authorization granted.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    func scheduleWaterReminders() {
        cancelAllNotifications() // Clear old reminders first
        
        let content = UNMutableNotificationContent()
        content.title = "Time for Water! 💧"
        content.body = "Stay hydrated to keep your energy levels up. Let's log some water."
        content.sound = .default

        // Reminder every 2 hours (7200 seconds)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 7200, repeats: true)

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)

        UNUserNotificationCenter.current().add(request)
        print("Reminders scheduled.")
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications cancelled.")
    }
}
