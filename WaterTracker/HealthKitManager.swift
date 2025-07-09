//
//  HealthKitManager.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
//
//  HealthKitManager.swift
//  WaterTracker
//
//  This file is the central point for all HealthKit interactions. It handles
//  saving, fetching, and deleting water intake data, now with support for
//  custom units and haptic feedback.
//

import Foundation
import HealthKit
import WidgetKit

class HealthKitManager: ObservableObject {
    
    // Define unique keys for our custom metadata.
    struct MetadataKeys {
        static let drinkName = "bitdegree.WaterTracker.drinkName"
        static let originalVolume = "bitdegree.WaterTracker.originalVolume"
    }
    
    let healthStore = HKHealthStore()
    
    @Published var totalWaterToday: Double = 0
    @Published var history: [HKQuantitySample] = []
    @Published var weeklyIntakeData: [DailyIntake] = []
    
    // NEW: A reference to the settings manager to get the current unit preference.
    private var settingsManager = SettingsManager()

    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device.")
            return
        }
        
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        
        healthStore.requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
            if success {
                self.fetchAllTodayData()
            } else {
                print("HealthKit Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // This now fetches all data and then updates the shared container for the widget.
    func fetchAllTodayData() {
        fetchTodayWaterIntake { [weak self] in
            guard let self = self else { return }
            
            // After fetching the total, update the shared data for the widget
            let currentGoal = UserDefaults.standard.double(forKey: "dailyGoal")
            let sharedData = SharedData(totalToday: self.totalWaterToday, dailyGoal: currentGoal)
            SharedDataManager.shared.save(data: sharedData)
            
            // Tell the widget to reload its timeline
            WidgetCenter.shared.reloadAllTimelines()
        }
        fetchDailyHistory()
        fetchWeeklyIntake() // Also fetch weekly data
    }
    
    // This function now accepts the drink object to save its metadata.
    func saveWaterIntake(drink: Drink, amountInML: Double) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            print("Dietary Water type is unavailable.")
            return
        }
        
        let hydratedAmount = amountInML * drink.hydrationFactor
        
        let metadata: [String: Any] = [
            MetadataKeys.drinkName: drink.name,
            MetadataKeys.originalVolume: amountInML
        ]
        
        // HealthKit always saves in a base unit (liters), which avoids conversion issues.
        let waterQuantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: hydratedAmount)
        let waterSample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: Date(), end: Date(), metadata: metadata)
        
        healthStore.save(waterSample) { success, error in
            if success {
                print("Successfully saved \(amountInML)ml of \(drink.name).")
                // Trigger haptic feedback on success.
                HapticManager.shared.simpleSuccess()
                DispatchQueue.main.async {
                    self.fetchAllTodayData() // Re-fetch all data to update UI and widget
                }
            } else if let error = error {
                print("Error saving water intake: \(error.localizedDescription)")
            }
        }
    }

    // Now has a completion handler for chaining operations.
    func fetchTodayWaterIntake(completion: (() -> Void)? = nil) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            completion?()
            return
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: nil, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async {
                    self.totalWaterToday = 0
                    completion?()
                }
                return
            }
            DispatchQueue.main.async {
                // Return the value in the user's preferred unit.
                self.totalWaterToday = sum.doubleValue(for: self.settingsManager.volumeUnit.healthKitUnit)
                completion?()
            }
        }
        healthStore.execute(query)
    }

    // Fetches individual entries for the history view.
    func fetchDailyHistory() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: nil, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: waterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample] else {
                if let error = error { print("Error fetching daily history: \(error.localizedDescription)") }
                return
            }
            
            DispatchQueue.main.async {
                self.history = samples
            }
        }
        healthStore.execute(query)
    }

    // Deletes a specific sample from HealthKit.
    func deleteSample(_ sample: HKQuantitySample) {
        healthStore.delete(sample) { success, error in
            if success {
                print("Successfully deleted sample.")
                DispatchQueue.main.async {
                    self.fetchAllTodayData()
                }
            } else if let error = error {
                print("Error deleting sample: \(error.localizedDescription)")
            }
        }
    }

    // Fetches aggregated data for the last 7 days for the chart.
    func fetchWeeklyIntake() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: today) else { return }

        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let anchorDate = calendar.startOfDay(for: startDate)
        let interval = DateComponents(day: 1)
        
        let query = HKStatisticsCollectionQuery(
            quantityType: waterType,
            quantitySamplePredicate: predicate,
            options: .cumulativeSum,
            anchorDate: anchorDate,
            intervalComponents: interval
        )
        
        query.initialResultsHandler = { query, result, error in
            guard let result = result else { return }
            
            var dailyData: [DailyIntake] = []
            
            result.enumerateStatistics(from: startDate, to: today) { statistics, stop in
                // Return the value for each day in the user's preferred unit.
                let intakeForDay = statistics.sumQuantity()?.doubleValue(for: self.settingsManager.volumeUnit.healthKitUnit) ?? 0
                dailyData.append(DailyIntake(date: statistics.startDate, intake: intakeForDay))
            }
            
            DispatchQueue.main.async {
                self.weeklyIntakeData = dailyData
            }
        }
        healthStore.execute(query)
    }
}
