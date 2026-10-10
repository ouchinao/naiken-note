import Domain
import Foundation

/// 画像を持たない写真Repository
struct PhotoRepositoryStub: PhotoRepository {
    func save(_ photo: Photo, imageData: Data, thumbnailData: Data, propertyID: UUID) async throws {}

    func update(_ photo: Photo) async throws {}

    func delete(id: UUID) async throws {}

    func photos(propertyID: UUID) async throws -> [Photo] {
        return []
    }

    func imageData(id: UUID) async throws -> Data? {
        return nil
    }

    func thumbnailData(id: UUID) async throws -> Data? {
        return nil
    }
}
