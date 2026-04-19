import SwiftUI

struct CompactYearHeatmapGrid: View {
    let days: [Date?]
    let colorForDate: (Date) -> Color
    let minCellWidth: CGFloat
    let maxCellWidth: CGFloat
    let minCellHeight: CGFloat
    let maxCellHeight: CGFloat
    let horizontalSpacing: CGFloat
    let verticalSpacing: CGFloat
    let horizontalPadding: CGFloat
    let verticalPadding: CGFloat
    let onSelectDate: ((Date) -> Void)?
    let isToday: (Date) -> Bool

    init(
        days: [Date?],
        minCellWidth: CGFloat = 4,
        maxCellWidth: CGFloat = 10,
        minCellHeight: CGFloat = 4,
        maxCellHeight: CGFloat = 10,
        horizontalSpacing: CGFloat = 3,
        verticalSpacing: CGFloat = 3,
        horizontalPadding: CGFloat = 0,
        verticalPadding: CGFloat = 0,
        onSelectDate: ((Date) -> Void)? = nil,
        isToday: @escaping (Date) -> Bool,
        colorForDate: @escaping (Date) -> Color
    ) {
        self.days = days
        self.minCellWidth = minCellWidth
        self.maxCellWidth = maxCellWidth
        self.minCellHeight = minCellHeight
        self.maxCellHeight = maxCellHeight
        self.horizontalSpacing = horizontalSpacing
        self.verticalSpacing = verticalSpacing
        self.horizontalPadding = horizontalPadding
        self.verticalPadding = verticalPadding
        self.onSelectDate = onSelectDate
        self.isToday = isToday
        self.colorForDate = colorForDate
    }

    var body: some View {
        GeometryReader { geometry in
            let weekCount = max(days.count / 7, 1)
            let availableWidth = geometry.size.width - (horizontalPadding * 2)
            let availableHeight = geometry.size.height - (verticalPadding * 2)
            let cellWidth = max(minCellWidth, min(maxCellWidth, (availableWidth - (CGFloat(weekCount - 1) * horizontalSpacing)) / CGFloat(weekCount)))
            let cellHeight = max(minCellHeight, min(maxCellHeight, (availableHeight - (6 * verticalSpacing)) / 7))

            HStack(alignment: .top, spacing: horizontalSpacing) {
                ForEach(0..<weekCount, id: \.self) { week in
                    VStack(spacing: verticalSpacing) {
                        ForEach(0..<7, id: \.self) { weekday in
                            let index = week * 7 + weekday
                            if index < days.count, let day = days[index] {
                                let cell = HeatmapCell(
                                    color: colorForDate(day),
                                    width: cellWidth,
                                    height: cellHeight,
                                    isToday: isToday(day)
                                )

                                if let onSelectDate {
                                    Button {
                                        onSelectDate(day)
                                    } label: {
                                        cell
                                    }
                                    .buttonStyle(.plain)
                                } else {
                                    cell
                                }
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
    }
}
