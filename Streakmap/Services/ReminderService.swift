import Foundation
import UserNotifications

enum ReminderService {
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleReminder(for habit: Habit) async {
        guard let reminderTime = habit.reminderTime else { return }

        let center = UNUserNotificationCenter.current()
        let granted = try? await center.requestAuthorization(options: [.alert, .sound, .badge])
        guard granted == true else { return }

        let content = UNMutableNotificationContent()
        content.title = habit.name
        content.body = "Keep your streak alive today."
        content.sound = .default

        let components = Calendar.current.dateComponents([.hour, .minute], from: reminderTime)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        let request = UNNotificationRequest(identifier: habit.id.uuidString, content: content, trigger: trigger)

        center.removePendingNotificationRequests(withIdentifiers: [habit.id.uuidString])
        try? await center.add(request)
    }

    static func removeReminder(for habitID: UUID) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [habitID.uuidString])
    }
}
