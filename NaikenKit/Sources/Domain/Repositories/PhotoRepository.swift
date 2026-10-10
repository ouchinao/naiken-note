import Foundation

public protocol PhotoRepository: Sendable {
    func save(_ photo: Photo, imageData: Data, thumbnailData: Data, propertyID: UUID) async throws
    func update(_ photo: Photo) async throws
    func delete(id: UUID) async throws
    func photos(propertyID: UUID) async throws -> [Photo]
    func imageData(id: UUID) async throws -> Data?
    func thumbnailData(id: UUID) async throws -> Data?
}
