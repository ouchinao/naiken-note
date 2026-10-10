import Foundation

/// 物件一覧の顧客別フォルダによる絞り込み(Pro)
public enum CustomerFilter: Hashable, Sendable {
    case all
    case customer(UUID)
    case unassigned

    public func includes(_ property: Property) -> Bool {
        switch self {
        case .all:
            return true
        case .customer(let customerID):
            return property.customerID == customerID
        case .unassigned:
            return property.customerID == nil
        }
    }
}
