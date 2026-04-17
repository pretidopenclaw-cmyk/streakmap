import SwiftUI

struct GlobalHeatmapView: View {
    @EnvironmentObject private var appState: AppState
    let cellSize: CGFloat
    let onSelectDate: ((Date) -> Void)?

    init(cellSize: CGFloat = 12, onSelectDate: ((Date) -> Void)? = nil) {
        self.cellSize = cellSize
        self.onSelectDate = onSelectDate
    }

    private var columns: [GridItem] {
        Array(repeating: GridItem(.fixed(cellSize), spacing: 5), count: 7)
    }

    private var days: [Date] {
        (0..<364)
            .compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }
            .reversed()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HeatmapLegend(accent: Color(hex: appState.globalHeatmapColorHex), mode: .gradient)

            ScrollView(.horizontal, showsIndicators: false) {
                LazyHGrid(rows: columns, spacing: 5) {
                    ForEach(days, id: \.self) { day in
                        Button {
                            onSelectDate?(day)
                        } label: {
                            HeatmapCell(
                                color: color(for: day),
                                size: cellSize,
                                isToday: Calendar.current.isDateInToday(day)
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 2)
            }
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
