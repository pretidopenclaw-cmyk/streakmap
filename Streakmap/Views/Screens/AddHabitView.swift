import SwiftUI

struct AddHabitView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name = ""
    @State private var icon = "sparkles"
    @State private var selectedColor: HabitColor = .violet
    @State private var reminderEnabled = false
    @State private var reminderTime = Date()
    @State private var showPremiumSheet = false

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("New habit")
                                .font(.system(size: 24, weight: .semibold, design: .rounded))
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
                                    Text("Choose the symbol that best matches this habit.")
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
                }
                .padding(20)
            }
            .background(StreakmapTheme.background)
            .navigationTitle("Add habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") { saveHabit() }
                        .fontWeight(.semibold)
                }
            }
            .sheet(isPresented: $showPremiumSheet) {
                PremiumView()
            }
        }
    }

    private func saveHabit() {
        let reminder = reminderEnabled ? reminderTime : nil
        let success = appState.addHabit(name: name, icon: icon.isEmpty ? "sparkles" : icon, color: selectedColor, reminderTime: reminder)

        if success {
            HapticService.success()
            dismiss()
        } else {
            showPremiumSheet = true
        }
    }
}
