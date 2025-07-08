//
//  HealthKitManager.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//

// HealthKitManager.swift (Modified)
// Make sure this file is a member of both the iOS and watchOS targets.

import Foundation
import HealthKit

class HealthKitManager: ObservableObject {
    
    let healthStore = HKHealthStore()
    
    @Published var totalWaterToday: Double = 0
    @Published var history: [HKQuantitySample] = [] // <-- NEW
    
    init() {
        guard HKHealthStore.isHealthDataAvailable() else {
            print("HealthKit not available on this device.")
            return
        }
        
        let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater)!
        
        healthStore.requestAuthorization(toShare: [waterType], read: [waterType]) { success, error in
            if success {
                self.fetchAllTodayData() // <-- MODIFIED: Use a single fetch function
            } else {
                print("HealthKit Authorization failed: \(error?.localizedDescription ?? "Unknown error")")
            }
        }
    }
    
    // NEW: A wrapper function to fetch all data at once
    func fetchAllTodayData() {
        fetchTodayWaterIntake()
        fetchDailyHistory()
    }
    
    func saveWaterIntake(amount: Double, date: Date = Date()) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            print("Dietary Water type is unavailable.")
            return
        }
        
        let waterQuantity = HKQuantity(unit: .literUnit(with: .milli), doubleValue: amount)
        let waterSample = HKQuantitySample(type: waterType, quantity: waterQuantity, start: date, end: date)
        
        healthStore.save(waterSample) { success, error in
            if success {
                print("Successfully saved \(amount)ml of water.")
                // Re-fetch all data to update UI
                DispatchQueue.main.async {
                    self.fetchAllTodayData()
                }
            } else if let error = error {
                print("Error saving water intake: \(error.localizedDescription)")
            }
        }
    }
    
    // NEW: Function to fetch individual entries for the history view
    func fetchDailyHistory() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: nil, options: .strictStartDate)
        let sortDescriptor = NSSortDescriptor(key: HKSampleSortIdentifierStartDate, ascending: false)
        
        let query = HKSampleQuery(sampleType: waterType, predicate: predicate, limit: HKObjectQueryNoLimit, sortDescriptors: [sortDescriptor]) { _, samples, error in
            guard let samples = samples as? [HKQuantitySample] else {
                if let error = error {
                    print("Error fetching daily history: \(error.localizedDescription)")
                }
                return
            }
            
            DispatchQueue.main.async {
                self.history = samples
            }
        }
        
        healthStore.execute(query)
    }

    // NEW: Function to delete an entry
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

    // Unchanged from before
    func fetchTodayWaterIntake() {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else { return }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: nil, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                DispatchQueue.main.async { self.totalWaterToday = 0 } // Handle case with no data
                return
            }
            DispatchQueue.main.async {
                self.totalWaterToday = sum.doubleValue(for: .literUnit(with: .milli))
            }
        }
        healthStore.execute(query)
    }
    
    // In HealthKitManager.swift

    // NEW: Function for background tasks like complications
    func fetchCurrentWaterTotal(completion: @escaping (Double) -> Void) {
        guard let waterType = HKQuantityType.quantityType(forIdentifier: .dietaryWater) else {
            completion(0)
            return
        }
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: Date())
        let predicate = HKQuery.predicateForSamples(withStart: today, end: nil, options: .strictStartDate)
        let query = HKStatisticsQuery(quantityType: waterType, quantitySamplePredicate: predicate, options: .cumulativeSum) { _, result, error in
            guard let result = result, let sum = result.sumQuantity() else {
                completion(0)
                return
            }
            let total = sum.doubleValue(for: .literUnit(with: .milli))
            completion(total)
        }
        healthStore.execute(query)
    }
    
    
}
