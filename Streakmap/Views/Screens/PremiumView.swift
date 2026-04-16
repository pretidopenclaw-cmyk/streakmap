import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKit = StoreKitService()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
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

                    VStack(spacing: 12) {
                        PricingCard(title: "Yearly", subtitle: "Best value for long-term consistency", price: "$19.99 / year", isHighlighted: true)
                        PricingCard(title: "Monthly", subtitle: "Flexible access to all premium features", price: "$3.99 / month", isHighlighted: false)
                        PricingCard(title: "Lifetime", subtitle: "One-time unlock for early supporters", price: "$39.99 once", isHighlighted: false)
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

                    if case .failed(let message) = storeKit.purchaseState {
                        Text(message)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.red)
                    }

                    Button("Maybe later") { dismiss() }
                        .foregroundStyle(StreakmapTheme.textSecondary)
                }
                .padding(24)
            }
            .background(StreakmapTheme.background.ignoresSafeArea())
            .task {
                await storeKit.loadProducts()
            }
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
