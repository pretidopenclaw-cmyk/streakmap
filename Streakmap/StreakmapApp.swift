import SwiftUI
import SwiftData

@main
struct StreakmapApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var swiftDataStore = SwiftDataStore()

    var body: some Scene {
        WindowGroup {
            RootTabView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .modelContainer(swiftDataStore.container)
                .onChange(of: appState.isPremiumUnlocked) { _ in appState.persist() }
                .onChange(of: appState.hasCompletedOnboarding) { _ in appState.persist() }
                .onChange(of: appState.selectedHabitID) { _ in appState.persist() }
        }
    }
}
