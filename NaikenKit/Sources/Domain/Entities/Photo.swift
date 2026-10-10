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
    public var takenAt: Date
    public var sortOrder: Int

    public init(id: UUID, roomTag: RoomTag, caption: String = "", takenAt: Date, sortOrder: Int = 0) {
        self.id = id
        self.roomTag = roomTag
        self.caption = caption
        self.takenAt = takenAt
        self.sortOrder = sortOrder
    }
}
