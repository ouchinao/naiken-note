import Domain
import Foundation

/// 購入状態を固定で返す。updates は何も流さずに終わる
struct PurchaseServiceStub: PurchaseService {
    var entitlements: Set<String> = []

    var updates: AsyncStream<Set<String>> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }

    func products() async throws -> [PurchasableProduct] {
        return []
    }

    func purchase(_: String) async throws -> PurchaseOutcome {
        return .purchased
    }

    func currentEntitlements() async -> Set<String> {
        return entitlements
    }

    func restore() async throws {}
}
