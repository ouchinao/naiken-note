import Foundation
@testable import Domain

// ロックを省かないのは、@unchecked Sendable でコンパイラによる並行アクセスのチェックを外しているため
final class PurchaseServiceMock: PurchaseService, @unchecked Sendable {
    private(set) var purchasedIDs: [String] = []
    private(set) var restoreCount = 0

    private let lock = NSLock()
    private let stubbedProducts: [PurchasableProduct]
    private let entitlements: Set<String>

    init(products: [PurchasableProduct] = [], entitlements: Set<String> = []) {
        stubbedProducts = products
        self.entitlements = entitlements
    }

    var updates: AsyncStream<Set<String>> {
        return AsyncStream { continuation in
            continuation.finish()
        }
    }

    func products() async throws -> [PurchasableProduct] {
        return stubbedProducts
    }

    func purchase(_ productID: String) async throws -> PurchaseOutcome {
        lock.withLock {
            purchasedIDs.append(productID)
        }
        return .purchased
    }

    func currentEntitlements() async -> Set<String> {
        return entitlements
    }

    func restore() async throws {
        lock.withLock {
            restoreCount += 1
        }
    }
}
