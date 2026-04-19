import SwiftUI

struct HeatmapCell: View {
    let color: Color
    let width: CGFloat
    let height: CGFloat
    var isToday: Bool = false

    init(color: Color, size: CGFloat, isToday: Bool = false) {
        self.color = color
        self.width = size
        self.height = size
        self.isToday = isToday
    }

    init(color: Color, width: CGFloat, height: CGFloat, isToday: Bool = false) {
        self.color = color
        self.width = width
        self.height = height
        self.isToday = isToday
    }

    var body: some View {
        let radius = min(width, height) * 0.28

        RoundedRectangle(cornerRadius: radius, style: .continuous)
            .fill(color)
            .overlay {
                if isToday {
                    RoundedRectangle(cornerRadius: radius, style: .continuous)
                        .stroke(StreakmapTheme.textPrimary, lineWidth: 1.4)
                }
            }
            .frame(width: width, height: height)
    }
}
