import Foundation

public protocol PurchaseService: Sendable {
    func products() async throws -> [PurchasableProduct]
    func purchase(_ productID: String) async throws -> PurchaseOutcome
    func currentEntitlements() async -> Set<String>
    var updates: AsyncStream<Set<String>> { get }
    func restore() async throws
}
