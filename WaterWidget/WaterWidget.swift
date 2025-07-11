//
//  WaterWidget.swift
//  WaterWidget
//
//  Created by BitDegree on 09/07/25.
//

import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), totalToday: 1250, dailyGoal: 2500)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), totalToday: 1250, dailyGoal: 2500)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let sharedData = SharedDataManager.shared.load()
        
        let total = sharedData?.totalToday ?? 0
        let goal = sharedData?.dailyGoal ?? 2500
        
        let entry = SimpleEntry(date: Date(), totalToday: total, dailyGoal: goal)

        let nextUpdateDate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdateDate))
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let totalToday: Double
    let dailyGoal: Double
    
    var progress: Double {
        dailyGoal > 0 ? totalToday / dailyGoal : 0
    }
}

// The SwiftUI view for the widget
struct WaterWidgetEntryView : View {
    var entry: Provider.Entry

    var body: some View {
        VStack {
            // --- THIS IS THE FIX ---
            // Use the new SimpleProgressCircle and specify a line width.
            SimpleProgressCircle(progress: entry.progress, lineWidth: 10)
                .padding(10)
            
            VStack {
                Text("\(Int(entry.totalToday)) ml")
                    .font(.headline)
                    .fontWeight(.bold)
                Text("of \(Int(entry.dailyGoal)) ml")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
        }
        .padding()
    }
}

// The main widget configuration
@main
struct WaterWidget: Widget {
    let kind: String = "WaterWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WaterWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Water Tracker")
        .description("Track your daily water intake progress.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// Preview provider for Xcode Previews
struct WaterWidget_Previews: PreviewProvider {
    static var previews: some View {
        WaterWidgetEntryView(entry: SimpleEntry(date: Date(), totalToday: 1250, dailyGoal: 2500))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
