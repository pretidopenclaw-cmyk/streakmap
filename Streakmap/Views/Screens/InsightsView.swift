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
                        Text(habit.name)
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundStyle(StreakmapTheme.textSecondary)

                        HStack(spacing: 12) {
                            InsightStatCard(title: "Current streak", value: "\(appState.streak(for: habit.id))d")
                            InsightStatCard(title: "Best streak", value: "\(appState.bestStreak(for: habit.id))d")
                        }

                        HStack(spacing: 12) {
                            InsightStatCard(title: "30 days", value: percent(appState.completionRate(for: habit.id, overLast: 30)))
                            InsightStatCard(title: "90 days", value: percent(appState.completionRate(for: habit.id, overLast: 90)))
                        }

                        SectionCard {
                            VStack(alignment: .leading, spacing: 14) {
                                Text("Status")
                                    .font(.system(size: 20, weight: .semibold, design: .rounded))
                                statRow(title: "Today", value: appState.isHabitCompleted(habit.id, on: .now) ? "Completed" : "Open")
                                statRow(title: "Plan", value: appState.isPremiumUnlocked ? "Premium unlocked" : "Free tier")
                                statRow(title: "Active habits", value: "\(appState.activeHabits.count)")
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

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}
