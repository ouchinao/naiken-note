import Domain
import Foundation

/// 画像を持たない写真Repository
struct PhotoRepositoryStub: PhotoRepository {
    func save(_: Photo, imageData _: Data, thumbnailData _: Data, propertyID _: UUID) async throws {}

    func update(_: Photo) async throws {}

    func delete(id _: UUID) async throws {}

    func photos(propertyID _: UUID) async throws -> [Photo] {
        return []
    }

    func imageData(id _: UUID) async throws -> Data? {
        return nil
    }

    func thumbnailData(id _: UUID) async throws -> Data? {
        return nil
    }
}
