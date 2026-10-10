import Foundation

public protocol PurchaseService: Sendable {
    func products() async throws -> [PurchasableProduct]
    func purchase(_ productID: String) async throws -> PurchaseOutcome
    /// 有効な Product ID の集合
    func currentEntitlements() async -> Set<String>
    /// 購入状態が変わるたびに、有効な Product ID の集合を流す
    var updates: AsyncStream<Set<String>> { get }
    func restore() async throws
}
