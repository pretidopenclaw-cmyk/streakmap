import SwiftUI
import SwiftData

@main
struct StreakmapApp: App {
    @StateObject private var appState = AppState()
    @StateObject private var swiftDataStore = SwiftDataStore()

    var body: some Scene {
        WindowGroup {
            RootAppContainerView()
                .environmentObject(appState)
                .preferredColorScheme(.light)
                .modelContainer(swiftDataStore.container)
                .onChange(of: appState.isPremiumUnlocked) { _ in appState.persist() }
                .onChange(of: appState.hasCompletedOnboarding) { _ in appState.persist() }
                .onChange(of: appState.selectedHabitID) { _ in appState.persist() }
        }
    }
}

struct RootAppContainerView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        RootTabView()
            .task {
                appState.attachModelContext(modelContext)
                appState.loadFromSwiftDataIfAvailable()
            }
    }
}
