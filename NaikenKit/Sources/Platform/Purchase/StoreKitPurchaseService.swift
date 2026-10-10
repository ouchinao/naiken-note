import Domain
import Foundation
import StoreKit

/// StoreKit の `Product` や `Transaction` を返さないのは、StoreKit の型を Domain に持ち込まないため
public final class StoreKitPurchaseService: PurchaseService {
    private enum Failure: Error {
        case productNotFound(String)
    }

    public init() {}

    /// `Transaction.updates` だけを流さないのは、サブスクが期限で切れても新しいトランザクションは届かず、アプリを開き直すまで Pro のままになるため
    public var updates: AsyncStream<Set<String>> {
        return AsyncStream { continuation in
            let task = Task {
                var expiryWatch = Self.watchExpiration(continuation)
                for await result in Transaction.updates {
                    if let transaction = try? Self.verified(result) {
                        await transaction.finish()
                    }
                    continuation.yield(await Self.activeProductIDs())
                    expiryWatch.cancel()
                    expiryWatch = Self.watchExpiration(continuation)
                }
                expiryWatch.cancel()
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
            let transaction = try Self.verified(verification)
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
        return await Self.activeProductIDs()
    }

    public func restore() async throws {
        try await AppStore.sync()
    }

    // MARK: - Private

    private static func activeProductIDs() async -> Set<String> {
        var ids: Set<String> = []
        for await result in Transaction.currentEntitlements {
            if let transaction = try? verified(result) {
                ids.insert(transaction.productID)
            }
        }
        return ids
    }

    private static func nextExpiration() async -> Date? {
        var dates: [Date] = []
        for await result in Transaction.currentEntitlements {
            if let date = (try? verified(result))?.expirationDate, date > Date() {
                dates.append(date)
            }
        }
        return dates.min()
    }

    private static func watchExpiration(_ continuation: AsyncStream<Set<String>>.Continuation) -> Task<Void, Never> {
        return Task {
            while let expiration = await nextExpiration() {
                do {
                    try await Task.sleep(for: .seconds(expiration.timeIntervalSinceNow))
                } catch {
                    return
                }
                continuation.yield(await activeProductIDs())
            }
        }
    }

    private static func verified<T>(_ result: VerificationResult<T>) throws -> T {
        switch result {
        case .verified(let value):
            return value
        case .unverified(_, let error):
            throw error
        }
    }
}
