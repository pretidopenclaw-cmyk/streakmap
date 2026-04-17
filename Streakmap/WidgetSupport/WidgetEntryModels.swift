import Foundation

struct GlobalHeatmapWidgetDay: Hashable, Codable {
    let date: Date
    let completionRate: Double
    let isToday: Bool
}

struct GlobalHeatmapWidgetSnapshot: Hashable, Codable {
    let title: String
    let subtitle: String
    let days: [GlobalHeatmapWidgetDay]
    let accentHex: String
    let completedToday: Int
    let totalHabits: Int
}
