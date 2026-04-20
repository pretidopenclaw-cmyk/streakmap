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
                // Small: 12 semaines (~3 mois)
                let visibleDays: [HabitHeatmapWidgetDay?] = Array(paddedDays.suffix(7 * 12))
                VStack(alignment: .leading, spacing: 8) {
                    header(accent: accent, compact: true)
                    FillingWidgetHeatmap(
                        days: visibleDays,
                        accent: accent,
                        horizontalSpacing: 2.5,
                        verticalSpacing: 2.5,
                        isCompleted: { $0.isCompleted },
                        isToday: { $0.isToday }
                    )
                }
            } else {
                // Medium: 26 semaines (~6 mois), bon équilibre visuel
                let visibleDays: [HabitHeatmapWidgetDay?] = Array(paddedDays.suffix(7 * 26))
                VStack(alignment: .leading, spacing: 10) {
                    header(accent: accent, compact: false)
                    FillingWidgetHeatmap(
                        days: visibleDays,
                        accent: accent,
                        horizontalSpacing: 3,
                        verticalSpacing: 3,
                        isCompleted: { $0.isCompleted },
                        isToday: { $0.isToday }
                    )
                }
            }
        }
        .padding(.horizontal, family == .systemSmall ? 12 : 14)
        .padding(.top, family == .systemSmall ? 12 : 14)
        .padding(.bottom, family == .systemSmall ? 12 : 14)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [Color(red: 0.12, green: 0.12, blue: 0.14), Color(red: 0.08, green: 0.08, blue: 0.10)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    @ViewBuilder
    private func header(accent: Color, compact: Bool) -> some View {
        HStack(spacing: 10) {
            ZStack {
                RoundedRectangle(cornerRadius: 9, style: .continuous)
                    .fill(accent.opacity(0.18))
                    .frame(width: compact ? 26 : 30, height: compact ? 26 : 30)
                Image(systemName: snapshot.habitIcon)
                    .font(.system(size: compact ? 12 : 14, weight: .semibold))
                    .foregroundStyle(accent)
            }

            VStack(alignment: .leading, spacing: 1) {
                Text(snapshot.habitName)
                    .font(.system(size: compact ? 14 : 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text("\(snapshot.currentStreak) day streak")
                    .font(.system(size: compact ? 10 : 11, weight: .medium, design: .rounded))
                    .foregroundStyle(Color.white.opacity(0.55))
                    .lineLimit(1)
            }

            Spacer(minLength: 0)
        }
    }
}

/// Heatmap qui remplit **exactement** l'espace disponible.
/// Les cellules prennent chacune une "case" de grille — largeur et hauteur
/// sont calculées indépendamment pour utiliser 100% de la surface.
struct FillingWidgetHeatmap<Day>: View {
    let days: [Day?]
    let accent: Color
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let isCompleted: (Day) -> Bool
    let isToday: (Day) -> Bool

    var body: some View {
        GeometryReader { geometry in
            let weekCount = max(days.count / 7, 1)
            let w = geometry.size.width
            let h = geometry.size.height

            // Cellules qui remplissent exactement — pas de min/max, pas de carré forcé
            let cellWidth = max(0, (w - CGFloat(weekCount - 1) * horizontalSpacing) / CGFloat(weekCount))
            let cellHeight = max(0, (h - 6 * verticalSpacing) / 7)
            let radius = min(cellWidth, cellHeight) * 0.28

            HStack(alignment: .top, spacing: horizontalSpacing) {
                ForEach(0..<weekCount, id: \.self) { week in
                    VStack(spacing: verticalSpacing) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let index = week * 7 + weekday
                            if index < days.count, let day = days[index] {
                                cell(for: day, width: cellWidth, height: cellHeight, radius: radius)
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
    private func cell(for day: Day, width: CGFloat, height: CGFloat, radius: CGFloat) -> some View {
        let completed = isCompleted(day)
        let today = isToday(day)

        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(
                completed
                ? LinearGradient(
                    colors: [accent, accent.opacity(0.82)],
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
                if today {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(Color.white.opacity(0.9), lineWidth: 1.1)
                }
            }
            .frame(width: width, height: height)
    }
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
