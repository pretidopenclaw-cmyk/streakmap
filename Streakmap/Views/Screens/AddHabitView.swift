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

                            TextField("SF Symbol icon", text: $icon)
                                .textFieldStyle(.plain)
                                .padding(16)
                                .background(StreakmapTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Color")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            HStack(spacing: 12) {
                                ForEach(HabitColor.allCases) { habitColor in
                                    Button {
                                        selectedColor = habitColor
                                    } label: {
                                        Circle()
                                            .fill(habitColor.color)
                                            .frame(width: 34, height: 34)
                                            .overlay {
                                                if selectedColor == habitColor {
                                                    Circle().stroke(.white, lineWidth: 3)
                                                        .padding(4)
                                                }
                                            }
                                    }
                                    .buttonStyle(.plain)
                                }
                            }
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
