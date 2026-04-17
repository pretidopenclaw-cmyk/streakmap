import Foundation

enum WidgetStorage {
    static let globalSnapshotKey = "streakmap.widget.globalSnapshot"

    static func saveGlobalSnapshot(_ snapshot: GlobalHeatmapWidgetSnapshot) {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        guard let data = try? encoder.encode(snapshot) else { return }
        UserDefaults.standard.set(data, forKey: globalSnapshotKey)
    }

    static func loadGlobalSnapshot() -> GlobalHeatmapWidgetSnapshot? {
        guard let data = UserDefaults.standard.data(forKey: globalSnapshotKey) else { return nil }
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try? decoder.decode(GlobalHeatmapWidgetSnapshot.self, from: data)
    }
}
