import Foundation
import StoreKit

@MainActor
final class StoreKitService: ObservableObject {
    @Published var products: [Product] = []
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

        do {
            products = try await Product.products(for: PremiumProduct.allCases.map(\.rawValue))
                .sorted { $0.displayPrice < $1.displayPrice }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }

    func purchase(_ product: Product) async {
        purchaseState = .loading

        do {
            let result = try await product.purchase()
            switch result {
            case .success(_):
                purchaseState = .purchased
            case .userCancelled:
                purchaseState = .idle
            case .pending:
                purchaseState = .loading
            @unknown default:
                purchaseState = .failed("Unknown purchase result")
            }
        } catch {
            purchaseState = .failed(error.localizedDescription)
        }
    }
}
