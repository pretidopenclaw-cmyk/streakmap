import SwiftUI
import StoreKit

struct PremiumView: View {
    @EnvironmentObject private var appState: AppState
    @Environment(\.dismiss) private var dismiss
    @StateObject private var storeKit = StoreKitService()
    @State private var selectedProductID: String = PremiumProduct.yearly.rawValue

    var body: some View {
        NavigationStack {
            ScrollView(showsIndicators: false) {
                VStack(spacing: 24) {
                    header

                    SectionCard {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Why upgrade?")
                                .font(.system(size: 20, weight: .semibold, design: .rounded))
                            FeatureBulletRow(title: "Track unlimited habits", subtitle: "The free version is perfect for one habit. Premium unlocks your full system.")
                            FeatureBulletRow(title: "See more of your life at once", subtitle: "Build multiple streaks and compare your habits over time.")
                            FeatureBulletRow(title: "Unlock the premium layer", subtitle: "Widgets, deeper insights, themes, and yearly recaps are part of the premium experience.")
                        }
                    }

                    HStack(alignment: .top, spacing: 12) {
                        PlanComparisonCard(
                            planName: "Free",
                            features: [
                                "1 habit",
                                "Full core experience",
                                "Basic insights",
                                "Simple reminders"
                            ],
                            isHighlighted: false
                        )

                        PlanComparisonCard(
                            planName: "Premium",
                            features: [
                                "Unlimited habits",
                                "Widgets",
                                "Advanced insights",
                                "Themes and yearly recap"
                            ],
                            isHighlighted: true
                        )
                    }

                    VStack(spacing: 12) {
                        if storeKit.products.isEmpty {
                            ForEach(fallbackProducts, id: \.id) { item in
                                Button {
                                    selectedProductID = item.id
                                } label: {
                                    PricingCard(
                                        title: item.title,
                                        subtitle: item.subtitle,
                                        price: item.price,
                                        isHighlighted: item.id == selectedProductID
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        } else {
                            ForEach(sortedProducts, id: \.id) { (product: StoreKit.Product) in
                                let premiumProduct = PremiumProduct(rawValue: product.id)
                                Button {
                                    selectedProductID = product.id
                                } label: {
                                    PricingCard(
                                        title: premiumProduct?.displayName ?? product.displayName,
                                        subtitle: premiumProduct?.marketingLabel ?? "",
                                        price: product.displayPrice + priceUnit(for: product),
                                        isHighlighted: product.id == selectedProductID
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                        }
                    }

                    Button {
                        Task { await purchaseSelected() }
                    } label: {
                        Group {
                            if storeKit.purchaseState == .loading {
                                ProgressView()
                                    .tint(.white)
                            } else {
                                Text("Continue with Premium")
                            }
                        }
                        .font(.system(size: 17, weight: .semibold, design: .rounded))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 18)
                        .background(StreakmapTheme.textPrimary)
                        .foregroundStyle(.white)
                        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
                    }
                    .disabled(storeKit.purchaseState == .loading)
                    .buttonStyle(PrimaryButtonStyle())

                    if case .failed(let message) = storeKit.purchaseState {
                        Text(message)
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundStyle(.red)
                    }

                    Button("Restore purchases") {
                        Task { await restore() }
                    }
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundStyle(StreakmapTheme.accent)

                    Button("Maybe later") { dismiss() }
                        .foregroundStyle(StreakmapTheme.textSecondary)
                }
                .padding(24)
            }
            .background(StreakmapTheme.background.ignoresSafeArea())
            .task {
                await storeKit.loadProducts()
                // Check if already entitled
                if await storeKit.checkEntitlements() {
                    appState.isPremiumUnlocked = true
                }
            }
        }
    }

    private struct FallbackProduct: Identifiable {
        let id: String
        let title: String
        let subtitle: String
        let price: String
    }

    private var fallbackProducts: [FallbackProduct] {
        [
            FallbackProduct(id: PremiumProduct.yearly.rawValue, title: "Yearly", subtitle: "Best value for long-term consistency", price: "$19.99 / year"),
            FallbackProduct(id: PremiumProduct.monthly.rawValue, title: "Monthly", subtitle: "Flexible access to all premium features", price: "$3.99 / month"),
            FallbackProduct(id: PremiumProduct.lifetime.rawValue, title: "Lifetime", subtitle: "One-time unlock for early supporters", price: "$39.99 once"),
        ]
    }

    private var sortedProducts: [StoreKit.Product] {
        let order: [String: Int] = [
            PremiumProduct.yearly.rawValue: 0,
            PremiumProduct.monthly.rawValue: 1,
            PremiumProduct.lifetime.rawValue: 2
        ]
        return storeKit.products.sorted(by: { (order[$0.id] ?? 9) < (order[$1.id] ?? 9) })
    }

    private func priceUnit(for product: StoreKit.Product) -> String {
        guard let premiumProduct = PremiumProduct(rawValue: product.id) else { return "" }
        switch premiumProduct {
        case .monthly: return " / month"
        case .yearly: return " / year"
        case .lifetime: return " once"
        }
    }

    private func purchaseSelected() async {
        // If products haven't loaded yet, try loading them
        if storeKit.products.isEmpty {
            await storeKit.loadProducts()
        }
        guard let product = storeKit.products.first(where: { $0.id == selectedProductID }) else {
            storeKit.purchaseState = .failed("Could not load products. Check your connection and try again.")
            return
        }
        let success = await storeKit.purchase(product)
        if success {
            appState.isPremiumUnlocked = true
            HapticService.success()
            dismiss()
        }
    }

    private func restore() async {
        let restored = await storeKit.restorePurchases()
        if restored {
            appState.isPremiumUnlocked = true
            HapticService.success()
            dismiss()
        }
    }

    private var header: some View {
        VStack(spacing: 12) {
            Image(systemName: "crown.fill")
                .font(.system(size: 46))
                .foregroundStyle(.yellow)
            Text("Unlock Premium")
                .font(.system(size: 32, weight: .bold, design: .rounded))
            Text("Streakmap is fully usable for one habit. Premium is for people who want to track their full system.")
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundStyle(StreakmapTheme.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            HStack(spacing: 12) {
                HeroStatPill(title: "Free", value: "1 habit")
                HeroStatPill(title: "Premium", value: "Unlimited")
            }
        }
    }
}
