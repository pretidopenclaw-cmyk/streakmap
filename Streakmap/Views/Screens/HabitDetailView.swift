import SwiftUI

struct HabitDetailView: View {
    let habit: Habit

    @EnvironmentObject private var appState: AppState
    @State private var selectedDate: Date?
    @State private var showEditHabit = false

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                header

                SectionCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Consistency map")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                        HabitHeatmapView(habit: habit, cellSize: 14) { date in
                            selectedDate = date
                        }
                        .frame(height: 136)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Performance")
                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                        statGrid
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Actions")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        Button {
                            appState.toggleHabit(habit.id, on: .now)
                            HapticService.success()
                        } label: {
                            Text(appState.isHabitCompleted(habit.id, on: .now) ? "Completed today" : "Done today")
                                .font(.system(size: 17, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: habit.colorHex))
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }
            }
            .padding(20)
        }
        .background(StreakmapTheme.background)
        .navigationTitle(habit.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button("Edit") {
                    showEditHabit = true
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
        .sheet(isPresented: $showEditHabit) {
            EditHabitView(habit: habit)
        }
        .sheet(isPresented: Binding(
            get: { selectedDate != nil },
            set: { if !$0 { selectedDate = nil } }
        )) {
            if let selectedDate {
                DayDetailView(habit: habit, date: selectedDate)
            }
        }
    }

    private var header: some View {
        SectionCard {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(Color(hex: habit.colorHex).opacity(0.18))
                        .frame(width: 62, height: 62)
                    Image(systemName: habit.icon)
                        .font(.system(size: 24, weight: .semibold))
                        .foregroundStyle(Color(hex: habit.colorHex))
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(habit.name)
                        .font(.system(size: 26, weight: .bold, design: .rounded))
                    Text("Daily habit")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundStyle(StreakmapTheme.textSecondary)
                }

                Spacer()
            }
        }
    }

    private var statGrid: some View {
        VStack(spacing: 12) {
            statRow(title: "Current streak", value: "\(appState.streak(for: habit.id)) days")
            statRow(title: "Best streak", value: "\(appState.bestStreak(for: habit.id)) days")
            statRow(title: "30-day completion", value: percent(appState.completionRate(for: habit.id, overLast: 30)))
            statRow(title: "90-day completion", value: percent(appState.completionRate(for: habit.id, overLast: 90)))
        }
    }

    private func statRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .foregroundStyle(StreakmapTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 16, weight: .semibold, design: .rounded))
        }
    }

    private func percent(_ value: Double) -> String {
        "\(Int((value * 100).rounded()))%"
    }
}
