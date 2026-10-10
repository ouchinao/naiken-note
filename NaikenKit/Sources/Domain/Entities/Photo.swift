import Foundation

public struct Photo: Identifiable, Hashable, Sendable {
    public enum RoomTag: String, CaseIterable, Sendable {
        case living
        case kitchen
        case bathroom
        case toilet
        case entrance
        case balcony
        case storage
        case exterior
        case other
    }

    public let id: UUID
    public var roomTag: RoomTag
    public var caption: String
    public let takenAt: Date
    public var sortOrder: Int

    public init(id: UUID, roomTag: RoomTag, caption: String = "", takenAt: Date, sortOrder: Int = 0) {
        self.id = id
        self.roomTag = roomTag
        self.caption = caption
        self.takenAt = takenAt
        self.sortOrder = sortOrder
    }
}

extension Photo {
    /// 並び順の値だけで比べないのは、2台の端末で同期前に写真を足すと同じ値の写真ができ、読み込むたびに代表写真が入れ替わるため
    static func displayOrder(_ lhs: Photo, _ rhs: Photo) -> Bool {
        if lhs.sortOrder != rhs.sortOrder {
            return lhs.sortOrder < rhs.sortOrder
        }
        if lhs.takenAt != rhs.takenAt {
            return lhs.takenAt < rhs.takenAt
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}
