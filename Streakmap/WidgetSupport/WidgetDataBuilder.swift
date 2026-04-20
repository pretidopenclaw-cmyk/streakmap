import Foundation

@MainActor
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

    static func buildHabitSnapshot(from appState: AppState) -> HabitHeatmapWidgetSnapshot? {
        guard let habit = appState.selectedHabit else { return nil }

        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -83, to: today) ?? today
        let days = (0..<84).compactMap { offset -> HabitHeatmapWidgetDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            return HabitHeatmapWidgetDay(
                date: date,
                isCompleted: appState.isHabitCompleted(habit.id, on: date),
                isToday: calendar.isDateInToday(date)
            )
        }

        return HabitHeatmapWidgetSnapshot(
            habitID: habit.id,
            habitName: habit.name,
            habitIcon: habit.icon,
            accentHex: habit.colorHex,
            currentStreak: appState.streak(for: habit.id),
            days: days
        )
    }
}
