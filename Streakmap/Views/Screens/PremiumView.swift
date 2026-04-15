import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Spacer()

                VStack(spacing: 12) {
                    Image(systemName: "crown.fill")
                        .font(.system(size: 46))
                        .foregroundStyle(.yellow)
                    Text("Unlock Premium")
                        .font(.system(size: 32, weight: .bold, design: .rounded))
                    Text("Track unlimited habits, unlock premium palettes, widgets, and deeper insights.")
                        .font(.system(size: 16, weight: .medium, design: .rounded))
                        .foregroundStyle(StreakmapTheme.textSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 24)
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 14) {
                        premiumRow("Unlimited habits")
                        premiumRow("Premium themes")
                        premiumRow("Widgets")
                        premiumRow("Advanced insights")
                        premiumRow("Yearly recap")
                    }
                }

                Button {
                    appState.isPremiumUnlocked = true
                    HapticService.success()
                    dismiss()
                } label: {
                    Text("Continue with Premium")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(StreakmapTheme.textPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }

                Button("Maybe later") { dismiss() }
                    .foregroundStyle(StreakmapTheme.textSecondary)

                Spacer()
            }
            .padding(24)
            .background(StreakmapTheme.background.ignoresSafeArea())
        }
    }

    private func premiumRow(_ text: String) -> some View {
        HStack {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(StreakmapTheme.accent)
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
            Spacer()
        }
    }
}
