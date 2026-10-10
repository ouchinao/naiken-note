import Foundation

public struct PurchasableProduct: Identifiable, Hashable, Sendable {
    public let id: String
    public let displayName: String
    public let displayPrice: String

    public var isSubscription: Bool {
        return id == ProductID.proMonthly
    }

    public init(id: String, displayName: String, displayPrice: String) {
        self.id = id
        self.displayName = displayName
        self.displayPrice = displayPrice
    }
}
