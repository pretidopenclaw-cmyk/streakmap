import SwiftUI

struct HabitCard: View {
    let habit: Habit
    let streak: Int

    var body: some View {
        HStack(spacing: 16) {
            ZStack {
                Circle()
                    .fill(Color(hex: habit.colorHex).opacity(0.16))
                    .frame(width: 44, height: 44)
                Image(systemName: habit.icon)
                    .foregroundStyle(Color(hex: habit.colorHex))
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(habit.name)
                    .font(.system(size: 17, weight: .semibold, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textPrimary)
                Text("\(streak) day streak")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundStyle(StreakmapTheme.textSecondary)
            }

            Spacer()

            Image(systemName: "chevron.right")
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(StreakmapTheme.textSecondary.opacity(0.7))
        }
        .padding(18)
        .background(StreakmapTheme.card)
        .clipShape(RoundedRectangle(cornerRadius: 24, style: .continuous))
    }
}
