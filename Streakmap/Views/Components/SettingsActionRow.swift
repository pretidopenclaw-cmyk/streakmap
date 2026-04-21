import SwiftUI

struct SettingsActionRow: View {
    let title: String
    let subtitle: String
    let actionTitle: String
    let isPrimary: Bool
    let action: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)

            Button(actionTitle, action: action)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(isPrimary ? StreakmapTheme.accent : StreakmapTheme.background)
                .foregroundStyle(isPrimary ? Color.white : StreakmapTheme.textPrimary)
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
        }
    }
}
