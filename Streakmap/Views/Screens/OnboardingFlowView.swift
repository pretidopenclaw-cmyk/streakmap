import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var page = 0
    @State private var showPremium = false

    var body: some View {
        VStack(spacing: 24) {
            TabView(selection: $page) {
                onboardingPage(
                    icon: "square.grid.3x3.fill",
                    title: "See your consistency",
                    subtitle: "Streakmap turns your habits into a beautiful visual rhythm.",
                    tag: 0
                )

                onboardingPage(
                    icon: "chart.bar.fill",
                    title: "Track globally and individually",
                    subtitle: "Use the global heatmap for momentum and habit heatmaps for precision.",
                    tag: 1
                )

                onboardingPage(
                    icon: "crown.fill",
                    title: "Premium from day one",
                    subtitle: "Start free with one habit, unlock the full system when you're ready.",
                    tag: 2
                )
            }
            .tabViewStyle(.page(indexDisplayMode: .always))
            .frame(maxHeight: 440)

            VStack(spacing: 12) {
                Button {
                    if page < 2 {
                        withAnimation(.spring(response: 0.35, dampingFraction: 0.86)) {
                            page += 1
                        }
                    } else {
                        appState.hasCompletedOnboarding = true
                    }
                } label: {
                    Text(page < 2 ? "Continue" : "Enter Streakmap")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(StreakmapTheme.textPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(PrimaryButtonStyle())

                Button("See Premium") {
                    showPremium = true
                }
                .foregroundStyle(StreakmapTheme.textSecondary)
            }
        }
        .padding(24)
        .background(StreakmapTheme.background.ignoresSafeArea())
        .sheet(isPresented: $showPremium) {
            PremiumView()
        }
    }

    private func onboardingPage(icon: String, title: String, subtitle: String, tag: Int) -> some View {
        VStack(spacing: 22) {
            Spacer()
            Image(systemName: icon)
                .font(.system(size: 54, weight: .semibold))
                .foregroundStyle(icon == "crown.fill" ? .yellow : StreakmapTheme.accent)

            VStack(spacing: 10) {
                Text(title)
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .multilineTextAlignment(.center)
                Text(subtitle)
                    .font(.system(size: 17, weight: .medium, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 12)
            }

            HStack(spacing: 12) {
                HeroStatPill(title: "Free", value: "1 habit")
                HeroStatPill(title: "Premium", value: "Unlimited")
            }
            Spacer()
        }
        .tag(tag)
    }
}
