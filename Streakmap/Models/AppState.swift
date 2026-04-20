import Foundation
import SwiftUI
import SwiftData
import WidgetKit

@MainActor
final class AppState: ObservableObject {
    @Published var habits: [Habit]
    @Published var entries: [HabitEntry]
    @Published var selectedHabitID: UUID?
    @Published var selectedDate: Date?
    @Published var isPremiumUnlocked: Bool
    @Published var hasCompletedOnboarding: Bool
    @Published var globalHeatmapColorHex: String
    var modelContext: ModelContext?

    init() {
        let initialHabits: [Habit]
        if let storedHabits = PersistenceService.load([Habit].self, forKey: AppStorageKeys.habits),
           !storedHabits.isEmpty {
            initialHabits = storedHabits
        } else {
            initialHabits = []
        }

        let initialEntries: [HabitEntry]
        if let storedEntries = PersistenceService.load([HabitEntry].self, forKey: AppStorageKeys.entries) {
            initialEntries = storedEntries
        } else {
            initialEntries = AppState.makeSampleEntries(for: initialHabits)
        }

        let fallbackID = initialHabits.first(where: { !$0.isArchived })?.id
        let initialSelectedHabitID: UUID?
        if let storedSelected = PersistenceService.loadString(forKey: AppStorageKeys.selectedHabitID),
           let uuid = UUID(uuidString: storedSelected),
           initialHabits.contains(where: { $0.id == uuid && !$0.isArchived }) {
            initialSelectedHabitID = uuid
        } else {
            initialSelectedHabitID = fallbackID
        }

        self.habits = initialHabits
        self.entries = initialEntries
        self.selectedHabitID = initialSelectedHabitID
        self.selectedDate = nil
        self.isPremiumUnlocked = PersistenceService.loadBool(forKey: AppStorageKeys.isPremiumUnlocked)
        self.hasCompletedOnboarding = PersistenceService.loadBool(forKey: AppStorageKeys.hasCompletedOnboarding)
        self.globalHeatmapColorHex = PersistenceService.loadString(forKey: "streakmap.globalHeatmapColorHex") ?? HabitColor.violet.hex
        self.modelContext = nil
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    func attachModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    func loadFromSwiftDataIfAvailable() {
        guard let context = modelContext else { return }

        do {
            let habitRecords = try context.fetch(FetchDescriptor<HabitRecord>())
            let entryRecords = try context.fetch(FetchDescriptor<HabitEntryRecord>())

            if !habitRecords.isEmpty {
                self.habits = habitRecords.map {
                    Habit(
                        id: $0.id,
                        name: $0.name,
                        icon: $0.icon,
                        colorHex: $0.colorHex,
                        createdAt: $0.createdAt,
                        reminderTime: $0.reminderTime,
                        isArchived: $0.isArchived
                    )
                }
            }

            if !entryRecords.isEmpty {
                self.entries = entryRecords.map {
                    HabitEntry(
                        id: $0.id,
                        habitID: $0.habitID,
                        date: $0.date,
                        isCompleted: $0.isCompleted,
                        note: $0.note
                    )
                }
            }
        } catch {
            return
        }
    }

    func persist() {
        PersistenceService.save(habits, forKey: AppStorageKeys.habits)
        PersistenceService.save(entries, forKey: AppStorageKeys.entries)
        PersistenceService.saveString(selectedHabitID?.uuidString, forKey: AppStorageKeys.selectedHabitID)
        PersistenceService.saveBool(isPremiumUnlocked, forKey: AppStorageKeys.isPremiumUnlocked)
        PersistenceService.saveBool(hasCompletedOnboarding, forKey: AppStorageKeys.hasCompletedOnboarding)
        PersistenceService.saveString(globalHeatmapColorHex, forKey: "streakmap.globalHeatmapColorHex")
        WidgetStorage.saveGlobalSnapshot(WidgetDataBuilder.buildGlobalSnapshot(from: self))
        if let habitSnapshot = WidgetDataBuilder.buildHabitSnapshot(from: self) {
            WidgetStorage.saveHabitSnapshot(habitSnapshot)
        }
        WidgetCenter.shared.reloadAllTimelines()
        syncToSwiftData()
    }

    private func syncToSwiftData() {
        guard let context = modelContext else { return }

        do {
            let existingHabits = try context.fetch(FetchDescriptor<HabitRecord>())
            for record in existingHabits {
                context.delete(record)
            }

            let existingEntries = try context.fetch(FetchDescriptor<HabitEntryRecord>())
            for record in existingEntries {
                context.delete(record)
            }

            for habit in habits {
                context.insert(HabitRecord(
                    id: habit.id,
                    name: habit.name,
                    icon: habit.icon,
                    colorHex: habit.colorHex,
                    createdAt: habit.createdAt,
                    reminderTime: habit.reminderTime,
                    isArchived: habit.isArchived
                ))
            }

            for entry in entries {
                context.insert(HabitEntryRecord(
                    id: entry.id,
                    habitID: entry.habitID,
                    date: entry.date,
                    isCompleted: entry.isCompleted,
                    note: entry.note
                ))
            }

            try context.save()
        } catch {
            return
        }
    }

    var selectedHabit: Habit? {
        activeHabits.first(where: { $0.id == selectedHabitID }) ?? activeHabits.first
    }

    func selectHabit(_ habitID: UUID) {
        selectedHabitID = habitID
        persist()
    }

    func updateGlobalHeatmapColor(_ color: HabitColor) {
        globalHeatmapColorHex = color.hex
        persist()
    }

    func toggleHabit(_ habitID: UUID, on date: Date) {
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            entries[index].isCompleted.toggle()
        } else {
            entries.insert(HabitEntry(habitID: habitID, date: day, isCompleted: true), at: 0)
        }
        persist()
    }

    @discardableResult
    func addHabit(name: String, icon: String, color: HabitColor, reminderTime: Date?) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard isPremiumUnlocked || activeHabits.count < 1 else { return false }

        let habit = Habit(name: trimmed, icon: icon, colorHex: color.hex, reminderTime: reminderTime)
        habits.append(habit)
        selectedHabitID = habit.id
        persist()
        if reminderTime != nil {
            Task { await ReminderService.scheduleReminder(for: habit) }
        }
        return true
    }

    func updateHabit(
        _ habitID: UUID,
        name: String,
        icon: String,
        color: HabitColor,
        reminderTime: Date?
    ) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }

        habits[index].name = name.trimmingCharacters(in: .whitespacesAndNewlines)
        habits[index].icon = icon.isEmpty ? "sparkles" : icon
        habits[index].colorHex = color.hex
        habits[index].reminderTime = reminderTime

        persist()

        if reminderTime != nil {
            Task { await ReminderService.scheduleReminder(for: habits[index]) }
        } else {
            ReminderService.removeReminder(for: habitID)
        }
    }

    func archiveHabit(_ habitID: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        habits[index].isArchived = true
        if selectedHabitID == habitID {
            selectedHabitID = activeHabits.first?.id
        }
        ReminderService.removeReminder(for: habitID)
        persist()
    }

    func updateNote(for habitID: UUID, on date: Date, note: String) {
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            entries[index].note = note.isEmpty ? nil : note
        } else {
            entries.insert(HabitEntry(habitID: habitID, date: day, isCompleted: false, note: note.isEmpty ? nil : note), at: 0)
        }
        persist()
    }

    func note(for habitID: UUID, on date: Date) -> String {
        entries.first(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: date) })?.note ?? ""
    }

    func habitStatusRows(for date: Date) -> [HabitStatusRow] {
        activeHabits.map { habit in
            HabitStatusRow(
                habit: habit,
                isCompleted: isHabitCompleted(habit.id, on: date)
            )
        }
    }

    func completionRate(for date: Date) -> Double {
        let habits = activeHabits
        guard !habits.isEmpty else { return 0 }
        let completedCount = habits.filter { isHabitCompleted($0.id, on: date) }.count
        return Double(completedCount) / Double(habits.count)
    }

    func isHabitCompleted(_ habitID: UUID, on date: Date) -> Bool {
        entries.first(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: date) })?.isCompleted == true
    }

    func streak(for habitID: UUID) -> Int {
        let calendar = Calendar.current
        let completedDays = Set(
            entries
                .filter { $0.habitID == habitID && $0.isCompleted }
                .map { calendar.startOfDay(for: $0.date) }
        )

        var streak = 0
        var cursor = calendar.startOfDay(for: .now)

        while completedDays.contains(cursor) {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return streak
    }

    func bestStreak(for habitID: UUID, lookbackDays: Int = 365) -> Int {
        let calendar = Calendar.current
        let completedDays = Set(
            entries
                .filter { $0.habitID == habitID && $0.isCompleted }
                .map { calendar.startOfDay(for: $0.date) }
        )

        let dates = (0..<lookbackDays)
            .compactMap { calendar.date(byAdding: .day, value: -$0, to: .now) }
            .map { calendar.startOfDay(for: $0) }
            .reversed()

        var best = 0
        var current = 0

        for date in dates {
            if completedDays.contains(date) {
                current += 1
                best = max(best, current)
            } else {
                current = 0
            }
        }

        return best
    }

    func completionRate(for habitID: UUID, overLast days: Int) -> Double {
        let dates = (0..<days).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }
        guard !dates.isEmpty else { return 0 }
        let completed = dates.filter { isHabitCompleted(habitID, on: $0) }.count
        return Double(completed) / Double(dates.count)
    }

    func globalCompletionRate(overLast days: Int) -> Double {
        let dates = (0..<days).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }
        guard !dates.isEmpty else { return 0 }
        let values = dates.map { completionRate(for: $0) }
        let total = values.reduce(0, +)
        return total / Double(values.count)
    }

    func bestPerformingHabit(overLast days: Int = 30) -> Habit? {
        activeHabits.max { completionRate(for: $0.id, overLast: days) < completionRate(for: $1.id, overLast: days) }
    }

    func needsAttentionHabit(overLast days: Int = 30) -> Habit? {
        activeHabits.min { completionRate(for: $0.id, overLast: days) < completionRate(for: $1.id, overLast: days) }
    }

    func totalCompletedDays(overLast days: Int) -> Int {
        let dates = (0..<days).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }
        return dates.filter { completionRate(for: $0) > 0 }.count
    }

    func perfectDays(overLast days: Int) -> Int {
        let dates = (0..<days).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }
        return dates.filter { completionRate(for: $0) == 1 }.count
    }

    func currentGlobalStreak() -> Int {
        let calendar = Calendar.current
        var streak = 0
        var cursor = calendar.startOfDay(for: .now)

        while completionRate(for: cursor) > 0 {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }

        return streak
    }

    func entry(for habitID: UUID, on date: Date) -> HabitEntry? {
        entries.first(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: date) })
    }

    private static func makeSampleEntries(for habits: [Habit]) -> [HabitEntry] {
        var items: [HabitEntry] = []
        let calendar = Calendar.current
        for offset in 0..<120 {
            guard let date = calendar.date(byAdding: .day, value: -offset, to: .now) else { continue }
            for (index, habit) in habits.enumerated() {
                let completed = ((offset + index) % (index == 0 ? 2 : 3)) != 0
                let note = completed && offset % 9 == 0 ? "Felt great today" : nil
                items.append(HabitEntry(habitID: habit.id, date: date, isCompleted: completed, note: note))
            }
        }
        return items
    }
}
