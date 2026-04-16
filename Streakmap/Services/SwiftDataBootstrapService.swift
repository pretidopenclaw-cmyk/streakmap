import Foundation
import SwiftData

@MainActor
enum SwiftDataBootstrapService {
    static func bootstrapIfNeeded(context: ModelContext) throws {
        let habitDescriptor = FetchDescriptor<HabitRecord>()
        let existingHabits = try context.fetch(habitDescriptor)
        guard existingHabits.isEmpty else { return }

        let habits = PersistenceService.load([Habit].self, forKey: AppStorageKeys.habits) ?? []
        let entries = PersistenceService.load([HabitEntry].self, forKey: AppStorageKeys.entries) ?? []

        guard !habits.isEmpty else { return }

        for habit in habits {
            let record = HabitRecord(
                id: habit.id,
                name: habit.name,
                icon: habit.icon,
                colorHex: habit.colorHex,
                createdAt: habit.createdAt,
                reminderTime: habit.reminderTime,
                isArchived: habit.isArchived
            )
            context.insert(record)
        }

        for entry in entries {
            let record = HabitEntryRecord(
                id: entry.id,
                habitID: entry.habitID,
                date: entry.date,
                isCompleted: entry.isCompleted,
                note: entry.note
            )
            context.insert(record)
        }

        try context.save()
    }
}
