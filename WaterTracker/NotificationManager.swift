//
//  NotificationManager.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
//
//
//  NotificationManager.swift
//  WaterTracker
//

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    // --- NEW: A dedicated, simple function for debug notifications ---
    func scheduleDebugReminders() {
        cancelAllNotifications()
        print("Scheduling DEBUG notifications for every 5 seconds.")
        
        let content = UNMutableNotificationContent()
        content.title = "💧 DEBUG: 5 Second Reminder"
        content.body = "This is a test notification."
        content.sound = .default
        
        // This trigger repeats every 5 seconds.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: true)
        let request = UNNotificationRequest(identifier: "debug-reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(request)
    }

    // This is the original function for real, calendar-based reminders.
    func scheduleAdvancedReminders(isPro: Bool, isEnabled: Bool, startTime: Date, endTime: Date, intervalInMinutes: Int, soundName: String) {
        cancelAllNotifications()
        guard isEnabled, intervalInMinutes > 0 else { return }
        
        // --- THIS IS THE FIX ---
        // If we are in DEBUG mode and the interval is 5, use the debug scheduler.
        #if DEBUG
        if intervalInMinutes == 5 {
            scheduleDebugReminders()
            return // Stop here
        }
        #endif

        let content = UNMutableNotificationContent()
        content.title = "Time for Water! 💧"
        content.body = MotivationManager.shared.getMotivationalMessage(isPro: isPro)
        
        if isPro && soundName != "default" {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
        } else {
            content.sound = .default
        }
        
        // The rest of the calendar-based scheduling logic remains the same...
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        
        guard let startHour = startComponents.hour, let startMinute = startComponents.minute,
              let endHour = endComponents.hour else { return }

        var currentHour = startHour; var currentMinute = startMinute
        
        while currentHour < endHour || (currentHour == endHour && currentMinute <= endComponents.minute ?? 0) {
            var dateComponents = DateComponents(); dateComponents.hour = currentHour; dateComponents.minute = currentMinute
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
            guard let currentDate = Calendar.current.date(from: dateComponents),
                  let nextDate = Calendar.current.date(byAdding: .minute, value: intervalInMinutes, to: currentDate) else { break }
            let nextComponents = Calendar.current.dateComponents([.hour, .minute], from: nextDate)
            currentHour = nextComponents.hour!; currentMinute = nextComponents.minute!
        }
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("All notifications cancelled.")
    }
}
