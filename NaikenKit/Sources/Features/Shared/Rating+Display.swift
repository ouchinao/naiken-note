import Domain
import Foundation

extension CheckResult.Rating {
    var symbol: String {
        switch self {
        case .good:
            return "○"
        case .neutral:
            return "△"
        case .bad:
            return "×"
        }
    }

    var accessibilityName: String {
        switch self {
        case .good:
            return String(localized: "良い", bundle: .module)
        case .neutral:
            return String(localized: "普通", bundle: .module)
        case .bad:
            return String(localized: "悪い", bundle: .module)
        }
    }
}
