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

    private let calendar = Calendar.current

    private var weeks: [[Date?]] {
        let today = calendar.startOfDay(for: .now)
        guard let start = calendar.date(byAdding: .day, value: -364, to: today) else { return [] }

        let allDays = (0..<365).compactMap { calendar.date(byAdding: .day, value: $0, to: start) }
        let leadingPadding = (calendar.component(.weekday, from: start) + 5) % 7

        var padded: [Date?] = Array(repeating: nil, count: leadingPadding)
        padded.append(contentsOf: allDays)

        while padded.count % 7 != 0 {
            padded.append(nil)
        }

        let weekCount = padded.count / 7
        return (0..<weekCount).map { week in
            Array(padded[(week * 7)..<((week + 1) * 7)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeatmapLegend(accent: Color(hex: habit.colorHex), mode: .binary)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 5) {
                    ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                        VStack(spacing: 5) {
                            ForEach(Array(week.enumerated()), id: \.offset) { _, day in
                                if let day {
                                    Button {
                                        onSelectDate?(day)
                                    } label: {
                                        HeatmapCell(
                                            color: appState.isHabitCompleted(habit.id, on: day) ? Color(hex: habit.colorHex) : StreakmapTheme.neutralCell,
                                            size: cellSize,
                                            isToday: calendar.isDateInToday(day)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    Color.clear
                                        .frame(width: cellSize, height: cellSize)
                                }
                            }
                        }
                        .id(weekIndex)
                    }
                }
                .padding(.vertical, 2)
            }
        }
    }
}
