import Foundation

/// 写真ライブラリから自動取り込みする候補の写真
public struct LibraryPhotoCandidate: Identifiable, Hashable, Sendable {
    /// 写真ライブラリ上の識別子
    public let id: String
    let takenAt: Date
    let coordinate: GeoCoordinate?

    public init(id: String, takenAt: Date, coordinate: GeoCoordinate?) {
        self.id = id
        self.takenAt = takenAt
        self.coordinate = coordinate
    }
}
