import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showPremium = false
    @State private var reminderPermissionGranted = false
    @State private var isRestoring = false
    @State private var restoreMessage: String?

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 16) {
                    ScreenHeader(
                        eyebrow: "Control center",
                        title: "Settings",
                        subtitle: "Manage plan, reminders, and product preferences."
                    )

                    SectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            HStack {
                                SectionTitleRow(title: "Plan", subtitle: appState.isPremiumUnlocked ? "Premium is active on this device." : "You are currently using the free plan.")
                                Spacer()
                                StatusBadge(text: appState.isPremiumUnlocked ? "Premium" : "Free", tint: appState.isPremiumUnlocked ? StreakmapTheme.accent : StreakmapTheme.textSecondary)
                            }

                            if !appState.isPremiumUnlocked {
                                SettingsActionRow(
                                    title: "Upgrade",
                                    subtitle: "Unlock unlimited habits, widgets, advanced insights, and premium visuals.",
                                    actionTitle: "Unlock Premium",
                                    isPrimary: true
                                ) {
                                    showPremium = true
                                }

                                Button {
                                    Task { await restorePurchases() }
                                } label: {
                                    HStack {
                                        Text("Restore purchases")
                                            .font(.system(size: 15, weight: .medium, design: .rounded))
                                            .foregroundStyle(StreakmapTheme.accent)
                                        Spacer()
                                        if isRestoring {
                                            ProgressView()
                                        }
                                    }
                                }
                                .disabled(isRestoring)

                                if let restoreMessage {
                                    Text(restoreMessage)
                                        .font(.system(size: 13, weight: .medium, design: .rounded))
                                        .foregroundStyle(StreakmapTheme.textSecondary)
                                }
                            }
                        }
                    }

                    SectionCard {
                        SettingsActionRow(
                            title: "Notifications",
                            subtitle: reminderPermissionGranted ? "Notifications are enabled for your daily routine." : "Enable reminders to make your streaks easier to keep.",
                            actionTitle: reminderPermissionGranted ? "Granted" : "Enable reminders",
                            isPrimary: false
                        ) {
                            Task {
                                reminderPermissionGranted = await ReminderService.requestAuthorization()
                            }
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitleRow(title: "Global heatmap", subtitle: "Choose the accent color used for your full-year overview.")
                            ColorSwatchPicker(selectedColor: Binding(
                                get: {
                                    HabitColor.allCases.first(where: { $0.hex == appState.globalHeatmapColorHex }) ?? .violet
                                },
                                set: { appState.updateGlobalHeatmapColor($0) }
                            ))
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitleRow(title: "Developer", subtitle: "Useful controls for local testing during MVP iteration.")
                            Toggle("Premium unlock for testing", isOn: Binding(
                                get: { appState.isPremiumUnlocked },
                                set: { newValue in
                                    appState.isPremiumUnlocked = newValue
                                    appState.persist()
                                }
                            ))
                            .font(.system(size: 16, weight: .medium, design: .rounded))
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            SectionTitleRow(title: "About", subtitle: "A lightweight streak product built around beautiful yearly heatmaps.")
                            infoRow(label: "App", value: "Streakmap")
                            infoRow(label: "Version", value: "0.1 MVP")
                            infoRow(label: "Focus", value: "Beautiful habit heatmaps")
                        }
                    }
                }
                .padding(20)
            }
            .background(StreakmapTheme.background)
            .navigationBarHidden(true)
            .sheet(isPresented: $showPremium) {
                PremiumView()
            }
        }
    }

    #if DEBUG
    private func generateDemoData() {
        let calendar = Calendar.current
        let today = calendar.startOfDay(for: .now)

        var newEntries: [HabitEntry] = []

        for habit in appState.activeHabits {
            for dayOffset in 0..<365 {
                guard let date = calendar.date(byAdding: .day, value: -dayOffset, to: today) else { continue }

                // ~85% completion, with occasional rough weeks (~45%)
                let weekOfYear = calendar.component(.weekOfYear, from: date)
                let isBadWeek = (weekOfYear % 7 == 3)
                let chance: Double = isBadWeek ? 0.45 : 0.88

                let completed = Double.random(in: 0...1) < chance

                newEntries.append(HabitEntry(
                    habitID: habit.id,
                    date: date,
                    isCompleted: completed
                ))
            }
        }

        appState.entries = newEntries
        appState.persist()
    }
    #endif

    private func restorePurchases() async {
        isRestoring = true
        restoreMessage = nil
        let service = StoreKitService()
        let restored = await service.restorePurchases()
        isRestoring = false
        if restored {
            appState.isPremiumUnlocked = true
            appState.persist()
            HapticService.success()
            restoreMessage = "Premium restored!"
        } else {
            restoreMessage = "No previous purchase found."
        }
    }

    private func infoRow(label: String, value: String) -> some View {
        HStack {
            Text(label)
                .foregroundStyle(StreakmapTheme.textSecondary)
            Spacer()
            Text(value)
                .font(.system(size: 15, weight: .semibold, design: .rounded))
                .foregroundStyle(StreakmapTheme.textPrimary)
        }
    }
}
