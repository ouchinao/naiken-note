import DesignSystem
import Domain
import SwiftUI

extension CheckResult.Rating {
    /// 比較表やチェックリストに出す記号
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

    var color: Color {
        switch self {
        case .good:
            return .positive
        case .neutral:
            return .caution
        case .bad:
            return .negative
        }
    }

    /// VoiceOverで読み上げる名前
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
