import Foundation

/// 項目を永続化しないのは、アプリの更新で項目を直したときに端末ごとの保存データを書き換えずに済ませるため
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

    public let id: String
    public let title: String
    public let category: Category
}
