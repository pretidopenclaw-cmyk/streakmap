import Foundation

struct HabitStatusRow: Identifiable {
    let habit: Habit
    let isCompleted: Bool

    var id: UUID { habit.id }
}
