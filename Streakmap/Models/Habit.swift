import Foundation
import SwiftUI

struct Habit: Identifiable, Hashable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var colorHex: String
    var createdAt: Date
    var reminderTime: Date?
    var isArchived: Bool

    init(
        id: UUID = UUID(),
        name: String,
        icon: String,
        colorHex: String,
        createdAt: Date = .now,
        reminderTime: Date? = nil,
        isArchived: Bool = false
    ) {
        self.id = id
        self.name = name
        self.icon = icon
        self.colorHex = colorHex
        self.createdAt = createdAt
        self.reminderTime = reminderTime
        self.isArchived = isArchived
    }
}
