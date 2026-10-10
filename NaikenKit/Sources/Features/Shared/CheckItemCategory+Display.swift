import Domain
import Foundation

extension CheckItem.Category {
    var title: String {
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
