import SwiftUI

struct ColorSwatchPicker: View {
    @Binding var selectedColor: HabitColor

    var body: some View {
        HStack(spacing: 12) {
            ForEach(HabitColor.allCases) { habitColor in
                Button {
                    selectedColor = habitColor
                    HapticService.tap()
                } label: {
                    Circle()
                        .fill(habitColor.color)
                        .frame(width: 34, height: 34)
                        .overlay {
                            if selectedColor == habitColor {
                                Circle()
                                    .stroke(.white, lineWidth: 3)
                                    .padding(4)
                            }
                        }
                        .shadow(color: habitColor.color.opacity(0.16), radius: 8, x: 0, y: 4)
                }
                .buttonStyle(.plain)
            }
        }
    }
}
