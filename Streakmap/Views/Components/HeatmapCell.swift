import SwiftUI

struct HeatmapCell: View {
    let color: Color
    let size: CGFloat
    var isToday: Bool = false

    var body: some View {
        RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
            .fill(color)
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: size * 0.28, style: .continuous)
                        .stroke(StreakmapTheme.textPrimary, lineWidth: 1.8)
                }
            }
            .frame(width: size, height: size)
    }
}
