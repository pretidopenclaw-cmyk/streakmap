import Foundation
import StoreKit

@MainActor
final class StoreKitService: ObservableObject {
    @Published var products: [StoreKit.Product] = []
    @Published var isLoading = false
    @Published var purchaseState: PurchaseState = .idle

    enum PurchaseState: Equatable {
        case idle
        case loading
        case purchased
        case failed(String)
    }

    func loadProducts() async {
        isLoading = true
        defer { isLoading = false }

        let ids = Set(PremiumProduct.allCases.map(\.rawValue))
        print("[StoreKit] Requesting products for IDs: \(ids)")

        do {
            let fetched = try await StoreKit.Product.products(for: ids)
            print("[StoreKit] Loaded \(fetched.count) products: \(fetched.map(\.id))")
            products = fetched.sorted(by: { $0.price < $1.price })
        } catch {
            print("[StoreKit] Error loading products: \(error)")
            purchaseState = .failed(error.localizedDescription)
        }
    }

    func purchase(_ product: StoreKit.Product) async -> Bool {
        purchaseState = .loading

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if let transaction = try? verification.payloadValue {
                    await transaction.finish()
                    purchaseState = .purchased
                    return true
                } else {
                    purchaseState = .failed("Could not verify purchase.")
                    return false
                }
            case .userCancelled:
                purchaseState = .idle
                return false
            case .pending:
                purchaseState = .idle
                return false
            @unknown default:
                purchaseState = .failed("Unknown purchase result.")
                return false
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
            return false
        }
    }

    func restorePurchases() async -> Bool {
        do {
            try await AppStore.sync()
        } catch {
            purchaseState = .failed(error.localizedDescription)
            return false
        }
        return await checkEntitlements()
    }

    func checkEntitlements() async -> Bool {
        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue,
               PremiumProduct.allCases.map(\.rawValue).contains(transaction.productID) {
                return true
            }
        }
        return false
    }
}
