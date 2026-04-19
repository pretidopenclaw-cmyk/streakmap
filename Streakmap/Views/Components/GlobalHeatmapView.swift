import SwiftUI

struct GlobalHeatmapView: View {
    @EnvironmentObject private var appState: AppState
    let cellSize: CGFloat
    let onSelectDate: ((Date) -> Void)?

    init(cellSize: CGFloat = 12, onSelectDate: ((Date) -> Void)? = nil) {
        self.cellSize = cellSize
        self.onSelectDate = onSelectDate
    }

    private let calendar = Calendar.current

    private var grid: [[Date?]] {
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
            HeatmapLegend(accent: Color(hex: appState.globalHeatmapColorHex), mode: .gradient)

            CompactYearHeatmapGrid(
                days: grid.flatMap { $0 },
                minCellWidth: 4,
                maxCellWidth: max(cellSize, 9),
                minCellHeight: 6,
                maxCellHeight: max(cellSize + 2, 11),
                horizontalSpacing: 3,
                verticalSpacing: 3,
                onSelectDate: onSelectDate,
                isToday: { calendar.isDateInToday($0) },
                colorForDate: color(for:)
            )
        }
    }

    private func color(for date: Date) -> Color {
        let rate = appState.completionRate(for: date)
        let accent = Color(hex: appState.globalHeatmapColorHex)
        switch rate {
        case 0:
            return StreakmapTheme.neutralCell
        case 0..<0.26:
            return accent.opacity(0.25)
        case 0..<0.51:
            return accent.opacity(0.45)
        case 0..<0.76:
            return accent.opacity(0.7)
        default:
            return accent
        }
    }
}
