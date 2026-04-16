import Foundation
import SwiftData

@Model
final class HabitEntryRecord {
    @Attribute(.unique) var id: UUID
    var habitID: UUID
    var date: Date
    var isCompleted: Bool
    var note: String?

    init(
        id: UUID = UUID(),
        habitID: UUID,
        date: Date,
        isCompleted: Bool,
        note: String? = nil
    ) {
        self.id = id
        self.habitID = habitID
        self.date = Calendar.current.startOfDay(for: date)
        self.isCompleted = isCompleted
        self.note = note
    }
}
