//
// AwardsManager.swift
// WaterTracker
//
// Created by BitDegree on 10/07/25.
//
import Foundation
import HealthKit
// Define keys for UserDefaults persistence
private enum AwardKeys {
static let earnedAwardIDs = "earnedAwardIDs"
static let firstLaunchDate = "firstLaunchDate"
static let goalMetStreak = "goalMetStreak"
static let lastGoalMetDate = "lastGoalMetDate"
static let totalGoalsMet = "totalGoalsMet"
}
class AwardsManager: ObservableObject {
@Published var allAwards: [AwardID: Award]

weak var healthManager: HealthKitManager?

private var earnedAwardIDs: Set<String> {
    get {
        let saved = UserDefaults.standard.stringArray(forKey: AwardKeys.earnedAwardIDs) ?? []
        return Set(saved)
    }
    set {
        UserDefaults.standard.set(Array(newValue), forKey: AwardKeys.earnedAwardIDs)
    }
}

init() {
    self.allAwards = Self.defineAllAwards()
    loadEarnedStatus()
    
    if UserDefaults.standard.object(forKey: AwardKeys.firstLaunchDate) == nil {
        UserDefaults.standard.set(Date(), forKey: AwardKeys.firstLaunchDate)
    }
}

func checkAllAwards(healthManager: HealthKitManager) {
    let history = healthManager.history
    guard let lastLog = history.first else { return }
    
    grant(id: .firstSip)
    checkDailyTimingAwards(for: lastLog)
    checkDrinkSpecificAwards(with: history)
    
    if (lastLog.metadata?[HealthKitManager.MetadataKeys.drinkName] as? String) != "Water" {
        grant(id: .varietyFirst)
    }
    if didLogAllDrinkTypes(with: history) {
        grant(id: .varietyAll)
    }
    
    if history.count >= 1000 { grant(id: .log1000) }
    else if history.count >= 500 { grant(id: .log500) }
    else if history.count >= 100 { grant(id: .log100) }
    
    if lastLog.metadata?[HealthKitManager.MetadataKeys.wasCustomAmount] as? Bool == true {
        grant(id: .customIntake)
    }
    
    checkGoalAndStreakAwards(healthManager: healthManager)
    checkTotalIntakeAwards(healthManager: healthManager)
    checkUsageDurationAwards()
}

func grant(id: AwardID) {
    guard !earnedAwardIDs.contains(id.rawValue) else { return }
    
    earnedAwardIDs.insert(id.rawValue)
    DispatchQueue.main.async {
        self.allAwards[id]?.isEarned = true
        print("🏆 Award Granted: \(self.allAwards[id]?.name ?? id.rawValue)")
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

private func checkDailyTimingAwards(for sample: HKQuantitySample) {
    let calendar = Calendar.current
    let dayOfWeek = calendar.component(.weekday, from: sample.startDate)
    if dayOfWeek == 1 || dayOfWeek == 7 { grant(id: .weekendWarrior) }
    else { grant(id: .weekdayWarrior) }

    let hour = calendar.component(.hour, from: sample.startDate)
    if hour < 9 { grant(id: .morningHydrator) }
    else if hour < 17 { grant(id: .middayHydrator) }
    else if hour < 21 { grant(id: .eveningHydrator) }
    else { grant(id: .nightOwl) }
}

private func checkDrinkSpecificAwards(with history: [HKQuantitySample]) {
    let coffeeCount = history.filter { ($0.metadata?[HealthKitManager.MetadataKeys.drinkName] as? String) == "Coffee" }.count
    if coffeeCount >= 100 { grant(id: .coffee100) } else if coffeeCount >= 25 { grant(id: .coffee25) } else if coffeeCount >= 5 { grant(id: .coffee5) }
    
    let teaCount = history.filter { ($0.metadata?[HealthKitManager.MetadataKeys.drinkName] as? String) == "Tea" }.count
    if teaCount >= 100 { grant(id: .tea100) } else if teaCount >= 25 { grant(id: .tea25) } else if teaCount >= 5 { grant(id: .tea5) }
    
    let juiceCount = history.filter { ($0.metadata?[HealthKitManager.MetadataKeys.drinkName] as? String) == "Juice" }.count
    if juiceCount >= 100 { grant(id: .juice100) } else if juiceCount >= 25 { grant(id: .juice25) } else if juiceCount >= 5 { grant(id: .juice5) }
}

private func didLogAllDrinkTypes(with history: [HKQuantitySample]) -> Bool {
    let allDrinkNames = Set(Drink.allDrinks.map { $0.name })
    let loggedDrinkNames = Set(history.compactMap { $0.metadata?[HealthKitManager.MetadataKeys.drinkName] as? String })
    return allDrinkNames.isSubset(of: loggedDrinkNames)
}

private func checkGoalAndStreakAwards(healthManager: HealthKitManager) {
    let totalToday = healthManager.totalWaterToday
    let dailyGoal = CloudSettingsManager.shared.getDailyGoal()
    
    guard totalToday >= dailyGoal, dailyGoal > 0 else { return }
    
    grant(id: .perfectDay)
    
    let defaults = UserDefaults.standard
    var totalGoalsMet = defaults.integer(forKey: AwardKeys.totalGoalsMet)
    var streak = defaults.integer(forKey: AwardKeys.goalMetStreak)
    
    if let lastMetDate = defaults.object(forKey: AwardKeys.lastGoalMetDate) as? Date,
       Calendar.current.isDateInToday(lastMetDate) {
        return
    }
    
    if let lastMetDate = defaults.object(forKey: AwardKeys.lastGoalMetDate) as? Date,
       Calendar.current.isDateInYesterday(lastMetDate) {
        streak += 1
    } else {
        streak = 1
    }
    
    totalGoalsMet += 1
    defaults.set(totalGoalsMet, forKey: AwardKeys.totalGoalsMet)
    defaults.set(streak, forKey: AwardKeys.goalMetStreak)
    defaults.set(Date(), forKey: AwardKeys.lastGoalMetDate)
    
    if totalGoalsMet >= 25 { grant(id: .goalAchiever25) }
    else if totalGoalsMet >= 5 { grant(id: .goalAchiever5) }

    if streak >= 365 { grant(id: .yearStreak) }
    else if streak >= 100 { grant(id: .hundredDayStreak) }
    else if streak >= 30 { grant(id: .thirtyDayStreak) }
    else if streak >= 14 { grant(id: .fourteenDayStreak) }
    else if streak >= 7 { grant(id: .sevenDayStreak) }
    else if streak >= 3 { grant(id: .threeDayStreak) }
}

private func checkTotalIntakeAwards(healthManager: HealthKitManager) {
    guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
    let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: nil, options: .cumulativeSum) { _, result, error in
        guard let result = result, let sum = result.sumQuantity() else { return }
        let totalLiters = sum.doubleValue(for: .liter())
        
        DispatchQueue.main.async {
            if totalLiters >= 5000 { self.grant(id: .total5000L) }
            else if totalLiters >= 1000 { self.grant(id: .total1000L) }
            else if totalLiters >= 500 { self.grant(id: .total500L) }
            else if totalLiters >= 250 { self.grant(id: .total250L) }
            else if totalLiters >= 100 { self.grant(id: .total100L) }
            else if totalLiters >= 50 { self.grant(id: .total50L) }
            else if totalLiters >= 10 { self.grant(id: .total10L) }
        }
    }
    healthManager.healthStore.execute(query)
}

private func checkUsageDurationAwards() {
    guard let firstLaunchDate = UserDefaults.standard.object(forKey: AwardKeys.firstLaunchDate) as? Date else { return }
    
    if let days = Calendar.current.dateComponents([.day], from: firstLaunchDate, to: Date()).day {
        if days >= 30 { grant(id: .firstMonth) }
        else if days >= 7 { grant(id: .firstWeek) }
    }
}

// --- THIS SECTION IS NOW FIXED ---
private static func defineAllAwards() -> [AwardID: Award] {
    var awards: [AwardID: Award] = [:]
    let definitions = [
        Award(id: .firstSip, name: "First Sip", description: "Log your first drink.", imageName: "drop.circle.fill"),
        Award(id: .morningHydrator, name: "Early Bird", description: "Log a drink before 9 AM.", imageName: "sunrise.fill"),
        Award(id: .middayHydrator, name: "Midday Top-Up", description: "Log a drink 12 PM-5 PM.", imageName: "sun.max.fill"),
        Award(id: .eveningHydrator, name: "Evening Sip", description: "Log a drink 5 PM-9 PM.", imageName: "sunset.fill"),
        Award(id: .nightOwl, name: "Night Owl", description: "Log a drink after 9 PM.", imageName: "moon.stars.fill"),
        Award(id: .perfectDay, name: "Perfect Day", description: "Meet your daily goal.", imageName: "star.fill"),
        Award(id: .threeDayStreak, name: "On a Roll", description: "3-day goal streak.", imageName: "3.circle.fill"),
        Award(id: .sevenDayStreak, name: "Perfect Week", description: "7-day goal streak.", imageName: "7.circle.fill"),
        Award(id: .fourteenDayStreak, name: "Fortnight", description: "14-day goal streak.", imageName: "calendar.circle.fill"),
        Award(id: .thirtyDayStreak, name: "Monthly Milestone", description: "30-day goal streak.", imageName: "flame.fill"),
        Award(id: .hundredDayStreak, name: "Hydration Hero", description: "100-day goal streak!", imageName: "crown.fill"),
        Award(id: .yearStreak, name: "One Year Legend", description: "365-day goal streak!", imageName: "person.3.sequence.fill"),
        Award(id: .total10L, name: "10 Liters", description: "Drank 10L total.", imageName: "testtube.2"),
        Award(id: .total50L, name: "50 Liters", description: "Drank 50L total.", imageName: "humidity.fill"),
        Award(id: .total100L, name: "100 Liters", description: "Drank 100L total.", imageName: "drop.fill"),
        Award(id: .total250L, name: "250 Liters", description: "A small tub's worth!", imageName: "wave.3.right.circle.fill"), // FIXED
        Award(id: .total500L, name: "500 Liters", description: "Half a metric ton!", imageName: "drop.triangle.fill"),
        Award(id: .total1000L, name: "1000 Liters", description: "A metric ton of hydration!", imageName: "fish.fill"),
        Award(id: .total5000L, name: "5000 Liters", description: "Truly oceanic!", imageName: "sailboat.fill"),
        Award(id: .coffee5, name: "Coffee Starter", description: "Logged 5 coffees.", imageName: "5.circle.fill"), // FIXED
        Award(id: .coffee25, name: "Daily Grind", description: "Logged 25 coffees.", imageName: "25.circle.fill"), // FIXED
        Award(id: .coffee100, name: "Barista", description: "Logged 100 coffees.", imageName: "cup.and.saucer.fill"), // FIXED
        Award(id: .tea5, name: "Tea Taster", description: "Logged 5 teas.", imageName: "5.circle.fill"), // FIXED
        Award(id: .tea25, name: "Tea Time", description: "Logged 25 teas.", imageName: "25.circle.fill"), // FIXED
        Award(id: .tea100, name: "Tea Master", description: "Logged 100 teas.", imageName: "mug.fill"), // FIXED
        Award(id: .juice5, name: "Juice Junior", description: "Logged 5 juices.", imageName: "5.circle.fill"), // FIXED
        Award(id: .juice25, name: "Fruit Fanatic", description: "Logged 25 juices.", imageName: "25.circle.fill"), // FIXED
        Award(id: .juice100, name: "Juice Fiend", description: "Logged 100 juices.", imageName: "leaf.fill"), // FIXED
        Award(id: .varietyFirst, name: "Variety", description: "Logged a drink other than water.", imageName: "plus.diamond.fill"),
        Award(id: .varietyAll, name: "Mixologist", description: "Logged every drink type.", imageName: "fork.knife.circle.fill"),
        Award(id: .goalSetter, name: "Goal Setter", description: "Set a custom daily goal.", imageName: "flag.checkered.2.crossed"),
        Award(id: .goalAchiever5, name: "High-Achiever", description: "Met your goal 5 times.", imageName: "5.circle.fill"),
        Award(id: .goalAchiever25, name: "Consistent", description: "Met your goal 25 times.", imageName: "25.circle.fill"),
        Award(id: .firstWeek, name: "First Week", description: "Used the app for 7 days.", imageName: "calendar"),
        Award(id: .firstMonth, name: "First Month", description: "Used the app for 30 days.", imageName: "calendar.badge.plus"),
        Award(id: .weekendWarrior, name: "Weekend Warrior", description: "Logged on a weekend.", imageName: "figure.play"),
        Award(id: .weekdayWarrior, name: "Weekday Warrior", description: "Logged on a weekday.", imageName: "figure.walk"),
        Award(id: .log100, name: "Centurion", description: "Logged 100 drinks.", imageName: "100.square.fill"), // This one is valid
        Award(id: .log500, name: "Dedicated", description: "Logged 500 drinks.", imageName: "sparkles.circle.fill"), // FIXED
        Award(id: .log1000, name: "Maniac", description: "Logged 1000 drinks.", imageName: "infinity.circle.fill"),
        Award(id: .customIntake, name: "Precise", description: "Logged a custom amount.", imageName: "dial.medium.fill"),
        Award(id: .appPro, name: "App Supporter", description: "Upgraded to Pro!", imageName: "heart.fill"),
    ]
    
    for award in definitions {
        awards[award.id] = award
    }
    
    return awards
}
}
