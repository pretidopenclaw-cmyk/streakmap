import SwiftUI

struct InsightsView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(
                        eyebrow: "Patterns",
                        title: "Insights",
                        subtitle: "Understand how your consistency evolves over time."
                    )

                    if let habit = appState.selectedHabit {
                        SectionCard {
                            VStack(alignment: .leading, spacing: 14) {
                                HStack(alignment: .center) {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text(habit.name)
                                            .font(.system(size: 24, weight: .bold, design: .rounded))
                                        Text("Focused insight view for your currently selected habit")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(StreakmapTheme.textSecondary)
                                    }
                                    Spacer()
                                    StatusBadge(
                                        text: appState.isHabitCompleted(habit.id, on: .now) ? "Completed" : "Open",
                                        tint: appState.isHabitCompleted(habit.id, on: .now) ? Color(hex: habit.colorHex) : StreakmapTheme.textSecondary
                                    )
                                }
                            }
                        }

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
                                SectionTitleRow(title: "Status", subtitle: "A quick read on your current habit context.")
                                statRow(title: "Today", value: appState.isHabitCompleted(habit.id, on: .now) ? "Completed" : "Open")
                                statRow(title: "Plan", value: appState.isPremiumUnlocked ? "Premium unlocked" : "Free tier")
                                statRow(title: "Active habits", value: "\(appState.activeHabits.count)")
                            }
                        }
                    } else {
                        EmptyStateCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "No habit selected",
                            message: "Open a habit first to see focused insights and performance details."
                        )
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
