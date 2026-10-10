import Domain
import Foundation

/// 物件の数値を画面表示用の文字列にする
enum DisplayFormat {
    static func rent(_ rent: Int?) -> String {
        guard let rent else {
            return "—"
        }
        return String(localized: "\(rent.formatted(.number))円", bundle: .module)
    }

    static func area(_ squareMeters: Double?) -> String {
        guard let squareMeters else {
            return "—"
        }
        return String(localized: "\(squareMeters.formatted(.number.precision(.fractionLength(0...2))))㎡", bundle: .module)
    }

    static func access(station: String, walkMinutes: Int?) -> String {
        guard let walkMinutes else {
            return station.isEmpty ? "—" : station
        }
        let walk = String(localized: "徒歩\(walkMinutes)分", bundle: .module)
        return station.isEmpty ? walk : "\(station) \(walk)"
    }

    static func millimeters(_ value: Int) -> String {
        return String(localized: "\(value.formatted(.number)) mm", bundle: .module)
    }

    static func visitDate(_ date: Date) -> String {
        return date.formatted(date: .abbreviated, time: .shortened)
    }

    static func layout(_ layout: String) -> String {
        return layout.isEmpty ? "—" : layout
    }
}
