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

// MARK: - Widget View

struct StreakmapWidgetView: View {
    var entry: StreakmapWidgetProvider.Entry

    var body: some View {
        let accent = Color(hex: entry.snapshot.accentHex)
        let paddedDays = paddedGlobal(entry.snapshot.days)

        VStack(alignment: .leading, spacing: 10) {
            // Header — matches habit widget style
            HStack(spacing: 10) {
                ZStack {
                    RoundedRectangle(cornerRadius: 9, style: .continuous)
                        .fill(accent.opacity(0.18))
                        .frame(width: 30, height: 30)
                    Image(systemName: "square.grid.3x3.fill")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundStyle(accent)
                        .widgetAccentable()
                }

                VStack(alignment: .leading, spacing: 1) {
                    Text("Your year")
                        .font(.system(size: 16, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    Text("\(entry.snapshot.completedToday)/\(entry.snapshot.totalHabits) completed today")
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.55))
                        .lineLimit(1)
                }

                Spacer(minLength: 0)
            }

            // Heatmap — fills all remaining space (same as habit widget)
            FillingGlobalHeatmap(days: paddedDays, accent: accent)
        }
        .padding(.horizontal, 14)
        .padding(.top, 14)
        .padding(.bottom, 14)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [
                    Color(red: 0.12, green: 0.12, blue: 0.14),
                    Color(red: 0.08, green: 0.08, blue: 0.10)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Filling Heatmap (same approach as habit widget FillingWidgetHeatmap)

struct FillingGlobalHeatmap: View {
    let days: [GlobalHeatmapWidgetDay?]
    let accent: Color

    var body: some View {
        GeometryReader { geometry in
            let weekCount = max(days.count / 7, 1)
            let horizontalSpacing: CGFloat = 2.5
            let verticalSpacing: CGFloat = 2.5
            let w = geometry.size.width
            let h = geometry.size.height

            // Independent width & height — fills 100% of available space
            let cellWidth = max(0, (w - CGFloat(weekCount - 1) * horizontalSpacing) / CGFloat(weekCount))
            let cellHeight = max(0, (h - 6 * verticalSpacing) / 7)
            let radius = min(cellWidth, cellHeight) * 0.28

            HStack(alignment: .top, spacing: horizontalSpacing) {
                ForEach(0..<weekCount, id: \.self) { week in
                    VStack(spacing: verticalSpacing) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let index = week * 7 + weekday
                            if index < days.count, let day = days[index] {
                                cellView(for: day, width: cellWidth, height: cellHeight, radius: radius)
                            } else {
                                RoundedRectangle(cornerRadius: radius, style: .continuous)
                                    .fill(Color.white.opacity(0.03))
                                    .frame(width: cellWidth, height: cellHeight)
                            }
                        }
                    }
                }
            }
            .frame(width: w, height: h, alignment: .topLeading)
        }
    }

    @ViewBuilder
    private func cellView(for day: GlobalHeatmapWidgetDay, width: CGFloat, height: CGFloat, radius: CGFloat) -> some View {
        let filled = day.completionRate > 0

        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(
                filled
                ? LinearGradient(
                    colors: [accent.opacity(opacity(for: day)), accent.opacity(opacity(for: day) * 0.82)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
                : LinearGradient(
                    colors: [Color.white.opacity(0.08), Color.white.opacity(0.05)],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                  )
            )
            .overlay {
                if day.isToday {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(Color.white.opacity(0.9), lineWidth: 1.1)
                }
            }
            .frame(width: width, height: height)
            .widgetAccentableIf(filled)
    }

    private func opacity(for day: GlobalHeatmapWidgetDay) -> Double {
        switch day.completionRate {
        case 0..<0.26:
            return 0.35
        case 0..<0.51:
            return 0.55
        case 0..<0.76:
            return 0.78
        default:
            return 1.0
        }
    }
}

// MARK: - Helpers

private extension View {
    @ViewBuilder
    func widgetAccentableIf(_ condition: Bool) -> some View {
        if condition {
            self.widgetAccentable()
        } else {
            self
        }
    }
}

private func paddedGlobal(_ days: [GlobalHeatmapWidgetDay]) -> [GlobalHeatmapWidgetDay?] {
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

// MARK: - Widget Configuration

struct StreakmapWidget: Widget {
    let kind: String = "StreakmapWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: StreakmapWidgetProvider()) { entry in
            StreakmapWidgetView(entry: entry)
        }
        .configurationDisplayName("Year Heatmap")
        .description("A full-year consistency map.")
        .supportedFamilies([.systemLarge])
    }
}

#Preview(as: .systemLarge) {
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
