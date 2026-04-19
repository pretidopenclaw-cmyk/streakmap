import Foundation

struct HabitHeatmapWidgetDay: Hashable, Codable {
    let date: Date
    let isCompleted: Bool
    let isToday: Bool
}

struct HabitHeatmapWidgetSnapshot: Hashable, Codable {
    let habitID: UUID
    let habitName: String
    let habitIcon: String
    let accentHex: String
    let currentStreak: Int
    let days: [HabitHeatmapWidgetDay]
}
