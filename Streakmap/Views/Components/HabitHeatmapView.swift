import SwiftUI

struct HabitHeatmapView: View {
    let habit: Habit
    let cellSize: CGFloat
    let onSelectDate: ((Date) -> Void)?
    @EnvironmentObject private var appState: AppState

    init(habit: Habit, cellSize: CGFloat = 12, onSelectDate: ((Date) -> Void)? = nil) {
        self.habit = habit
        self.cellSize = cellSize
        self.onSelectDate = onSelectDate
    }

    private var rows: [GridItem] {
        Array(repeating: GridItem(.fixed(cellSize), spacing: 5), count: 7)
    }

    private let days = (0..<84).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }.reversed()

    var body: some View {
        LazyHGrid(rows: rows, spacing: 5) {
            ForEach(days, id: \.self) { day in
                Button {
                    onSelectDate?(day)
                } label: {
                    HeatmapCell(
                        color: appState.isHabitCompleted(habit.id, on: day) ? Color(hex: habit.colorHex) : StreakmapTheme.neutralCell,
                        size: cellSize
                    )
                }
                .buttonStyle(.plain)
            }
        }
    }
}
