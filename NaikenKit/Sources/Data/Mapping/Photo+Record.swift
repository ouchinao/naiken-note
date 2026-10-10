import Domain
import Foundation

extension Photo {
    init(record: PhotoRecord) {
        self.init(
            id: record.id,
            roomTag: RoomTag(rawValue: record.roomTag) ?? .other,
            caption: record.caption,
            takenAt: record.takenAt,
            sortOrder: record.sortOrder
        )
    }
}

extension PhotoRecord {
    func apply(_ photo: Photo) {
        roomTag = photo.roomTag.rawValue
        caption = photo.caption
        takenAt = photo.takenAt
        sortOrder = photo.sortOrder
    }
}
