import SwiftUI

struct HeatmapLegend: View {
    enum Mode {
        case gradient
        case binary
    }

    let accent: Color
    let mode: Mode

    init(accent: Color, mode: Mode = .gradient) {
        self.accent = accent
        self.mode = mode
    }

    var body: some View {
        HStack(spacing: 8) {
            Text(mode == .binary ? "Not done" : "Less")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)

            if mode == .binary {
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(StreakmapTheme.neutralCell)
                    .frame(width: 14, height: 14)
                RoundedRectangle(cornerRadius: 4, style: .continuous)
                    .fill(accent)
                    .frame(width: 14, height: 14)
            } else {
                ForEach(0..<5, id: \.self) { level in
                    RoundedRectangle(cornerRadius: 4, style: .continuous)
                        .fill(level == 0 ? StreakmapTheme.neutralCell : accent.opacity(Double(level) * 0.22 + 0.1))
                        .frame(width: 14, height: 14)
                }
            }

            Text(mode == .binary ? "Done" : "More")
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)
        }
    }
}
