import Domain
import Foundation

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class PurchaseServiceStub: PurchaseService, @unchecked Sendable {
    private let lock = NSLock()
    private var stubbedEntitlements: Set<String>
    private let stubbedProducts: [PurchasableProduct]
    private let outcome: PurchaseOutcome
    private let failure: (any Error)?

    init(
        entitlements: Set<String> = [],
        products: [PurchasableProduct] = [],
        outcome: PurchaseOutcome = .purchased,
        failure: (any Error)? = nil
    ) {
        stubbedEntitlements = entitlements
        stubbedProducts = products
        self.outcome = outcome
        self.failure = failure
    }

    var updates: AsyncStream<Set<String>> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }

    func setEntitlements(_ entitlements: Set<String>) {
        lock.withLock {
            stubbedEntitlements = entitlements
        }
    }

    func products() async throws -> [PurchasableProduct] {
        if let failure {
            throw failure
        }
        return stubbedProducts
    }

    func purchase(_: String) async throws -> PurchaseOutcome {
        if let failure {
            throw failure
        }
        return outcome
    }

    func currentEntitlements() async -> Set<String> {
        return lock.withLock {
            return stubbedEntitlements
        }
    }

    func restore() async throws {
        if let failure {
            throw failure
        }
    }
}
