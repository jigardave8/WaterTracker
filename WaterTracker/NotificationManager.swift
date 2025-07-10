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

import Foundation
import UserNotifications

class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    // Asks for permission and uses a completion handler to report the result.
    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { success, error in
            if let error = error {
                print("Error requesting notification auth: \(error.localizedDescription)")
            }
            DispatchQueue.main.async {
                completion(success)
            }
        }
    }

    // Schedules notifications with dynamic content and custom sounds for Pro users.
    func scheduleAdvancedReminders(isPro: Bool, isEnabled: Bool, startTime: Date, endTime: Date, intervalInMinutes: Int, soundName: String) {
        cancelAllNotifications()
        guard isEnabled, intervalInMinutes > 0 else {
            print("Reminders are disabled. All notifications cancelled.")
            return
        }

        let content = UNMutableNotificationContent()
        content.title = "Time for Water! 💧"
        content.body = MotivationManager.shared.getMotivationalMessage(isPro: isPro)
        
        // Use a custom sound for Pro users, otherwise the default sound.
        if isPro && soundName != "default" {
            content.sound = UNNotificationSound(named: UNNotificationSoundName(soundName))
        } else {
            content.sound = .default
        }
        
        let startComponents = Calendar.current.dateComponents([.hour, .minute], from: startTime)
        let endComponents = Calendar.current.dateComponents([.hour, .minute], from: endTime)
        
        guard let startHour = startComponents.hour, let startMinute = startComponents.minute,
              let endHour = endComponents.hour else { return }

        var currentHour = startHour
        var currentMinute = startMinute
        
        while currentHour < endHour || (currentHour == endHour && currentMinute <= endComponents.minute ?? 0) {
            var dateComponents = DateComponents()
            dateComponents.hour = currentHour
            dateComponents.minute = currentMinute
            
            let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            UNUserNotificationCenter.current().add(request)
            
            guard let currentDate = Calendar.current.date(from: dateComponents),
                  let nextDate = Calendar.current.date(byAdding: .minute, value: intervalInMinutes, to: currentDate) else { break }
            
            let nextComponents = Calendar.current.dateComponents([.hour, .minute], from: nextDate)
            currentHour = nextComponents.hour!
            currentMinute = nextComponents.minute!
        }
        print("Advanced reminders scheduled.")
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }
}
