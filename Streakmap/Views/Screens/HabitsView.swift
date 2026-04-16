import SwiftUI

struct HabitsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showAddHabit = false
    @State private var showPremium = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    HStack(alignment: .top) {
                        ScreenHeader(
                            eyebrow: "Collection",
                            title: "Your habits",
                            subtitle: "Each habit gets its own beautiful consistency map."
                        )
                        Spacer()
                        Button {
                            if appState.isPremiumUnlocked || appState.activeHabits.count < 1 {
                                showAddHabit = true
                            } else {
                                showPremium = true
                            }
                        } label: {
                            Image(systemName: "plus")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundStyle(.white)
                                .frame(width: 42, height: 42)
                                .background(StreakmapTheme.textPrimary)
                                .clipShape(Circle())
                        }
                    }

                    if appState.activeHabits.isEmpty {
                        EmptyStateCard(
                            icon: "sparkles",
                            title: "No habits yet",
                            message: "Create your first habit to start building your heatmap."
                        )
                    } else {
                        ForEach(appState.activeHabits) { habit in
                            NavigationLink {
                                HabitDetailView(habit: habit)
                            } label: {
                                HabitCard(habit: habit, streak: appState.streak(for: habit.id))
                            }
                            .simultaneousGesture(TapGesture().onEnded {
                                appState.selectedHabitID = habit.id
                            })
                            .buttonStyle(.plain)
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(appState.isPremiumUnlocked ? "Premium unlocked" : "Premium")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Text(appState.isPremiumUnlocked ? "Unlimited habits and premium features are active." : "Unlock unlimited habits, premium palettes, widgets, and deeper insights.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textSecondary)
                            if !appState.isPremiumUnlocked {
                                Button("Unlock Premium") { showPremium = true }
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                    .background(StreakmapTheme.textPrimary)
                                    .foregroundStyle(Color.white)
                                    .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
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
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
        }
    }
}
