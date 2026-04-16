import SwiftUI

struct ScreenHeader: View {
    let eyebrow: String?
    let title: String
    let subtitle: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            if let eyebrow {
                Text(eyebrow.uppercased())
                    .font(.system(size: 12, weight: .bold, design: .rounded))
                    .foregroundStyle(StreakmapTheme.accent)
            }

            Text(title)
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(StreakmapTheme.textPrimary)

            if let subtitle {
                Text(subtitle)
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textSecondary)
            }
        }
    }
}
