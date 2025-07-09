//
//  NotificationManager.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

//
//  NotificationManager.swift
//  WaterTracker
//
//  This manager handles the logic for scheduling and canceling all local notifications.
//  It now supports an advanced scheduling model with start/end times and frequency.
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // Request user permission for notifications.
    func requestAuthorization() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if success {
                print("Notification authorization granted.")
            } else if let error = error {
                print(error.localizedDescription)
            }
        }
    }

    // Schedules reminders based on detailed user preferences.
    func scheduleAdvancedReminders(isEnabled: Bool, startTime: Date, endTime: Date, intervalInMinutes: Int) {
        cancelAllNotifications()
        guard isEnabled, intervalInMinutes > 0 else {
            print("Reminders are disabled or interval is zero. All notifications cancelled.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time for Water! 💧"
        content.body = "Stay hydrated to keep your energy levels up. Let's log some water."
        content.sound = .default
        
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        
        guard let startHour = startComponents.hour, let startMinute = startComponents.minute,
              let endHour = endComponents.hour else { return }

        var currentHour = startHour
        var currentMinute = startMinute
        
        // Loop from start time to end time, creating a notification for each interval.
        while currentHour < endHour || (currentHour == endHour && currentMinute <= endComponents.minute ?? 0) {
            var dateComponents = DateComponents()
            dateComponents.hour = currentHour
            dateComponents.minute = currentMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
            // Calculate the time for the next notification.
            guard let currentDate = Calendar.current.date(from: dateComponents),
                  let nextDate = Calendar.current.date(byAdding: .minute, value: intervalInMinutes, to: currentDate) else { break }
            
            let nextComponents = Calendar.current.dateComponents([.hour, .minute], from: nextDate)
            currentHour = nextComponents.hour!
            currentMinute = nextComponents.minute!
        }
        print("Advanced reminders scheduled from \(startHour):\(startMinute) to \(endHour):\(endComponents.minute ?? 0) every \(intervalInMinutes) minutes.")
    }

    // Clears all previously scheduled notifications.
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All pending notifications cancelled.")
    }
}
