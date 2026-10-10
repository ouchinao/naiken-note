import Foundation

public enum Entitlement: Sendable {
    case free
    case unlocked
    case pro

    /// 有効な Product ID の集合から購入状態を決める。
    /// Proが有効ならpro、そうでなければunlockがあればunlocked、なければfree
    public init(activeProductIDs: Set<String>) {
        if activeProductIDs.contains(ProductID.proMonthly) {
            self = .pro
        } else if activeProductIDs.contains(ProductID.unlock) {
            self = .unlocked
        } else {
            self = .free
        }
    }

    public var propertyLimit: Int? {
        switch self {
        case .free:
            return Limits.freePropertyCount
        case .unlocked, .pro:
            return nil
        }
    }

    public var canExportComparison: Bool {
        return self != .free
    }

    public var canUseCustomerFolders: Bool {
        return self == .pro
    }
}
