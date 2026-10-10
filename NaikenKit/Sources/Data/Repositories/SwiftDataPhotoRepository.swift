import Domain
import Foundation
import SwiftData

@ModelActor
actor SwiftDataPhotoRepository: PhotoRepository {
    func save(_ photo: Photo, imageData: Data, thumbnailData: Data, propertyID: UUID) throws {
        guard let property = try modelContext.propertyRecord(id: propertyID) else {
            throw RepositoryError.propertyNotFound
        }
        let record = PhotoRecord(id: photo.id, roomTag: photo.roomTag, takenAt: photo.takenAt)
        modelContext.insert(record)
        record.apply(photo)
        record.imageData = imageData
        record.thumbnailData = thumbnailData
        record.property = property
        try modelContext.commit()
    }

    func update(_ photo: Photo) throws {
        guard let record = try modelContext.photoRecord(id: photo.id) else {
            return
        }
        record.apply(photo)
        try modelContext.commit()
    }

    func delete(id: UUID) throws {
        guard let record = try modelContext.photoRecord(id: id) else {
            return
        }
        modelContext.delete(record)
        try modelContext.commit()
    }

    func photos(propertyID: UUID) throws -> [Photo] {
        guard let property = try modelContext.propertyRecord(id: propertyID) else {
            return []
        }
        return (property.photos ?? []).map(Photo.init(record:))
    }

    func imageData(id: UUID) throws -> Data? {
        return try modelContext.photoRecord(id: id)?.imageData
    }

    func thumbnailData(id: UUID) throws -> Data? {
        return try modelContext.photoRecord(id: id)?.thumbnailData
    }
}
