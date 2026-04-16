import SwiftUI

@main
struct StreakmapApp: App {
    @StateObject private var appState = AppState()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .onChange(of: appState.isPremiumUnlocked) { _ in appState.persist() }
                .onChange(of: appState.hasCompletedOnboarding) { _ in appState.persist() }
                .onChange(of: appState.selectedHabitID) { _ in appState.persist() }
        }
    }
}
