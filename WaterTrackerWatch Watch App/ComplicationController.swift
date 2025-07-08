//
//  ComplicationController.swift
//  WaterTracker
//
//  Created by BitDegree on 08/07/25.
//
//
//  ComplicationController.swift
//  WaterTrackerWatch Watch App
//
//  This file is the single source of truth for all watch face complications.
//  It works directly with ClockKit's templates and providers for maximum reliability.
//

import ClockKit
import SwiftUI // Used for system colors

class ComplicationController: NSObject, CLKComplicationDataSource {
    
    let healthManager = HealthKitManager()
    
    // MARK: - Complication Configuration

    func getComplicationDescriptors(handler: @escaping ([CLKComplicationDescriptor]) -> Void) {
        let descriptors = [
            CLKComplicationDescriptor(identifier: "water_progress",
                                      displayName: "Water Progress",
                                      supportedFamilies: [.graphicCircular, .graphicCorner])
        ]
        handler(descriptors)
    }
    
    // MARK: - Timeline Population
    
    func getCurrentTimelineEntry(for complication: CLKComplication, withHandler handler: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        // Fetch the current water total from HealthKit and create an entry.
        createTimelineEntry(for: complication, date: Date()) { entry in
            handler(entry)
        }
    }
    
    // MARK: - Templating
    
    // This is the main helper function that builds the complication.

    // This is the NEW, CORRECT version
    func createTimelineEntry(for complication: CLKComplication, date: Date, completion: @escaping (CLKComplicationTimelineEntry?) -> Void) {
        let goal = UserDefaults.standard.double(forKey: "dailyGoal")

        // --- FIX: Use the new function name and get the value from the manager ---
        healthManager.fetchTodayWaterIntake {
            // The total is now on the healthManager's published property
            let progress = self.healthManager.totalWaterToday
            
            // The rest of the logic is the same
            let template = self.createTemplate(for: complication.family, progress: progress, goal: goal)
            
            if let template = template {
                let entry = CLKComplicationTimelineEntry(date: date, complicationTemplate: template)
                completion(entry)
            } else {
                completion(nil)
            }
        }
    }

    // This function creates the specific template for a given family.
    private func createTemplate(for family: CLKComplicationFamily, progress: Double, goal: Double) -> CLKComplicationTemplate? {
        let effectiveGoal = goal > 0 ? goal : 2500 // Use a default if goal is 0.
        let fraction = Float(progress / effectiveGoal)
        
        switch family {
        case .graphicCircular:
            // This template is a gauge with text in the middle and at the bottom.
            return CLKComplicationTemplateGraphicCircularOpenGaugeSimpleText(
                gaugeProvider: CLKSimpleGaugeProvider(style: .fill, gaugeColor: .cyan, fillFraction: fraction),
                bottomTextProvider: CLKSimpleTextProvider(text: "Water"),
                centerTextProvider: CLKSimpleTextProvider(text: "\(Int(progress))")
            )
            
        case .graphicCorner:
            // --- THE FIX IS HERE ---
            // 1. Create a UIImage and apply the color directly to it.
            let waterDropImage = UIImage(systemName: "drop.fill")!.withTintColor(.cyan, renderingMode: .alwaysOriginal)
            
            // 2. Use the correct CLKFullColorImageProvider class, as required by this template.
            let imageProvider = CLKFullColorImageProvider(fullColorImage: waterDropImage)
            
            // This template combines a gauge with a full-color image provider.
            return CLKComplicationTemplateGraphicCornerGaugeImage(
                gaugeProvider: CLKSimpleGaugeProvider(style: .fill, gaugeColor: .cyan, fillFraction: fraction),
                imageProvider: imageProvider // Now the type is correct.
            )
            
        default:
            return nil
        }
    }
    
    
}
