import SwiftUI

struct OnboardingView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        VStack(spacing: 28) {
            Spacer()

            VStack(spacing: 18) {
                Image(systemName: "square.grid.3x3.fill")
                    .font(.system(size: 54, weight: .semibold))
                    .foregroundStyle(StreakmapTheme.accent)

                VStack(spacing: 10) {
                    Text("Streakmap")
                        .font(.system(size: 34, weight: .bold, design: .rounded))
                        .foregroundStyle(StreakmapTheme.textPrimary)
                    Text("Build consistency through the most beautiful habit heatmap on iPhone.")
                        .font(.system(size: 17, weight: .medium, design: .rounded))
                        .foregroundStyle(StreakmapTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 16)
                }

                HStack(spacing: 12) {
                    HeroStatPill(title: "Free", value: "1 habit")
                    HeroStatPill(title: "Premium", value: "Unlimited")
                }
            }

            SectionCard {
                VStack(alignment: .leading, spacing: 14) {
                    featureRow(icon: "sparkles", title: "Premium visual tracking", subtitle: "A calm, elegant heatmap that becomes more rewarding every day.")
                    featureRow(icon: "circle.grid.2x2.fill", title: "Global + habit views", subtitle: "See your full rhythm and each habit in detail.")
                    featureRow(icon: "crown.fill", title: "Premium built in", subtitle: "One habit free, unlimited habits and extras in premium.")
                }
            }

            Button {
                withAnimation(.spring(response: 0.45, dampingFraction: 0.88)) {
                    appState.hasCompletedOnboarding = true
                    appState.persist()
                }
            } label: {
                Text("Start building")
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 18)
                    .background(StreakmapTheme.textPrimary)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
            }
            .buttonStyle(PrimaryButtonStyle())

            Spacer()
        }
        .padding(24)
        .background(StreakmapTheme.background.ignoresSafeArea())
    }

    private func featureRow(icon: String, title: String, subtitle: String) -> some View {
        HStack(alignment: .top, spacing: 14) {
            Image(systemName: icon)
                .foregroundStyle(StreakmapTheme.accent)
                .frame(width: 24, height: 24)
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                Text(subtitle)
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textSecondary)
            }
        }
    }
}
