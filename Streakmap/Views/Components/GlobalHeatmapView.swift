import SwiftUI

struct GlobalHeatmapView: View {
    @EnvironmentObject private var appState: AppState
    let onSelectDate: ((Date) -> Void)?

    init(onSelectDate: ((Date) -> Void)? = nil) {
        self.onSelectDate = onSelectDate
    }

    private let columns = Array(repeating: GridItem(.fixed(14), spacing: 6), count: 7)
    private let days = (0..<98).compactMap { Calendar.current.date(byAdding: .day, value: -$0, to: .now) }.reversed()

    var body: some View {
        LazyHGrid(rows: columns, spacing: 6) {
            ForEach(days, id: \.self) { day in
                Button {
                    onSelectDate?(day)
                } label: {
                    HeatmapCell(color: color(for: day), size: 14)
                }
                .buttonStyle(.plain)
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
