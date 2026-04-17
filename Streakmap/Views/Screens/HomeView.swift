import SwiftUI

struct HomeView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showAddHabit = false
    @State private var showDayDetail = false

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
                                .background(StreakmapTheme.textPrimary)
                                .clipShape(Circle())
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 18) {
                            HStack(alignment: .top) {
                                VStack(alignment: .leading, spacing: 6) {
                                    Text("Year at a glance")
                                        .font(.system(size: 22, weight: .semibold, design: .rounded))
                                    Text(todaySummary)
                                        .font(.system(size: 14, weight: .medium, design: .rounded))
                                        .foregroundStyle(StreakmapTheme.textSecondary)
                                }
                                Spacer()
                                HeroStatPill(title: "Today", value: globalScore)
                            }

                            HeatmapLegend(accent: Color(hex: appState.globalHeatmapColorHex), mode: .gradient)

                            GlobalHeatmapView { date in
                                appState.selectedDate = date
                                showDayDetail = true
                            }
                            .frame(height: 140)

                            VStack(alignment: .leading, spacing: 10) {
                                Text("Year color")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                ColorSwatchPicker(selectedColor: Binding(
                                    get: {
                                        HabitColor.allCases.first(where: { $0.hex == appState.globalHeatmapColorHex }) ?? .violet
                                    },
                                    set: { appState.updateGlobalHeatmapColor($0) }
                                ))
                            }
                        }
                    }

                    if !appState.activeHabits.isEmpty {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Your habits")
                                .font(.system(size: 22, weight: .semibold, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textPrimary)

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
                                                showDayDetail = true
                                            }
                                            .frame(height: 140)

                                            Button {
                                                appState.selectedHabitID = habit.id
                                                appState.toggleHabit(habit.id, on: .now)
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
            .sheet(isPresented: $showDayDetail) {
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
