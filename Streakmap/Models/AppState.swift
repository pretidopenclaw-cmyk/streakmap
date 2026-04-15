import Foundation
import SwiftUI

final class AppState: ObservableObject {
    @Published var habits: [Habit]
    @Published var entries: [HabitEntry]
    @Published var selectedHabitID: UUID?
    @Published var selectedDate: Date?
    @Published var isPremiumUnlocked: Bool
    @Published var hasCompletedOnboarding: Bool

    init() {
        let meditation = Habit(name: "Meditation", icon: "brain.head.profile", colorHex: HabitColor.violet.hex)
        self.habits = [meditation]
        self.entries = AppState.makeSampleEntries(for: [meditation])
        self.selectedHabitID = meditation.id
        self.selectedDate = nil
        self.isPremiumUnlocked = false
        self.hasCompletedOnboarding = false
    }

    var activeHabits: [Habit] {
        habits.filter { !$0.isArchived }
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
    }

    @discardableResult
    func addHabit(name: String, icon: String, color: HabitColor, reminderTime: Date?) -> Bool {
        let trimmed = name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        guard isPremiumUnlocked || activeHabits.count < 1 else { return false }

        let habit = Habit(name: trimmed, icon: icon, colorHex: color.hex, reminderTime: reminderTime)
        habits.append(habit)
        selectedHabitID = habit.id
        return true
    }

    func archiveHabit(_ habitID: UUID) {
        guard let index = habits.firstIndex(where: { $0.id == habitID }) else { return }
        habits[index].isArchived = true
        if selectedHabitID == habitID {
            selectedHabitID = activeHabits.first?.id
        }
    }

    func updateNote(for habitID: UUID, on date: Date, note: String) {
        let day = Calendar.current.startOfDay(for: date)
        if let index = entries.firstIndex(where: { $0.habitID == habitID && Calendar.current.isDate($0.date, inSameDayAs: day) }) {
            entries[index].note = note.isEmpty ? nil : note
        } else {
            entries.insert(HabitEntry(habitID: habitID, date: day, isCompleted: false, note: note.isEmpty ? nil : note), at: 0)
        }
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
