import SwiftUI

struct PremiumView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKit = StoreKitService()

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header

                    SectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Why upgrade?")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            FeatureBulletRow(title: "Track unlimited habits", subtitle: "The free version is perfect for one habit. Premium unlocks your full system.")
                            FeatureBulletRow(title: "See more of your life at once", subtitle: "Build multiple streaks and compare your habits over time.")
                            FeatureBulletRow(title: "Unlock the premium layer", subtitle: "Widgets, deeper insights, themes, and yearly recaps are part of the premium experience.")
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        PlanComparisonCard(
                            planName: "Free",
                            features: [
                                "1 habit",
                                "Full core experience",
                                "Basic insights",
                                "Simple reminders"
                            ],
                            isHighlighted: false
                        )

                        PlanComparisonCard(
                            planName: "Premium",
                            features: [
                                "Unlimited habits",
                                "Widgets",
                                "Advanced insights",
                                "Themes and yearly recap"
                            ],
                            isHighlighted: true
                        )
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
                    .buttonStyle(PrimaryButtonStyle())

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

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 46))
                .foregroundStyle(.yellow)
            Text("Unlock Premium")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text("Streakmap is fully usable for one habit. Premium is for people who want to track their full system.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            HStack(spacing: 12) {
                HeroStatPill(title: "Free", value: "1 habit")
                HeroStatPill(title: "Premium", value: "Unlimited")
            }
        }
    }
}
