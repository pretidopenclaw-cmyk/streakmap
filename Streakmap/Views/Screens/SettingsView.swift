import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appState: AppState
    @State private var showPremium = false
    @State private var reminderPermissionGranted = false

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
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Plan")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Text(appState.isPremiumUnlocked ? "Premium is active" : "You are currently on the free plan")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textSecondary)

                            if !appState.isPremiumUnlocked {
                                Button("Unlock Premium") {
                                    showPremium = true
                                }
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(StreakmapTheme.textPrimary)
                                .foregroundStyle(.white)
                                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                            }
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notifications")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Text(reminderPermissionGranted ? "Notifications are enabled" : "Enable reminders for your daily habits")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textSecondary)
                            Button(reminderPermissionGranted ? "Granted" : "Enable reminders") {
                                Task {
                                    reminderPermissionGranted = await ReminderService.requestAuthorization()
                                }
                            }
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 14)
                            .background(StreakmapTheme.background)
                            .foregroundStyle(StreakmapTheme.textPrimary)
                            .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Global heatmap")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Text("Choose the accent color used for your full-year overview.")
                                .font(.system(size: 14, weight: .medium, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textSecondary)
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
                            Text("Developer")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
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
                            Text("About")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
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
