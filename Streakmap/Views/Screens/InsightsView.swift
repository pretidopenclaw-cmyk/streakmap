import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    Text("Insights")
                        .font(.system(size: 32, weight: .bold, design: .rounded))

                    if let habit = appState.selectedHabit {
                        SectionCard {
                            VStack(alignment: .leading, spacing: 16) {
                                Text(habit.name)
                                    .font(.system(size: 22, weight: .semibold, design: .rounded))
                                statRow(title: "Current streak", value: "\(appState.streak(for: habit.id)) days")
                                statRow(title: "Today", value: appState.isHabitCompleted(habit.id, on: .now) ? "Completed" : "Open")
                                statRow(title: "Plan", value: appState.isPremiumUnlocked ? "Premium unlocked" : "Free tier")
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(StreakmapTheme.background)
            .navigationBarHidden(true)
        }
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(StreakmapTheme.textSecondary)
            Spacer()
            Text(value)
                .fontWeight(.semibold)
                .foregroundStyle(StreakmapTheme.textPrimary)
        }
    }
}
