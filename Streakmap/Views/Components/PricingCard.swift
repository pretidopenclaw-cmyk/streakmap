import SwiftUI

struct PricingCard: View {
    let title: String
    let subtitle: String
    let price: String
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                if isHighlighted {
                    Text("Best")
                        .font(.system(size: 12, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(StreakmapTheme.accent.opacity(0.12))
                        .foregroundStyle(StreakmapTheme.accent)
                        .clipShape(Capsule())
                }
            }

            Text(subtitle)
                .font(.system(size: 14, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)

            Text(price)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(StreakmapTheme.textPrimary)
        }
        .padding(18)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(StreakmapTheme.card)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isHighlighted ? StreakmapTheme.accent : Color.clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
