import Foundation

enum WidgetStorage {
    static let globalSnapshotKey = "streakmap.widget.globalSnapshot"
    static let habitSnapshotKey = "streakmap.widget.habitSnapshot"

    private static var defaults: UserDefaults {
        UserDefaults(suiteName: WidgetConfig.appGroupID) ?? .standard
    }

    static func saveGlobalSnapshot(_ snapshot: GlobalHeatmapWidgetSnapshot) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        defaults.set(data, forKey: globalSnapshotKey)
    }

    static func loadGlobalSnapshot() -> GlobalHeatmapWidgetSnapshot? {
        guard let data = defaults.data(forKey: globalSnapshotKey) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(GlobalHeatmapWidgetSnapshot.self, from: data)
    }

    static func saveHabitSnapshot(_ snapshot: HabitHeatmapWidgetSnapshot) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        defaults.set(data, forKey: habitSnapshotKey)
    }

    static func loadHabitSnapshot() -> HabitHeatmapWidgetSnapshot? {
        guard let data = defaults.data(forKey: habitSnapshotKey) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(HabitHeatmapWidgetSnapshot.self, from: data)
    }
}
