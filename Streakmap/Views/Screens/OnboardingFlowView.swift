import SwiftUI

struct OnboardingFlowView: View {
    @EnvironmentObject private var appState: AppState
    @State private var page = 0

    var body: some View {
        VStack(spacing: 24) {
            if page == 0 {
                introStep
            } else {
                FirstHabitSetupView()
            }
        }
        .padding(24)
        .background(StreakmapTheme.background.ignoresSafeArea())
    }

    private var introStep: some View {
        VStack(spacing: 24) {
            Spacer()

            ScreenHeader(
                eyebrow: "Step 1",
                title: "This is your streak map",
                subtitle: "Each square is a day. Fill them one by one and your consistency becomes visible."
            )

            MockHeatmapCard()

            VStack(spacing: 12) {
                Button {
                    withAnimation(.spring(response: 0.36, dampingFraction: 0.86)) {
                        page = 1
                    }
                } label: {
                    Text("Create my first habit")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(StreakmapTheme.textPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(PrimaryButtonStyle())

                Text("You’ll be able to unlock premium later if you want to track more habits.")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textSecondary)
                    .multilineTextAlignment(.center)
            }

            Spacer()
        }
    }
}
