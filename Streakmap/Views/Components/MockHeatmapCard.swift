import SwiftUI

struct MockHeatmapCard: View {
    private let columns = Array(repeating: GridItem(.fixed(12), spacing: 5), count: 7)
    private let levels: [Double] = [0, 0.15, 0.35, 0.6, 1]

    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Meditation")
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text("See your rhythm unfold over time")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(StreakmapTheme.textSecondary)
                }
                Spacer()
                HeroStatPill(title: "Streak", value: "12d")
            }

            LazyHGrid(rows: columns, spacing: 5) {
                ForEach(0..<84, id: \.self) { index in
                    let level = levels[(index / 3) % levels.count]
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(level == 0 ? StreakmapTheme.neutralCell : StreakmapTheme.accent.opacity(level))
                        .frame(width: 12, height: 12)
                }
            }
            .frame(height: 110)
        }
        .padding(20)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 30, style: .continuous))
        .shadow(color: StreakmapTheme.shadow, radius: 18, x: 0, y: 10)
    }
}
