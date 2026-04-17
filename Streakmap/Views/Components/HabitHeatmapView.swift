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
    private let days: [Date] = Array(
        (0..<365)
            .compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }
            .reversed()
    )

    private var weeks: [[Date]] {
        stride(from: 0, to: days.count, by: 7).map { start in
            Array(days[start..<min(start + 7, days.count)])
        }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeatmapLegend(accent: Color(hex: habit.colorHex), mode: .binary)

            ScrollViewReader { proxy in
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(alignment: .top, spacing: 5) {
                        ForEach(Array(weeks.enumerated()), id: \.offset) { weekIndex, week in
                            VStack(spacing: 5) {
                                ForEach(week, id: \.self) { day in
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
                                }
                            }
                            .id(weekIndex)
                        }
                    }
                    .padding(.vertical, 2)
                }
                .onAppear {
                    if let todayWeekIndex = weeks.firstIndex(where: { week in
                        week.contains(where: { calendar.isDateInToday($0) })
                    }) {
                        DispatchQueue.main.async {
                            proxy.scrollTo(todayWeekIndex, anchor: .trailing)
                        }
                    }
                }
            }
        }
    }
}
