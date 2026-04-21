import WidgetKit
import SwiftUI

struct HabitFocusWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: HabitHeatmapWidgetSnapshot
}

struct HabitFocusWidgetProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> HabitFocusWidgetEntry {
        HabitFocusWidgetEntry(date: .now, snapshot: previewSnapshot)
    }

    func snapshot(for configuration: HabitSelectionIntent, in context: Context) async -> HabitFocusWidgetEntry {
        let snapshot = resolveSnapshot(for: configuration)
        return HabitFocusWidgetEntry(date: .now, snapshot: snapshot)
    }

    func timeline(for configuration: HabitSelectionIntent, in context: Context) async -> Timeline<HabitFocusWidgetEntry> {
        let snapshot = resolveSnapshot(for: configuration)
        let entry = HabitFocusWidgetEntry(date: .now, snapshot: snapshot)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        return Timeline(entries: [entry], policy: .after(next))
    }

    private func resolveSnapshot(for configuration: HabitSelectionIntent) -> HabitHeatmapWidgetSnapshot {
        let allSnapshots = WidgetStorage.loadAllHabitSnapshots()
        if let selectedHabit = configuration.habit,
           let match = allSnapshots.first(where: { $0.habitID == selectedHabit.id }) {
            return match
        }
        // Fallback: first available snapshot, then legacy single snapshot, then preview
        return allSnapshots.first
            ?? WidgetStorage.loadHabitSnapshot()
            ?? previewSnapshot
    }

    private var previewSnapshot: HabitHeatmapWidgetSnapshot {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -364, to: today) ?? today
        let days = (0..<365).compactMap { offset -> HabitHeatmapWidgetDay? in
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
        AppIntentConfiguration(kind: kind, intent: HabitSelectionIntent.self, provider: HabitFocusWidgetProvider()) { entry in
            HabitWidgetCardView(snapshot: entry.snapshot)
                .widgetURL(URL(string: "streakmap://habit/\(entry.snapshot.habitID.uuidString)"))
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
