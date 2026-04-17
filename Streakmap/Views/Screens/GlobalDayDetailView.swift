import SwiftUI

struct GlobalDayDetailView: View {
    let date: Date

    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {
                    SectionCard {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(date.formatted(date: .complete, time: .omitted))
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                            Text(daySummary)
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundStyle(StreakmapTheme.textSecondary)
                        }
                    }

                    SectionCard {
                        VStack(alignment: .leading, spacing: 14) {
                            Text("Habits")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))

                            ForEach(appState.habitStatusRows(for: date)) { row in
                                Button {
                                    appState.toggleHabit(row.habit.id, on: date)
                                    HapticService.tap()
                                } label: {
                                    HStack(spacing: 14) {
                                        ZStack {
                                            Circle()
                                                .fill(Color(hex: row.habit.colorHex).opacity(0.14))
                                                .frame(width: 40, height: 40)
                                            Image(systemName: row.habit.icon)
                                                .foregroundStyle(Color(hex: row.habit.colorHex))
                                        }

                                        VStack(alignment: .leading, spacing: 4) {
                                            Text(row.habit.name)
                                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                                .foregroundStyle(StreakmapTheme.textPrimary)
                                            Text(row.isCompleted ? "Completed" : "Not completed")
                                                .font(.system(size: 13, weight: .medium, design: .rounded))
                                                .foregroundStyle(StreakmapTheme.textSecondary)
                                        }

                                        Spacer()

                                        Image(systemName: row.isCompleted ? "checkmark.circle.fill" : "circle")
                                            .font(.system(size: 22, weight: .semibold))
                                            .foregroundStyle(row.isCompleted ? Color(hex: row.habit.colorHex) : StreakmapTheme.textSecondary)
                                    }
                                    .padding(.vertical, 4)
                                }
                                .buttonStyle(.plain)
                            }
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
                    Button("Done") { dismiss() }
                        .fontWeight(.semibold)
                }
            }
        }
    }

    private var daySummary: String {
        let rows = appState.habitStatusRows(for: date)
        let completed = rows.filter(\.isCompleted).count
        return "\(completed) of \(rows.count) habits completed"
    }
}
