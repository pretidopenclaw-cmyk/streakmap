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

    private let columns = Array(repeating: GridItem(.fixed(6), spacing: 3), count: 7)

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 2) {
                    Text(entry.snapshot.title)
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                    Text("\(entry.snapshot.completedToday)/\(max(entry.snapshot.totalHabits, 1)) today")
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }
                Spacer()
            }

            let accent = Color(hex: entry.snapshot.accentHex)
            let paddedDays = padded(entry.snapshot.days)
            let weekCount = paddedDays.count / 7

            HStack(alignment: .top, spacing: 3) {
                ForEach(0..<weekCount, id: \.self) { week in
                    VStack(spacing: 3) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let index = week * 7 + weekday
                            if let day = paddedDays[index] {
                                RoundedRectangle(cornerRadius: 2, style: .continuous)
                                    .fill(color(for: day, accent: accent))
                                    .overlay {
                                        if day.isToday {
                                            RoundedRectangle(cornerRadius: 2, style: .continuous)
                                                .stroke(Color.primary.opacity(0.7), lineWidth: 0.8)
                                        }
                                    }
                                    .frame(width: 6, height: 6)
                            } else {
                                Color.clear.frame(width: 6, height: 6)
                            }
                        }
                    }
                }
            }
        }
        .padding(12)
        .containerBackground(.background, for: .widget)
    }

    private func color(for day: GlobalHeatmapWidgetDay, accent: Color) -> Color {
        switch day.completionRate {
        case 0:
            return Color(.systemGray5)
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
        .supportedFamilies([.systemMedium, .systemLarge])
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
