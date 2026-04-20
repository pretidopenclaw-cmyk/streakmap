import SwiftUI
import WidgetKit

struct HabitWidgetCardView: View {
    let snapshot: HabitHeatmapWidgetSnapshot
    @Environment(\.widgetFamily) private var family

    var body: some View {
        let accent = Color(hex: snapshot.accentHex)
        let paddedDays = padded(snapshot.days)

        Group {
            if family == .systemSmall {
                let visibleDays: [HabitHeatmapWidgetDay?] = Array(paddedDays.suffix(7 * 12))
                VStack(alignment: .leading, spacing: 10) {
                    header(accent: accent, compact: true)
                    CompactWidgetHeatmap(
                        days: visibleDays,
                        accent: accent,
                        horizontalSpacing: 3,
                        verticalSpacing: 3,
                        horizontalPadding: 0,
                        verticalPadding: 0,
                        minCellWidth: 8,
                        maxCellWidth: 12,
                        minCellHeight: 8,
                        maxCellHeight: 12,
                        isCompleted: { $0.isCompleted },
                        isToday: { $0.isToday }
                    )
                }
            } else {
                let visibleDays: [HabitHeatmapWidgetDay?] = Array(paddedDays.suffix(7 * 18))
                HStack(spacing: 14) {
                    VStack(alignment: .leading, spacing: 10) {
                        header(accent: accent, compact: false)
                        Spacer(minLength: 0)
                    }
                    .frame(width: 108, alignment: .topLeading)

                    CompactWidgetHeatmap(
                        days: visibleDays,
                        accent: accent,
                        horizontalSpacing: 2,
                        verticalSpacing: 3,
                        horizontalPadding: 0,
                        verticalPadding: 0,
                        minCellWidth: 7,
                        maxCellWidth: 10,
                        minCellHeight: 8,
                        maxCellHeight: 11,
                        isCompleted: { $0.isCompleted },
                        isToday: { $0.isToday }
                    )
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(family == .systemSmall ? 14 : 16)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.12, blue: 0.14), Color(red: 0.09, green: 0.09, blue: 0.11)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private func header(accent: Color, compact: Bool) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(accent.opacity(0.16))
                    .frame(width: compact ? 28 : 32, height: compact ? 28 : 32)
                Image(systemName: snapshot.habitIcon)
                    .font(.system(size: compact ? 13 : 15, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 2) {
                Text(snapshot.habitName)
                    .font(.system(size: compact ? 14 : 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(snapshot.currentStreak) day streak")
                    .font(.system(size: compact ? 11 : 12, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.62))
                    .lineLimit(1)
            }

            if compact { Spacer() }
        }
    }
}

struct CompactWidgetHeatmap<Day>: View {
    let days: [Day?]
    let accent: Color
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let minCellWidth: CGFloat
    let maxCellWidth: CGFloat
    let minCellHeight: CGFloat
    let maxCellHeight: CGFloat
    let isCompleted: (Day) -> Bool
    let isToday: (Day) -> Bool

    var body: some View {
        GeometryReader { geometry in
            let weekCount = max(days.count / 7, 1)
            let availableWidth = geometry.size.width - (horizontalPadding * 2)
            let availableHeight = geometry.size.height - (verticalPadding * 2)
            let cellWidth = max(minCellWidth, min(maxCellWidth, (availableWidth - (CGFloat(weekCount - 1) * horizontalSpacing)) / CGFloat(weekCount)))
            let cellHeight = max(minCellHeight, min(maxCellHeight, (availableHeight - (6 * verticalSpacing)) / 7))
            let radius = min(cellWidth, cellHeight) * 0.28

            HStack(alignment: .top, spacing: horizontalSpacing) {
                ForEach(0..<weekCount, id: \.self) { week in
                    VStack(spacing: verticalSpacing) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let index = week * 7 + weekday
                            if index < days.count, let day = days[index] {
                                RoundedRectangle(cornerRadius: radius, style: .continuous)
                                    .fill(isCompleted(day) ? accent : Color.white.opacity(0.10))
                                    .overlay {
                                        if isToday(day) {
                                            RoundedRectangle(cornerRadius: radius, style: .continuous)
                                                .stroke(Color.white.opacity(0.78), lineWidth: 0.9)
                                        }
                                    }
                                    .frame(width: cellWidth, height: cellHeight)
                            } else {
                                RoundedRectangle(cornerRadius: radius, style: .continuous)
                                    .fill(Color.white.opacity(0.04))
                                    .frame(width: cellWidth, height: cellHeight)
                            }
                        }
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            .padding(.horizontal, horizontalPadding)
            .padding(.vertical, verticalPadding)
        }
    }

    private func padded(_ days: [Day]) -> [Day?] { days }
}

func padded(_ days: [HabitHeatmapWidgetDay]) -> [HabitHeatmapWidgetDay?] {
    guard let first = days.first else { return [] }
    let weekday = Calendar.current.component(.weekday, from: first.date)
    let leadingPadding = (weekday + 5) % 7
    var result: [HabitHeatmapWidgetDay?] = Array(repeating: nil, count: leadingPadding)
    result.append(contentsOf: days)
    while result.count % 7 != 0 {
        result.append(nil)
    }
    return result
}
