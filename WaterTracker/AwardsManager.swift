//
//  AwardsManager.swift
//  WaterTracker
//
//  Created by BitDegree on 10/07/25.
//

//
//  AwardsManager.swift
//  WaterTracker
//
//  This manager will handle the logic for defining and checking awards.
//

import Foundation

// Using an enum for award IDs is much safer than strings.
enum AwardID: String {
    case firstSip
    case goalSetter
    case perfectDay
    case perfectWeek
    case thirtyDayStreak
    case morningHydrator
    case nightOwl
    case coffeeConnoisseur
}

class AwardsManager: ObservableObject {
    @Published var awards: [Award] = []
    
    init() {
        self.awards = defineAwards()
        // In the future, this is where we would check which awards are earned.
        checkEarnedAwards()
    }
    
    private func defineAwards() -> [Award] {
        return [
            Award(id: .firstSip, name: "First Sip", description: "Log your first drink.", imageName: "drop.circle.fill"),
            Award(id: .goalSetter, name: "Goal Setter", description: "Set a personal daily goal.", imageName: "flag.checkered.2.crossed"),
            Award(id: .perfectDay, name: "Perfect Day", description: "Meet your daily goal for the first time.", imageName: "star.fill"),
            Award(id: .perfectWeek, name: "Perfect Week", description: "Meet your goal 7 days in a row.", imageName: "7.square.fill"),
            Award(id: .thirtyDayStreak, name: "30-Day Streak", description: "Meet your goal 30 days in a row.", imageName: "flame.fill"),
            Award(id: .morningHydrator, name: "Morning Hydrator", description: "Log water before 9 AM.", imageName: "sunrise.fill"),
            Award(id: .nightOwl, name: "Night Owl", description: "Log water after 9 PM.", imageName: "moon.stars.fill"),
            Award(id: .coffeeConnoisseur, name: "Coffee Connoisseur", description: "Log 10 coffees.", imageName: "cup.and.saucer.fill")
        ]
    }
    
    func checkEarnedAwards() {
        // This is where the logic will go. For now, we'll just mock some as earned.
        let earnedIDs = getEarnedAwardIDs()
        
        for i in awards.indices {
            if earnedIDs.contains(awards[i].id) {
                awards[i].isEarned = true
            }
        }
    }
    
    // We will use UserDefaults to track earned awards.
    private func getEarnedAwardIDs() -> Set<AwardID> {
        // For testing, let's pretend some are already earned.
        return [.firstSip, .perfectDay, .thirtyDayStreak]
    }
    
    // This is the function we'll call when we want to grant an award.
    func grantAward(id: AwardID) {
        // In a real app, you would save this to UserDefaults or a database.
        if let index = awards.firstIndex(where: { $0.id == id }) {
            awards[index].isEarned = true
        }
    }
}
