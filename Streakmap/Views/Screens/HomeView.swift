import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showAddHabit = false
    @State private var showGlobalDayDetail = false
    @State private var showHabitDayDetail = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    HStack(alignment: .top) {
                        ScreenHeader(
                            eyebrow: "Daily rhythm",
                            title: "Streakmap",
                            subtitle: "See your consistency, beautifully."
                        )
                        Spacer()
                        Button {
                            showAddHabit = true
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(StreakmapTheme.accent)
                                .clipShape(Circle())
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Last 365 days")
                                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    Text("A rolling year of your habit consistency, including today")
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(StreakmapTheme.textSecondary)
                                }
                                Spacer()
                                HeroStatPill(title: "Today", value: globalScore)
                            }

                            GlobalHeatmapView(cellSize: 12) { date in
                                appState.selectedDate = date
                                showGlobalDayDetail = true
                            }
                            .frame(height: 150)
                        }
                    }

                    if !appState.activeHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            SectionTitleRow(title: "Your habits", subtitle: "Track each habit individually while keeping the yearly view in sight.")

                            ForEach(appState.activeHabits) { habit in
                                NavigationLink {
                                    HabitDetailView(habit: habit)
                                } label: {
                                    SectionCard {
                                        VStack(alignment: .leading, spacing: 16) {
                                            HStack {
                                                VStack(alignment: .leading, spacing: 4) {
                                                    Text(habit.name)
                                                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                                                    Text(appState.isHabitCompleted(habit.id, on: .now) ? "Completed today" : "Open today")
                                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                                        .foregroundStyle(StreakmapTheme.textSecondary)
                                                }
                                                Spacer()
                                                Text("\(appState.streak(for: habit.id))d")
                                                    .font(.system(size: 26, weight: .bold, design: .rounded))
                                                    .foregroundStyle(Color(hex: habit.colorHex))
                                            }

                                            HabitHeatmapView(habit: habit, cellSize: 14) { date in
                                                appState.selectedHabitID = habit.id
                                                appState.selectedDate = date
                                                showHabitDayDetail = true
                                            }
                                            .frame(height: 140)

                                            Button {
                                                withAnimation(.spring(response: 0.28, dampingFraction: 0.82)) {
                                                    appState.selectedHabitID = habit.id
                                                    appState.toggleHabit(habit.id, on: .now)
                                                }
                                                HapticService.success()
                                            } label: {
                                                Text(appState.isHabitCompleted(habit.id, on: .now) ? "Completed today" : "Done today")
                                                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                                                    .frame(maxWidth: .infinity)
                                                    .padding(.vertical, 16)
                                                    .background(Color(hex: habit.colorHex))
                                                    .foregroundStyle(Color.white)
                                                    .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                                            }
                                            .buttonStyle(PrimaryButtonStyle())
                                        }
                                    }
                                }
                                .buttonStyle(.plain)
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
            .sheet(isPresented: $showGlobalDayDetail) {
                if let selectedDate = appState.selectedDate {
                    GlobalDayDetailView(date: selectedDate)
                }
            }
            .sheet(isPresented: $showHabitDayDetail) {
                if let habit = appState.selectedHabit, let selectedDate = appState.selectedDate {
                    DayDetailView(habit: habit, date: selectedDate)
                }
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
