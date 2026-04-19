import WidgetKit
import SwiftUI

struct StreakmapWidgetEntry: TimelineEntry {
    let date: Date
    let snapshot: GlobalHeatmapWidgetSnapshot
}

struct StreakmapWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> StreakmapWidgetEntry {
        StreakmapWidgetEntry(date: .now, snapshot: previewSnapshot)
    }

    func getSnapshot(in context: Context, completion: @escaping (StreakmapWidgetEntry) -> Void) {
        let snapshot = WidgetStorage.loadGlobalSnapshot() ?? previewSnapshot
        completion(StreakmapWidgetEntry(date: .now, snapshot: snapshot))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<StreakmapWidgetEntry>) -> Void) {
        let snapshot = WidgetStorage.loadGlobalSnapshot() ?? previewSnapshot
        let entry = StreakmapWidgetEntry(date: .now, snapshot: snapshot)
        let next = Calendar.current.date(byAdding: .minute, value: 30, to: .now) ?? .now.addingTimeInterval(1800)
        completion(Timeline(entries: [entry], policy: .after(next)))
    }

    private var previewSnapshot: GlobalHeatmapWidgetSnapshot {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)
        let start = calendar.date(byAdding: .day, value: -364, to: today) ?? today
        let days = (0..<365).compactMap { offset -> GlobalHeatmapWidgetDay? in
            guard let date = calendar.date(byAdding: .day, value: offset, to: start) else { return nil }
            let rate = [0.0, 0.2, 0.5, 0.8, 1.0][offset % 5]
            return GlobalHeatmapWidgetDay(date: date, completionRate: rate, isToday: calendar.isDateInToday(date))
        }
        return GlobalHeatmapWidgetSnapshot(
            title: "Last 365 days",
            subtitle: "Your yearly consistency at a glance",
            days: days,
            accentHex: "#7C3AED",
            completedToday: 3,
            totalHabits: 5
        )
    }
}

struct StreakmapWidgetView: View {
    var entry: StreakmapWidgetProvider.Entry

    var body: some View {
        heatmapWidget(
            days: padded(entry.snapshot.days),
            horizontalPadding: 6,
            verticalPadding: 6,
            horizontalSpacing: 2,
            verticalSpacing: 2,
            minCell: 5,
            maxCell: 12
        )
    }

    private func heatmapWidget(days: [GlobalHeatmapWidgetDay?], horizontalPadding: CGFloat, verticalPadding: CGFloat, horizontalSpacing: CGFloat, verticalSpacing: CGFloat, minCell: CGFloat, maxCell: CGFloat) -> some View {
        GeometryReader { geometry in
            let accent = Color(hex: entry.snapshot.accentHex)
            let weekCount = max(days.count / 7, 1)
            let availableWidth = geometry.size.width - (horizontalPadding * 2)
            let availableHeight = geometry.size.height - (verticalPadding * 2)

            let widthLimitedCell = (availableWidth - (CGFloat(weekCount - 1) * horizontalSpacing)) / CGFloat(weekCount)
            let heightLimitedCell = (availableHeight - (6 * verticalSpacing)) / 7

            let cellWidth = max(minCell, min(maxCell, widthLimitedCell))
            let cellHeight = max(minCell, min(maxCell * 1.6, heightLimitedCell))
            let cornerRadius = min(cellWidth, cellHeight) * 0.28

            HStack(alignment: .top, spacing: horizontalSpacing) {
                ForEach(0..<weekCount, id: \.self) { week in
                    VStack(spacing: verticalSpacing) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let index = week * 7 + weekday
                            if index < days.count, let day = days[index] {
                                RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                    .fill(color(for: day, accent: accent))
                                    .overlay {
                                        if day.isToday {
                                            RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)
                                                .stroke(Color.primary.opacity(0.8), lineWidth: 0.8)
                                        }
                                    }
                                    .frame(width: cellWidth, height: cellHeight)
                            } else {
                                Color.clear
                                    .frame(width: cellWidth, height: cellHeight)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
        .containerBackground(.background, for: .widget)
    }

    private func color(for day: GlobalHeatmapWidgetDay, accent: Color) -> Color {
        switch day.completionRate {
        case 0:
            return Color(.systemGray5).opacity(0.95)
        case 0..<0.26:
            return accent.opacity(0.32)
        case 0..<0.51:
            return accent.opacity(0.52)
        case 0..<0.76:
            return accent.opacity(0.76)
        default:
            return accent
        }
    }

    private func padded(_ days: [GlobalHeatmapWidgetDay]) -> [GlobalHeatmapWidgetDay?] {
        guard let first = days.first else { return [] }
        let weekday = Calendar.current.component(.weekday, from: first.date)
        let leadingPadding = (weekday + 5) % 7
        var result: [GlobalHeatmapWidgetDay?] = Array(repeating: nil, count: leadingPadding)
        result.append(contentsOf: days)
        while result.count % 7 != 0 {
            result.append(nil)
        }
        return result
    }
}

struct StreakmapWidget: Widget {
    let kind: String = "StreakmapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakmapWidgetProvider()) { entry in
            StreakmapWidgetView(entry: entry)
        }
        .configurationDisplayName("Streakmap Year")
        .description("See your last 365 days at a glance.")
        .supportedFamilies([.systemLarge])
    }
}

#Preview(as: .systemMedium) {
    StreakmapWidget()
} timeline: {
    StreakmapWidgetEntry(
        date: .now,
        snapshot: GlobalHeatmapWidgetSnapshot(
            title: "Last 365 days",
            subtitle: "Your yearly consistency at a glance",
            days: [],
            accentHex: "#7C3AED",
            completedToday: 2,
            totalHabits: 4
        )
    )
}
