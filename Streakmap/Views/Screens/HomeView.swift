import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showAddHabit = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Streakmap")
                                .font(.system(size: 34, weight: .bold, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textPrimary)
                            Text("See your consistency, beautifully.")
                                .font(.system(size: 16, weight: .medium, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textSecondary)
                        }
                        Spacer()
                        Button {
                            showAddHabit = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(StreakmapTheme.textPrimary)
                                .clipShape(Circle())
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Year at a glance")
                                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    Text(todaySummary)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(StreakmapTheme.textSecondary)
                                }
                                Spacer()
                                Text(globalScore)
                                    .font(.system(size: 28, weight: .bold, design: .rounded))
                            }

                            GlobalHeatmapView()
                                .frame(height: 140)
                        }
                    }

                    if let selectedHabit = appState.selectedHabit {
                        SectionCard {
                            VStack(alignment: .leading, spacing: 16) {
                                HStack {
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text(selectedHabit.name)
                                            .font(.system(size: 22, weight: .semibold, design: .rounded))
                                        Text("Focused habit")
                                            .font(.system(size: 14, weight: .medium, design: .rounded))
                                            .foregroundStyle(StreakmapTheme.textSecondary)
                                    }
                                    Spacer()
                                    Text("\(appState.streak(for: selectedHabit.id))d")
                                        .font(.system(size: 26, weight: .bold, design: .rounded))
                                        .foregroundStyle(Color(hex: selectedHabit.colorHex))
                                }

                                HabitHeatmapView(habit: selectedHabit)
                                    .frame(height: 118)

                                Button {
                                    appState.toggleHabit(selectedHabit.id, on: .now)
                                } label: {
                                    Text(appState.isHabitCompleted(selectedHabit.id, on: .now) ? "Completed today" : "Done today")
                                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 16)
                                        .background(Color(hex: selectedHabit.colorHex))
                                        .foregroundStyle(Color.white)
                                        .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                }
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(StreakmapTheme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showAddHabit) {
                AddHabitView()
            }
        }
    }

    private var globalScore: String {
        let completed = appState.activeHabits.filter { appState.isHabitCompleted($0.id, on: .now) }.count
        let total = max(appState.activeHabits.count, 1)
        return "\(completed)/\(total)"
    }

    private var todaySummary: String {
        let rate = Int((appState.completionRate(for: .now) * 100).rounded())
        return "Today is at \(rate)% completion"
    }
}
