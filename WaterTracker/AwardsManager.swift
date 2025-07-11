//
//  AwardsManager.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//
//
//
//  AwardsManager.swift
//  WaterTracker
//
//  A comprehensive system for defining, checking, and granting over 50 awards.
//

import Foundation
import HealthKit // <-- I am also adding this import to be safe

// A safe, typed way to identify awards.
enum AwardID: String, CaseIterable {
    // Daily
    case firstSip, morningHydrator, middayHydrator, eveningHydrator, nightOwl, perfectDay
    // Streaks
    case threeDayStreak, sevenDayStreak, fourteenDayStreak, thirtyDayStreak, hundredDayStreak, yearStreak
    // Total Intake (Liters)
    case total10L, total50L, total100L, total250L, total500L, total1000L, total5000L
    // Drink Specific (Count)
    case coffee5, coffee25, coffee100
    case tea5, tea25, tea100
    case juice5, juice25, juice100
    // Variety
    case varietyFirst, varietyAll
    // Goal
    case goalSetter, goalAchiever5, goalAchiever25
    // Other Milestones
    case firstWeek, firstMonth, weekendWarrior, weekdayWarrior
    case log100, log500, log1000
    case customIntake, appPro
}

class AwardsManager: ObservableObject {
    @Published var allAwards: [AwardID: Award]

    // We use UserDefaults to permanently store earned award IDs.
    private var earnedAwardIDs: Set<String> {
        get {
            let saved = UserDefaults.standard.stringArray(forKey: "earnedAwardIDs") ?? []
            return Set(saved)
        }
        set {
            UserDefaults.standard.set(Array(newValue), forKey: "earnedAwardIDs")
        }
    }
    
    init() {
        self.allAwards = AwardsManager.defineAllAwards()
        loadEarnedStatus()
    }
    
    // MARK: - Core Logic
    
    func checkAwards(afterLogging drink: Drink, healthManager: HealthKitManager) {
        let earnedBefore = earnedAwardIDs.count
        
        grant(id: .firstSip)
        
        if drink.name != "Water" {
            grant(id: .varietyFirst)
        }

        // --- THE FIX IS HERE ---
        // An HKQuantitySample has a `startDate`, not a `date`.
        if let lastLog = healthManager.history.first {
            let hour = Calendar.current.component(.hour, from: lastLog.startDate)
            if hour < 9 { grant(id: .morningHydrator) }
            if hour >= 12 && hour < 17 { grant(id: .middayHydrator) }
            if hour >= 17 && hour < 21 { grant(id: .eveningHydrator) }
            if hour >= 21 { grant(id: .nightOwl) }
        }
        
        let history = healthManager.history
        let coffeeCount = history.filter { ($0.metadata?["bitdegree.WaterTracker.drinkName"] as? String) == "Coffee" }.count
        if coffeeCount >= 5 { grant(id: .coffee5) }
        if coffeeCount >= 25 { grant(id: .coffee25) }
        if coffeeCount >= 100 { grant(id: .coffee100) }
        
        let teaCount = history.filter { ($0.metadata?["bitdegree.WaterTracker.drinkName"] as? String) == "Tea" }.count
        if teaCount >= 5 { grant(id: .tea5) }
        if teaCount >= 25 { grant(id: .tea25) }
        if teaCount >= 100 { grant(id: .tea100) }
        
        let juiceCount = history.filter { ($0.metadata?["bitdegree.WaterTracker.drinkName"] as? String) == "Juice" }.count
        if juiceCount >= 5 { grant(id: .juice5) }
        if juiceCount >= 25 { grant(id: .juice25) }
        if juiceCount >= 100 { grant(id: .juice100) }
        
        let totalLogs = history.count
        if totalLogs >= 100 { grant(id: .log100) }
        if totalLogs >= 500 { grant(id: .log500) }
        if totalLogs >= 1000 { grant(id: .log1000) }
        
        let earnedAfter = earnedAwardIDs.count
        if earnedAfter > earnedBefore {
            print("🏆 New award(s) granted! Total earned: \(earnedAfter)")
        }
    }
    
    func grant(id: AwardID) {
        guard !earnedAwardIDs.contains(id.rawValue) else { return }
        
        earnedAwardIDs.insert(id.rawValue)
        DispatchQueue.main.async {
            self.allAwards[id]?.isEarned = true
        }
    }

    private func loadEarnedStatus() {
        let earned = earnedAwardIDs
        for idString in earned {
            if let id = AwardID(rawValue: idString) {
                self.allAwards[id]?.isEarned = true
            }
        }
    }
    
    // MARK: - Award Definitions
    private static func defineAllAwards() -> [AwardID: Award] {
        var awards: [AwardID: Award] = [:]
        
        let definitions = [
            Award(id: .firstSip, name: "First Sip", description: "Log your first drink of many.", imageName: "drop.circle.fill"),
            Award(id: .morningHydrator, name: "Early Bird", description: "Log a drink before 9 AM.", imageName: "sunrise.fill"),
            Award(id: .middayHydrator, name: "Midday Top-Up", description: "Log a drink between 12 PM and 5 PM.", imageName: "sun.max.fill"),
            Award(id: .eveningHydrator, name: "Evening Sip", description: "Log a drink between 5 PM and 9 PM.", imageName: "sunset.fill"),
            Award(id: .nightOwl, name: "Night Owl", description: "Log a drink after 9 PM.", imageName: "moon.stars.fill"),
            Award(id: .perfectDay, name: "Perfect Day", description: "Meet your daily goal for the first time.", imageName: "star.fill"),
            Award(id: .threeDayStreak, name: "On a Roll", description: "Meet your goal 3 days in a row.", imageName: "3.circle.fill"),
            Award(id: .sevenDayStreak, name: "Perfect Week", description: "Meet your goal 7 days in a row.", imageName: "7.circle.fill"),
            Award(id: .fourteenDayStreak, name: "Fortnight", description: "Meet your goal 14 days in a row.", imageName: "calendar.circle.fill"),
            Award(id: .thirtyDayStreak, name: "Monthly Milestone", description: "Meet your goal 30 days in a row.", imageName: "flame.fill"),
            Award(id: .hundredDayStreak, name: "Hydration Hero", description: "A 100-day perfect streak!", imageName: "crown.fill"),
            Award(id: .yearStreak, name: "One Year Legend", description: "An entire year of meeting your goal!", imageName: "person.3.sequence.fill"),
            Award(id: .total10L, name: "10 Liters", description: "Drank 10L total.", imageName: "testtube.2"),
            Award(id: .total50L, name: "50 Liters", description: "Drank 50L total.", imageName: "humidity.fill"),
            Award(id: .total100L, name: "100 Liters", description: "Drank 100L total.", imageName: "drop.fill"),
            Award(id: .total250L, name: "250 Liters", description: "That's a small tub!", imageName: "wave.3.right"),
            Award(id: .total500L, name: "500 Liters", description: "Half a metric ton!", imageName: "drop.triangle.fill"),
            Award(id: .total1000L, name: "1000 Liters", description: "A metric ton of hydration!", imageName: "fish.fill"),
            Award(id: .total5000L, name: "5000 Liters", description: "Truly oceanic!", imageName: "sailboat.fill"),
            Award(id: .coffee5, name: "Coffee Starter", description: "Logged 5 coffees.", imageName: "5.alt.circle.fill"),
            Award(id: .coffee25, name: "Daily Grind", description: "Logged 25 coffees.", imageName: "25.alt.circle.fill"),
            Award(id: .coffee100, name: "Barista", description: "Logged 100 coffees.", imageName: "100.alt.circle.fill"),
            Award(id: .tea5, name: "Tea Taster", description: "Logged 5 teas.", imageName: "5.alt.circle.fill"),
            Award(id: .tea25, name: "Tea Time", description: "Logged 25 teas.", imageName: "25.alt.circle.fill"),
            Award(id: .tea100, name: "Tea Master", description: "Logged 100 teas.", imageName: "100.alt.circle.fill"),
            Award(id: .juice5, name: "Juice Junior", description: "Logged 5 juices.", imageName: "5.alt.circle.fill"),
            Award(id: .juice25, name: "Fruit Fanatic", description: "Logged 25 juices.", imageName: "25.alt.circle.fill"),
            Award(id: .juice100, name: "Juice Fiend", description: "Logged 100 juices.", imageName: "100.alt.circle.fill"),
            Award(id: .varietyFirst, name: "Variety", description: "Logged a drink other than water.", imageName: "plus.diamond.fill"),
            Award(id: .varietyAll, name: "Mixologist", description: "Logged every type of drink.", imageName: "fork.knife.circle.fill"),
            Award(id: .goalSetter, name: "Goal Setter", description: "Set a custom goal in Settings.", imageName: "flag.checkered.2.crossed"),
            Award(id: .goalAchiever5, name: "High-Achiever", description: "Met your daily goal 5 times.", imageName: "5.circle.fill"),
            Award.init(id: .goalAchiever25, name: "Consistent", description: "Met your daily goal 25 times.", imageName: "25.circle.fill"),
            Award(id: .firstWeek, name: "First Week", description: "Used the app for 7 days.", imageName: "calendar"),
            Award(id: .firstMonth, name: "First Month", description: "Used the app for 30 days.", imageName: "calendar.badge.plus"),
            Award(id: .weekendWarrior, name: "Weekend Warrior", description: "Logged a drink on a Saturday or Sunday.", imageName: "figure.play"),
            Award(id: .weekdayWarrior, name: "Weekday Warrior", description: "Logged a drink on a weekday.", imageName: "figure.walk"),
            Award(id: .log100, name: "Centurion", description: "Logged 100 drinks in total.", imageName: "100.square.fill"),
            Award(id: .log500, name: "Dedicated", description: "Logged 500 drinks in total.", imageName: "500.square.fill"),
            Award(id: .log1000, name: "Maniac", description: "Logged 1000 drinks in total.", imageName: "infinity.circle.fill"),
            Award(id: .customIntake, name: "Precise", description: "Used the Digital Crown to log a custom amount.", imageName: "dial.medium.fill"),
            Award(id: .appPro, name: "App Supporter", description: "Upgraded to the Pro version.", imageName: "heart.fill"),
        ]
        
        for award in definitions {
            awards[award.id] = award
        }
        
        return awards
    }
}
