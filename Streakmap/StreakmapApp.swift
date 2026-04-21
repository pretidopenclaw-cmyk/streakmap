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
                .modelContainer(swiftDataStore.container)
                .onChange(of: appState.isPremiumUnlocked) { _ in appState.persist() }
                .onChange(of: appState.hasCompletedOnboarding) { _ in appState.persist() }
                .onChange(of: appState.selectedHabitID) { _ in appState.persist() }
                .onOpenURL { url in
                    guard url.scheme == "streakmap",
                          url.host == "habit",
                          let idString = url.pathComponents.last,
                          let habitID = UUID(uuidString: idString) else { return }
                    appState.selectHabit(habitID)
                }
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
                // Verify entitlements on launch
                let service = StoreKitService()
                let entitled = await service.checkEntitlements()
                if entitled != appState.isPremiumUnlocked {
                    appState.isPremiumUnlocked = entitled
                    appState.persist()
                }
            }
    }
}
