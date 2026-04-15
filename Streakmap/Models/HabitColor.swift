import SwiftUI

enum HabitColor: String, CaseIterable, Identifiable {
    case violet
    case sky
    case mint
    case coral
    case amber
    case rose

    var id: String { rawValue }

    var hex: String {
        switch self {
        case .violet: return "#7C3AED"
        case .sky: return "#0EA5E9"
        case .mint: return "#10B981"
        case .coral: return "#F97316"
        case .amber: return "#F59E0B"
        case .rose: return "#F43F5E"
        }
    }

    var color: Color { Color(hex: hex) }

    var displayName: String {
        rawValue.capitalized
    }
}
