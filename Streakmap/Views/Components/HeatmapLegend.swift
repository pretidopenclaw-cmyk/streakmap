import SwiftUI

struct HeatmapLegend: View {
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            Text("Less")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)
            ForEach(0..<5, id: \.self) { level in
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(level == 0 ? StreakmapTheme.neutralCell : accent.opacity(Double(level) * 0.22 + 0.1))
                    .frame(width: 14, height: 14)
            }
            Text("More")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)
        }
    }
}
