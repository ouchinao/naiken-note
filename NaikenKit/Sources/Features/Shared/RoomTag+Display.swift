import Domain
import Foundation

extension Photo.RoomTag {
    var title: String {
        switch self {
        case .living:
            return String(localized: "リビング", bundle: .module)
        case .kitchen:
            return String(localized: "キッチン", bundle: .module)
        case .bathroom:
            return String(localized: "浴室", bundle: .module)
        case .toilet:
            return String(localized: "トイレ", bundle: .module)
        case .entrance:
            return String(localized: "玄関", bundle: .module)
        case .balcony:
            return String(localized: "バルコニー", bundle: .module)
        case .storage:
            return String(localized: "収納", bundle: .module)
        case .exterior:
            return String(localized: "外観", bundle: .module)
        case .other:
            return String(localized: "その他", bundle: .module)
        }
    }
}
