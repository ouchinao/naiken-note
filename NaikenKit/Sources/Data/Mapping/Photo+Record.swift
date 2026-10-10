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
    /// タグ・キャプション・撮影日時・並び順を書き込む。画像は変えない
    func apply(_ photo: Photo) {
        roomTag = photo.roomTag.rawValue
        caption = photo.caption
        takenAt = photo.takenAt
        sortOrder = photo.sortOrder
    }
}
