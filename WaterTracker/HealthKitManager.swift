//
//  HealthKitManager.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

import Foundation
import HealthKit
import WidgetKit

class HealthKitManager: ObservableObject {
    
    struct MetadataKeys {
        static let drinkName = "bitdegree.WaterTracker.drinkName"
        static let originalVolume = "bitdegree.WaterTracker.originalVolume"
        static let wasCustomAmount = "bitdegree.WaterTracker.wasCustomAmount"
    }
    
    let healthStore = HKHealthStore()
    
    @Published var totalWaterToday: Double = 0
    @Published var history: [HKQuantitySample] = []
    @Published var weeklyIntakeData: [DailyIntake] = []
    
    var awardsManager: AwardsManager?

    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device.")
            return
        }
        
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        
        healthStore.requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
            if success {
                // Initial fetch, no completion needed.
                self.fetchAllTodayData(completion: nil)
            } else {
                print("HealthKit Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // --- THIS IS THE FIX FOR THE LOGIC BUG ---
    // The function now uses a DispatchGroup to manage multiple async calls and has a completion handler.
    func fetchAllTodayData(completion: (() -> Void)?) {
        let dispatchGroup = DispatchGroup()

        // 1. Fetch today's total intake
        dispatchGroup.enter()
        fetchTodayWaterIntake {
            dispatchGroup.leave()
        }

        // 2. Fetch today's detailed history
        dispatchGroup.enter()
        fetchDailyHistory {
            dispatchGroup.leave()
        }

        // 3. Fetch weekly data for charts
        dispatchGroup.enter()
        fetchWeeklyIntake {
            dispatchGroup.leave()
        }

        // This block will only run after ALL of the above calls have completed.
        dispatchGroup.notify(queue: .main) {
            // Update the widget with the latest data
            let currentGoal = CloudSettingsManager.shared.getDailyGoal()
            let sharedData = SharedData(totalToday: self.totalWaterToday, dailyGoal: currentGoal)
            SharedDataManager.shared.save(data: sharedData)
            WidgetCenter.shared.reloadAllTimelines()
            
            // Call the completion handler if it exists. This is where we will check for awards.
            completion?()
        }
    }
    
    func saveWaterIntake(drink: Drink, amountInML: Double, isCustom: Bool = false) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            print("Dietary Water type is unavailable.")
            return
        }
        
        let hydratedAmount = amountInML * drink.hydrationFactor
        
        var metadata: [String: Any] = [
            MetadataKeys.drinkName: drink.name,
            MetadataKeys.originalVolume: amountInML
        ]
        
        if isCustom {
            metadata[MetadataKeys.wasCustomAmount] = true
        }
        
        let waterQuantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: hydratedAmount)
        let waterSample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: Date(), end: Date(), metadata: metadata)
        
        healthStore.save(waterSample) { success, error in
            if success {
                print("Successfully saved \(amountInML)ml of \(drink.name).")
                HapticManager.shared.simpleSuccess()
                DispatchQueue.main.async {
                    // --- THE FIX ---
                    // Now, we check for awards INSIDE the completion handler of our robust fetch function.
                    // This guarantees the awards manager has the latest data.
                    self.fetchAllTodayData {
                        self.awardsManager?.checkAllAwards(healthManager: self)
                    }
                }
            } else if let error = error {
                print("Error saving water intake: \(error.localizedDescription)")
            }
        }
    }

    func fetchTodayWaterIntake(completion: (() -> Void)?) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            completion?(); return
        }
        let predicate = HKQuery.predicateForSamples(withStart: Date().startOfDay, end: nil, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            defer { completion?() } // Ensure completion is always called
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async { self.totalWaterToday = 0 }
                return
            }
            DispatchQueue.main.async {
                let currentUnit = CloudSettingsManager.shared.getVolumeUnit().healthKitUnit
                self.totalWaterToday = sum.doubleValue(for: currentUnit)
            }
        }
        healthStore.execute(query)
    }

    func fetchDailyHistory(completion: (() -> Void)?) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            completion?(); return
        }
        let predicate = HKQuery.predicateForSamples(withStart: Date().startOfDay, end: nil, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: waterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            defer { completion?() } // Ensure completion is always called
            guard let samples = samples as? [HKQuantitySample] else {
                if let error = error { print("Error fetching daily history: \(error.localizedDescription)") }
                return
            }
            DispatchQueue.main.async { self.history = samples }
        }
        healthStore.execute(query)
    }

    func deleteSample(_ sample: HKQuantitySample) {
        healthStore.delete(sample) { success, error in
            if success {
                DispatchQueue.main.async {
                    // Call the robust fetch function after a deletion
                    self.fetchAllTodayData(completion: nil)
                }
            } else if let error = error {
                print("Error deleting sample: \(error.localizedDescription)")
            }
        }
    }

    func fetchWeeklyIntake(completion: (() -> Void)?) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            completion?(); return
        }
        let calendar = Calendar.current
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: Date().startOfDay) else {
            completion?(); return
        }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        
        let query = HKStatisticsCollectionQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: startDate, intervalComponents: DateComponents(day: 1))
        query.initialResultsHandler = { _, result, error in
            defer { completion?() } // Ensure completion is always called
            guard let result = result else { return }
            var dailyData: [DailyIntake] = []
            let currentUnit = CloudSettingsManager.shared.getVolumeUnit().healthKitUnit
            result.enumerateStatistics(from: startDate, to: Date()) { statistics, stop in
                let intakeForDay = statistics.sumQuantity()?.doubleValue(for: currentUnit) ?? 0
                dailyData.append(DailyIntake(date: statistics.startDate, intake: intakeForDay))
            }
            DispatchQueue.main.async { self.weeklyIntakeData = dailyData }
        }
        healthStore.execute(query)
    }
}
