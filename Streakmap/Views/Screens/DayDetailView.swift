import SwiftUI

struct DayDetailView: View {
    let habit: Habit
    let date: Date

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @State private var note: String = ""

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text(formattedDate)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text(habit.name)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textSecondary)

                            Button {
                                appState.toggleHabit(habit.id, on: date)
                                HapticService.tap()
                            } label: {
                                HStack {
                                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                                    Text(isCompleted ? "Completed" : "Mark as done")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color(hex: habit.colorHex).opacity(isCompleted ? 1 : 0.14))
                                .foregroundStyle(isCompleted ? Color.white : Color(hex: habit.colorHex))
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                            }
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Notes")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            TextEditor(text: $note)
                                .frame(minHeight: 140)
                                .scrollContentBackground(.hidden)
                                .padding(12)
                                .background(StreakmapTheme.background)
                                .clipShape(RoundedRectangle(cornerRadius: 18, style: .continuous))
                        }
                    }
                }
                .padding(20)
            }
            .background(StreakmapTheme.background)
            .navigationTitle("Day")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        appState.updateNote(for: habit.id, on: date, note: note)
                        dismiss()
                    }
                    .fontWeight(.semibold)
                }
            }
            .onAppear {
                note = appState.note(for: habit.id, on: date)
            }
        }
    }

    private var isCompleted: Bool {
        appState.isHabitCompleted(habit.id, on: date)
    }

    private var formattedDate: String {
        date.formatted(date: .complete, time: .omitted)
    }
}
