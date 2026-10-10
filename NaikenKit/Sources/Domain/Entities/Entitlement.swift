import Foundation

public enum Entitlement: Sendable {
    case free
    case unlocked
    case pro

    public init(activeProductIDs: Set<String>) {
        if activeProductIDs.contains(ProductID.proMonthly) {
            self = .pro
        } else if activeProductIDs.contains(ProductID.unlock) {
            self = .unlocked
        } else {
            self = .free
        }
    }

    var propertyLimit: Int? {
        switch self {
        case .free:
            return Limits.freePropertyCount
        case .unlocked, .pro:
            return nil
        }
    }

    var canExportComparison: Bool {
        return self != .free
    }

    public var canUseCustomerFolders: Bool {
        return self == .pro
    }
}
