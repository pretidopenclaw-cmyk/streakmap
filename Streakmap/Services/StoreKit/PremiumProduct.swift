import Foundation

enum PremiumProduct: String, CaseIterable {
    case monthly = "streakmap.premium.monthly"
    case yearly = "streakmap.premium.yearly"
    case lifetime = "streakmap.premium.lifetime"

    var displayName: String {
        switch self {
        case .monthly: return "Monthly"
        case .yearly: return "Yearly"
        case .lifetime: return "Lifetime"
        }
    }

    var marketingLabel: String {
        switch self {
        case .monthly: return "Flexible"
        case .yearly: return "Best value"
        case .lifetime: return "One-time unlock"
        }
    }
}
