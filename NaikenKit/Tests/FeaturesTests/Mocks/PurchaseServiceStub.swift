import Domain
import Foundation

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
