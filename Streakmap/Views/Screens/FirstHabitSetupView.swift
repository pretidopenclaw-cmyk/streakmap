import SwiftUI

struct FirstHabitSetupView: View {
    @EnvironmentObject private var appState: AppState

    @State private var name = ""
    @State private var icon = HabitIcon.sparkles.rawValue
    @State private var selectedColor: HabitColor = .violet
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 20) {
                ScreenHeader(
                    eyebrow: "Step 2",
                    title: "Create your first habit",
                    subtitle: "Choose one habit to start building your first streak."
                )

                SectionCard {
                    VStack(alignment: .leading, spacing: 14) {
                        TextField("Habit name", text: $name)
                            .textFieldStyle(.plain)
                            .padding(16)
                            .background(StreakmapTheme.background)
                            .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))

                        VStack(alignment: .leading, spacing: 12) {
                            Text("Icon")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                            HStack(spacing: 12) {
                                ZStack {
                                    Circle()
                                        .fill(selectedColor.color.opacity(0.16))
                                        .frame(width: 44, height: 44)
                                    Image(systemName: icon)
                                        .foregroundStyle(selectedColor.color)
                                }
                                Text("Pick the symbol that best matches your habit.")
                                    .font(.system(size: 14, weight: .medium, design: .rounded))
                                    .foregroundStyle(StreakmapTheme.textSecondary)
                            }
                            IconPickerGrid(selectedIcon: $icon, tint: selectedColor.color)
                        }
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Text("Color")
                            .font(.system(size: 20, weight: .semibold, design: .rounded))
                        HStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .fill(selectedColor.color.opacity(0.16))
                                    .frame(width: 44, height: 44)
                                Image(systemName: icon)
                                    .foregroundStyle(selectedColor.color)
                            }
                            Text(selectedColor.displayName)
                                .font(.system(size: 15, weight: .semibold, design: .rounded))
                        }
                        ColorSwatchPicker(selectedColor: $selectedColor)
                    }
                }

                SectionCard {
                    VStack(alignment: .leading, spacing: 14) {
                        Toggle("Daily reminder", isOn: $reminderEnabled)
                            .font(.system(size: 17, weight: .medium, design: .rounded))
                        if reminderEnabled {
                            DatePicker("Reminder time", selection: $reminderTime, displayedComponents: .hourAndMinute)
                                .datePickerStyle(.compact)
                        }
                    }
                }

                Button {
                    let didCreate = appState.addHabit(
                        name: name,
                        icon: icon,
                        color: selectedColor,
                        reminderTime: reminderEnabled ? reminderTime : nil
                    )
                    if didCreate {
                        appState.hasCompletedOnboarding = true
                        HapticService.success()
                    }
                } label: {
                    Text("Start tracking")
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(StreakmapTheme.textPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                }
                .buttonStyle(PrimaryButtonStyle())
                .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                .opacity(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.55 : 1)
            }
            .padding(24)
        }
        .background(StreakmapTheme.background.ignoresSafeArea())
    }
}
