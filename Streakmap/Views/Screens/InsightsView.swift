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
                        subtitle: "A global dashboard for your overall consistency, not just one habit."
                    )

                    if appState.activeHabits.isEmpty {
                        EmptyStateCard(
                            icon: "chart.line.uptrend.xyaxis",
                            title: "No habits yet",
                            message: "Create your first habit to unlock your global dashboard and consistency trends."
                        )
                    } else {
                        HStack(spacing: 12) {
                            InsightStatCard(title: "Progress streak", value: "\(appState.currentGlobalStreak())d")
                            InsightStatCard(title: "Active habits", value: "\(appState.activeHabits.count)")
                        }

                        HStack(spacing: 12) {
                            InsightStatCard(title: "Days with progress", value: "\(appState.totalCompletedDays(overLast: 30))/30")
                            InsightStatCard(title: "Perfect days", value: "\(appState.perfectDays(overLast: 30))/30")
                        }

                        SectionCard {
                            VStack(alignment: .leading, spacing: 14) {
                                SectionTitleRow(title: "Overview", subtitle: "How your full habit system is behaving right now.")
                                statRow(title: "Today", value: todayStatus)
                                statRow(title: "Days with progress (30d)", value: "\(appState.totalCompletedDays(overLast: 30))")
                                statRow(title: "Perfect days (30d)", value: "\(appState.perfectDays(overLast: 30))")
                            }
                        }

                        SectionCard {
                            VStack(alignment: .leading, spacing: 14) {
                                SectionTitleRow(title: "Best performing habit", subtitle: "Your most consistent habit over the last 30 days.")
                                if let bestHabit = appState.bestPerformingHabit() {
                                    habitSummaryRow(habit: bestHabit, value: percent(appState.completionRate(for: bestHabit.id, overLast: 30)))
                                }
                            }
                        }

                        SectionCard {
                            VStack(alignment: .leading, spacing: 14) {
                                SectionTitleRow(title: "Needs attention", subtitle: "The habit that currently needs the most support.")
                                if let attentionHabit = appState.needsAttentionHabit() {
                                    habitSummaryRow(habit: attentionHabit, value: percent(appState.completionRate(for: attentionHabit.id, overLast: 30)))
                                }
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

    private var todayStatus: String {
        let completed = appState.activeHabits.filter { appState.isHabitCompleted($0.id, on: .now) }.count
        return "\(completed) of \(appState.activeHabits.count) habits completed"
    }

    private func habitSummaryRow(habit: Habit, value: String) -> some View {
        HStack(spacing: 14) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex).opacity(0.16))
                    .frame(width: 40, height: 40)
                Image(systemName: habit.icon)
                    .foregroundStyle(Color(hex: habit.colorHex))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textPrimary)
                Text("Last 30 days")
                    .font(.system(size: 13, weight: .medium, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textSecondary)
            }

            Spacer()

            Text(value)
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundStyle(Color(hex: habit.colorHex))
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
