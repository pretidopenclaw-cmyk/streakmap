import Foundation
import SwiftUI

@MainActor
final class AppState: ObservableObject {
    @Published var habits: [Habit]
    @Published var entries: [HabitEntry]
    @Published var selectedHabitID: UUID?
    @Published var selectedDate: Date?
    @Published var isPremiumUnlocked: Bool
    @Published var hasCompletedOnboarding: Bool

    init() {
        if let storedHabits = PersistenceService.load([Habit].self, forKey: AppStorageKeys.habits), !storedHabits.isEmpty {
            self.habits = storedHabits
        } else {
            let meditation = Habit(name: "Meditation", icon: "brain.head.profile", colorHex: HabitColor.violet.hex)
            self.habits = [meditation]
        }

        if let storedEntries = PersistenceService.load([HabitEntry].self, forKey: AppStorageKeys.entries) {
            self.entries = storedEntries
        } else {
            self.entries = AppState.makeSampleEntries(for: self.habits)
        }

        let fallbackID = self.habits.first?.id
        if let storedSelected = PersistenceService.loadString(forKey: AppStorageKeys.selectedHabitID),
           let uuid = UUID(uuidString: storedSelected),
           self.habits.contains(where: { $0.id == uuid && !$0.isArchived }) {
            self.selectedHabitID = uuid
        } else {
            self.selectedHabitID = fallbackID
        }

        self.selectedDate = nil
        self.isPremiumUnlocked = PersistenceService.loadBool(forKey: AppStorageKeys.isPremiumUnlocked)
        self.hasCompletedOnboarding = PersistenceService.loadBool(forKey: AppStorageKeys.hasCompletedOnboarding)
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
    }

    func persist() {
        PersistenceService.save(habits, forKey: AppStorageKeys.habits)
        PersistenceService.save(entries, forKey: AppStorageKeys.entries)
        PersistenceService.saveString(selectedHabitID?.uuidString, forKey: AppStorageKeys.selectedHabitID)
        PersistenceService.saveBool(isPremiumUnlocked, forKey: AppStorageKeys.isPremiumUnlocked)
        PersistenceService.saveBool(hasCompletedOnboarding, forKey: AppStorageKeys.hasCompletedOnboarding)
    }

    var selectedHabit: Habit? {
        activeHabits.first(where: { $0.id == selectedHabitID }) ?? activeHabits.first
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
        return true
    }

    func archiveHabit(_ habitID: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        habits[index].isArchived = true
        if selectedHabitID == habitID {
            selectedHabitID = activeHabits.first?.id
        }
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
        var streak = 0
        var cursor = Calendar.current.startOfDay(for: .now)
        while isHabitCompleted(habitID, on: cursor) {
            streak += 1
            guard let previous = Calendar.current.date(byAdding: .day, value: -1, to: cursor) else { break }
            cursor = previous
        }
        return streak
    }

    func bestStreak(for habitID: UUID, lookbackDays: Int = 365) -> Int {
        let dates = (0..<lookbackDays).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }.reversed()
        var best = 0
        var current = 0
        for date in dates {
            if isHabitCompleted(habitID, on: date) {
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
