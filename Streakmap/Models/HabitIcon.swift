import Foundation

enum HabitIcon: String, CaseIterable, Identifiable {
    case brain = "brain.head.profile"
    case book = "book.closed"
    case walk = "figure.walk"
    case drop = "drop.fill"
    case moon = "moon.stars.fill"
    case heart = "heart.fill"
    case leaf = "leaf.fill"
    case bolt = "bolt.fill"
    case sparkles = "sparkles"
    case sun = "sun.max.fill"
    case flame = "flame.fill"
    case fork = "fork.knife"

    var id: String { rawValue }
}
