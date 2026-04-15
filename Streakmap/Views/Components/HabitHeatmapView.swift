import SwiftUI

struct HabitHeatmapView: View {
    let habit: Habit
    @EnvironmentObject private var appState: AppState
    private let rows = Array(repeating: GridItem(.fixed(12), spacing: 5), count: 7)
    private let days = (0..<84).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }.reversed()

    var body: some View {
        LazyHGrid(rows: rows, spacing: 5) {
            ForEach(days, id: \.self) { day in
                HeatmapCell(
                    color: appState.isHabitCompleted(habit.id, on: day) ? Color(hex: habit.colorHex) : StreakmapTheme.neutralCell,
                    size: 12
                )
            }
        }
    }
}
