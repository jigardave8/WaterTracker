//
//  HealthKitManager.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
// HealthKitManager.swift
// Targets: WaterTracker, WaterTrackerWatch

import Foundation
import HealthKit
import WidgetKit // Import for widget updates

class HealthKitManager: ObservableObject {
    
    // --- METADATA KEYS (NEW) ---
    // Define unique keys for our custom metadata.
    struct MetadataKeys {
        static let drinkName = "bitdegree.WaterTracker.drinkName"
              static let originalVolume = "bitdegree.WaterTracker.originalVolume"
    }
    
    let healthStore = HKHealthStore()
    
    @Published var totalWaterToday: Double = 0
    @Published var history: [HKQuantitySample] = []
    @Published var weeklyIntakeData: [DailyIntake] = []
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else { return }
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        healthStore.requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
            if success {
                self.fetchAllTodayData()
            }
        }
    }
    
    // --- MODIFIED ---
    // This now fetches all data and then updates the shared container for the widget.
    func fetchAllTodayData() {
        fetchTodayWaterIntake { [weak self] in
            guard let self = self else { return }
            
            // After fetching the total, update the shared data
            let currentGoal = UserDefaults.standard.double(forKey: "dailyGoal")
            let sharedData = SharedData(totalToday: self.totalWaterToday, dailyGoal: currentGoal)
            SharedDataManager.shared.save(data: sharedData)
            
            // Tell the widget to reload its timeline
            WidgetCenter.shared.reloadAllTimelines()
        }
        fetchDailyHistory()
    }
    
    // --- MODIFIED: The Core Logic Upgrade ---
    // This function now accepts the drink object to save its metadata.
    func saveWaterIntake(drink: Drink, amountInML: Double) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            print("Dietary Water type is unavailable.")
            return
        }
        
        let hydratedAmount = amountInML * drink.hydrationFactor
        
        // --- NEW: Metadata creation ---
        let metadata: [String: Any] = [
            MetadataKeys.drinkName: drink.name,
            MetadataKeys.originalVolume: amountInML
        ]
        
        let waterQuantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: hydratedAmount)
        let waterSample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: Date(), end: Date(), metadata: metadata)
        
        healthStore.save(waterSample) { success, error in
            if success {
                print("Successfully saved \(amountInML)ml of \(drink.name).")
                DispatchQueue.main.async {
                    self.fetchAllTodayData() // Re-fetch all data to update UI and widget
                }
            } else if let error = error {
                print("Error saving water intake: \(error.localizedDescription)")
            }
        }
    }

    // --- MODIFIED: Now has a completion handler ---
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
                self.totalWaterToday = sum.doubleValue(for: .literUnit(with: .milli))
                completion?()
            }
        }
        healthStore.execute(query)
    }

    // Unchanged from before
    func fetchDailyHistory() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: nil, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        let query = HKSampleQuery(sampleType: waterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample] else { return }
            DispatchQueue.main.async { self.history = samples }
        }
        healthStore.execute(query)
    }

    // Unchanged from before
    func deleteSample(_ sample: HKQuantitySample) {
        healthStore.delete(sample) { success, error in
            if success {
                DispatchQueue.main.async { self.fetchAllTodayData() }
            }
        }
    }

    // Unchanged from before
    func fetchWeeklyIntake() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        guard let startDate = calendar.date(byAdding: .day, value: -6, to: today) else { return }
        let predicate = HKQuery.predicateForSamples(withStart: startDate, end: nil, options: .strictStartDate)
        let anchorDate = calendar.startOfDay(for: startDate)
        let interval = DateComponents(day: 1)
        let query = HKStatisticsCollectionQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum, anchorDate: anchorDate, intervalComponents: interval)
        query.initialResultsHandler = { query, result, error in
            guard let result = result else { return }
            var dailyData: [DailyIntake] = []
            result.enumerateStatistics(from: startDate, to: today) { statistics, stop in
                let intakeForDay = statistics.sumQuantity()?.doubleValue(for: .literUnit(with: .milli)) ?? 0
                dailyData.append(DailyIntake(date: statistics.startDate, intake: intakeForDay))
            }
            DispatchQueue.main.async { self.weeklyIntakeData = dailyData }
        }
        healthStore.execute(query)
    }
}
