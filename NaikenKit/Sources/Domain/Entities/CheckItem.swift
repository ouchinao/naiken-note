import Foundation

/// チェックリストの定型項目。永続化せず `CheckItemCatalog` に定数として持つ
public struct CheckItem: Identifiable, Hashable, Sendable {
    public enum Category: String, CaseIterable, Sendable {
        case environment
        case water
        case interior
        case storage
        case common

        public var title: String {
            switch self {
            case .environment:
                return String(localized: "環境", bundle: .module)
            case .water:
                return String(localized: "水回り", bundle: .module)
            case .interior:
                return String(localized: "室内", bundle: .module)
            case .storage:
                return String(localized: "収納", bundle: .module)
            case .common:
                return String(localized: "共用部・周辺", bundle: .module)
            }
        }
    }

    /// `CheckResult.itemKey` が指す識別子
    public let id: String
    public let title: String
    public let category: Category

    public init(id: String, title: String, category: Category) {
        self.id = id
        self.title = title
        self.category = category
    }
}
