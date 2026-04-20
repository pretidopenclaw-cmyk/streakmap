import WidgetKit
import SwiftUI

struct HabitFocusWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: HabitHeatmapWidgetSnapshot
}

struct HabitFocusWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> HabitFocusWidgetEntry {
        HabitFocusWidgetEntry(date: .now, snapshot: previewSnapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (HabitFocusWidgetEntry) -> Void) {
        let snapshot = WidgetStorage.loadHabitSnapshot() ?? previewSnapshot
        completion(HabitFocusWidgetEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<HabitFocusWidgetEntry>) -> Void) {
        let snapshot = WidgetStorage.loadHabitSnapshot() ?? previewSnapshot
        let entry = HabitFocusWidgetEntry(date: .now, snapshot: snapshot)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private var previewSnapshot: HabitHeatmapWidgetSnapshot {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -83, to: today) ?? today
        let days = (0..<84).compactMap { offset -> HabitHeatmapWidgetDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return HabitHeatmapWidgetDay(
                date: date,
                isCompleted: (offset % 3) != 0,
                isToday: calendar.isDateInToday(date)
            )
        }

        return HabitHeatmapWidgetSnapshot(
            habitID: UUID(),
            habitName: "Meditation",
            habitIcon: "brain.head.profile",
            accentHex: "#D16BF5",
            currentStreak: 12,
            days: days
        )
    }
}

struct HabitFocusWidget: Widget {
    let kind: String = "HabitFocusWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: HabitFocusWidgetProvider()) { entry in
            HabitWidgetCardView(snapshot: entry.snapshot)
        }
        .configurationDisplayName("Habit Focus")
        .description("A premium card for one habit.")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

#Preview(as: .systemSmall) {
    HabitFocusWidget()
} timeline: {
    HabitFocusWidgetEntry(
        date: .now,
        snapshot: HabitHeatmapWidgetSnapshot(
            habitID: UUID(),
            habitName: "Meditation",
            habitIcon: "brain.head.profile",
            accentHex: "#D16BF5",
            currentStreak: 12,
            days: []
        )
    )
}
