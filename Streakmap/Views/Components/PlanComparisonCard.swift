import SwiftUI

struct PlanComparisonCard: View {
    let planName: String
    let features: [String]
    let isHighlighted: Bool

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text(planName)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Spacer()
                if isHighlighted {
                    Text("Recommended")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(StreakmapTheme.accent.opacity(0.12))
                        .foregroundStyle(StreakmapTheme.accent)
                        .clipShape(Capsule())
                }
            }

            VStack(alignment: .leading, spacing: 8) {
                ForEach(features, id: \.self) { feature in
                    Text("• \(feature)")
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(StreakmapTheme.textSecondary)
                }
            }
        }
        .padding(18)
        .background(Color.white)
        .overlay(
            RoundedRectangle(cornerRadius: 24, style: .continuous)
                .stroke(isHighlighted ? StreakmapTheme.accent : Color.clear, lineWidth: 2)
        )
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
