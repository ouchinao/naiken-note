import Foundation
@testable import Domain

// テストからは逐次呼ぶだけだが、記録はロックで守ってから @unchecked Sendable にする
final class PhotoRepositoryMock: PhotoRepository, @unchecked Sendable {
    struct SavedPhoto {
        let photo: Photo
        let imageData: Data
        let thumbnailData: Data
        let propertyID: UUID
    }

    private(set) var saved: [SavedPhoto] = []
    private(set) var updated: [Photo] = []
    private(set) var deletedIDs: [UUID] = []

    private let lock = NSLock()
    private let existingPhotos: [Photo]
    private let images: [UUID: Data]

    init(photos: [Photo] = [], images: [UUID: Data] = [:]) {
        existingPhotos = photos
        self.images = images
    }

    func save(_ photo: Photo, imageData: Data, thumbnailData: Data, propertyID: UUID) async throws {
        lock.withLock {
            saved.append(SavedPhoto(photo: photo, imageData: imageData, thumbnailData: thumbnailData, propertyID: propertyID))
        }
    }

    func update(_ photo: Photo) async throws {
        lock.withLock {
            updated.append(photo)
        }
    }

    func delete(id: UUID) async throws {
        lock.withLock {
            deletedIDs.append(id)
        }
    }

    func photos(propertyID _: UUID) async throws -> [Photo] {
        return existingPhotos
    }

    func imageData(id: UUID) async throws -> Data? {
        return images[id]
    }

    func thumbnailData(id: UUID) async throws -> Data? {
        return images[id]
    }
}
