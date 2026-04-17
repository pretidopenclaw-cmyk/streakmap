import Foundation

enum WidgetDataBuilder {
    static func buildGlobalSnapshot(from appState: AppState) -> GlobalHeatmapWidgetSnapshot {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -364, to: today) ?? today
        let days = (0..<365).compactMap { offset -> GlobalHeatmapWidgetDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return GlobalHeatmapWidgetDay(
                date: date,
                completionRate: appState.completionRate(for: date),
                isToday: calendar.isDateInToday(date)
            )
        }

        let completedToday = appState.activeHabits.filter { appState.isHabitCompleted($0.id, on: today) }.count

        return GlobalHeatmapWidgetSnapshot(
            title: "Last 365 days",
            subtitle: "Your yearly consistency at a glance",
            days: days,
            accentHex: appState.globalHeatmapColorHex,
            completedToday: completedToday,
            totalHabits: appState.activeHabits.count
        )
    }
}
