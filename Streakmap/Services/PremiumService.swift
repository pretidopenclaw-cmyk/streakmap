import Foundation

final class PremiumService: ObservableObject {
    @Published var isPremiumUnlocked: Bool = false

    func unlockPremium() {
        isPremiumUnlocked = true
    }
}
