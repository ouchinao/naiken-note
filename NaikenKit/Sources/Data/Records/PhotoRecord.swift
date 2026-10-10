import Domain
import Foundation
import SwiftData

@Model
final class PhotoRecord {
    var id: UUID = UUID()
    @Attribute(.externalStorage) var imageData: Data?
    @Attribute(.externalStorage) var thumbnailData: Data?
    var roomTag: String = Photo.RoomTag.other.rawValue
    var caption: String = ""
    var takenAt: Date = Date()
    var sortOrder: Int = 0
    var property: PropertyRecord?

    init(id: UUID = UUID(), roomTag: Photo.RoomTag, takenAt: Date) {
        self.id = id
        self.roomTag = roomTag.rawValue
        self.takenAt = takenAt
    }
}
