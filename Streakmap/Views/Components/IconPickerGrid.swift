import SwiftUI

struct IconPickerGrid: View {
    @Binding var selectedIcon: String
    let tint: Color

    private let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 4)

    var body: some View {
        LazyVGrid(columns: columns, spacing: 12) {
            ForEach(HabitIcon.allCases) { icon in
                Button {
                    selectedIcon = icon.rawValue
                } label: {
                    ZStack {
                        RoundedRectangle(cornerRadius: 18, style: .continuous)
                            .fill(selectedIcon == icon.rawValue ? tint.opacity(0.16) : StreakmapTheme.background)
                            .overlay {
                                RoundedRectangle(cornerRadius: 18, style: .continuous)
                                    .stroke(selectedIcon == icon.rawValue ? tint : Color.clear, lineWidth: 2)
                            }
                            .frame(height: 56)

                        Image(systemName: icon.rawValue)
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundStyle(selectedIcon == icon.rawValue ? tint : StreakmapTheme.textPrimary)
                    }
                }
                .buttonStyle(.plain)
            }
        }
    }
}
