import AppIntents
import WidgetKit

struct HabitAppEntity: AppEntity {
    static let typeDisplayRepresentation = TypeDisplayRepresentation(name: "Habit")
    static let defaultQuery = HabitQuery()

    let id: UUID
    let name: String
    let icon: String
    let colorHex: String

    var displayRepresentation: DisplayRepresentation {
        DisplayRepresentation(title: "\(name)", image: .init(systemName: icon))
    }

    init(id: UUID, name: String, icon: String, colorHex: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
    }
}

struct HabitQuery: EntityQuery {
    func entities(for identifiers: [UUID]) async throws -> [HabitAppEntity] {
        let snapshots = allAvailableSnapshots()
        return identifiers.compactMap { id in
            guard let snapshot = snapshots.first(where: { $0.habitID == id }) else { return nil }
            return HabitAppEntity(
                id: snapshot.habitID,
                name: snapshot.habitName,
                icon: snapshot.habitIcon,
                colorHex: snapshot.accentHex
            )
        }
    }

    func suggestedEntities() async throws -> [HabitAppEntity] {
        allAvailableSnapshots().map { snapshot in
            HabitAppEntity(
                id: snapshot.habitID,
                name: snapshot.habitName,
                icon: snapshot.habitIcon,
                colorHex: snapshot.accentHex
            )
        }
    }

    func defaultResult() async -> HabitAppEntity? {
        guard let first = allAvailableSnapshots().first else { return nil }
        return HabitAppEntity(
            id: first.habitID,
            name: first.habitName,
            icon: first.habitIcon,
            colorHex: first.accentHex
        )
    }

    private func allAvailableSnapshots() -> [HabitHeatmapWidgetSnapshot] {
        let all = WidgetStorage.loadAllHabitSnapshots()
        if !all.isEmpty { return all }
        // Fallback to legacy single snapshot for first launch after update
        if let legacy = WidgetStorage.loadHabitSnapshot() {
            return [legacy]
        }
        return []
    }
}

struct HabitSelectionIntent: WidgetConfigurationIntent {
    static let title: LocalizedStringResource = "Select Habit"
    static let description = IntentDescription("Choose which habit to display.")

    @Parameter(title: "Habit")
    var habit: HabitAppEntity?
}
