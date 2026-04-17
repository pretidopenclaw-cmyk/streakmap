import SwiftUI

struct EditHabitView: View {
    let habit: Habit

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    @State private var name: String
    @State private var icon: String
    @State private var selectedColor: HabitColor
    @State private var reminderEnabled: Bool
    @State private var reminderTime: Date

    init(habit: Habit) {
        self.habit = habit
        _name = State(initialValue: habit.name)
        _icon = State(initialValue: habit.icon)
        _selectedColor = State(initialValue: HabitColor.allCases.first(where: { $0.hex == habit.colorHex }) ?? .violet)
        _reminderEnabled = State(initialValue: habit.reminderTime != nil)
        _reminderTime = State(initialValue: habit.reminderTime ?? Date())
    }

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Edit habit")
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
                                                    Circle()
                                                        .stroke(.white, lineWidth: 3)
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

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Danger zone")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            Button(role: .destructive) {
                                appState.archiveHabit(habit.id)
                                dismiss()
                            } label: {
                                Text("Archive habit")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                            }
                        }
                    }
                }
                .padding(20)
            }
            .background(StreakmapTheme.background)
            .navigationTitle("Edit habit")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.updateHabit(
                            habit.id,
                            name: name,
                            icon: icon,
                            color: selectedColor,
                            reminderTime: reminderEnabled ? reminderTime : nil
                        )
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
        }
    }
}
