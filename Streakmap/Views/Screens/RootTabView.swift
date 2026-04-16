import SwiftUI

struct RootTabView: View {
    @EnvironmentObject private var appState: AppState

    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                TabView {
                    HomeView()
                        .tabItem {
                            Label("Home", systemImage: "square.grid.3x3.fill")
                        }

                    HabitsView()
                        .tabItem {
                            Label("Habits", systemImage: "checklist")
                        }

                    InsightsView()
                        .tabItem {
                            Label("Insights", systemImage: "chart.bar.fill")
                        }

                    SettingsView()
                        .tabItem {
                            Label("Settings", systemImage: "gearshape.fill")
                        }
                }
                .tint(StreakmapTheme.accent)
            } else {
                OnboardingView()
            }
        }
    }
}
