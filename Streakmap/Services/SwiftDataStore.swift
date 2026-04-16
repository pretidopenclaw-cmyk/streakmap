import Foundation
import SwiftData

@MainActor
final class SwiftDataStore: ObservableObject {
    let container: ModelContainer

    init() {
        do {
            container = try ModelContainer(for: HabitRecord.self, HabitEntryRecord.self)
            try SwiftDataBootstrapService.bootstrapIfNeeded(context: container.mainContext)
        } catch {
            fatalError("Failed to initialize SwiftData container: \(error.localizedDescription)")
        }
    }
}
