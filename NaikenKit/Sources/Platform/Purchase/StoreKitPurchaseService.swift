import Domain
import Foundation
import StoreKit

/// StoreKit の `Product` や `Transaction` を返さないのは、StoreKit の型を Domain に持ち込まないため
public final class StoreKitPurchaseService: PurchaseService {
    enum Failure: Error {
        case productNotFound(String)
    }

    public init() {}

    public var updates: AsyncStream<Set<String>> {
        return AsyncStream { continuation in
            let task = Task {
                for await result in Transaction.updates {
                    if let transaction = try? verified(result) {
                        await transaction.finish()
                    }
                    continuation.yield(await currentEntitlements())
                }
            }
            continuation.onTermination = { _ in
                task.cancel()
            }
        }
    }

    public func products() async throws -> [PurchasableProduct] {
        return try await Product.products(for: ProductID.all).map { product in
            return PurchasableProduct(id: product.id, displayName: product.displayName, displayPrice: product.displayPrice)
        }
    }

    public func purchase(_ productID: String) async throws -> PurchaseOutcome {
        guard let product = try await Product.products(for: [productID]).first else {
            throw Failure.productNotFound(productID)
        }
        let result = try await product.purchase()
        switch result {
        case .success(let verification):
            let transaction = try verified(verification)
            await transaction.finish()
            return .purchased
        case .pending:
            return .pending
        case .userCancelled:
            return .cancelled
        @unknown default:
            return .cancelled
        }
    }

    public func currentEntitlements() async -> Set<String> {
        var ids: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? verified(result) {
                ids.insert(transaction.productID)
            }
        }
        return ids
    }

    public func restore() async throws {
        try await AppStore.sync()
    }

    // MARK: - Private

    private func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            throw error
        }
    }
}
