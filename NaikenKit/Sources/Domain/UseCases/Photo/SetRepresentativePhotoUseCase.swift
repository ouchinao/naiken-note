import Foundation

/// 写真を並び順の先頭に移し、比較表の代表写真にする
public struct SetRepresentativePhotoUseCase: Sendable {
    private let repository: any PhotoRepository

    public init(repository: any PhotoRepository) {
        self.repository = repository
    }

    public func execute(photoID: UUID, propertyID: UUID) async throws {
        let photos = try await repository.photos(propertyID: propertyID)
        guard let chosen = photos.first(where: { $0.id == photoID }) else {
            return
        }
        let reordered = [chosen] + photos.filter { $0.id != photoID }
        for (index, photo) in reordered.enumerated() where photo.sortOrder != index {
            var updated = photo
            updated.sortOrder = index
            try await repository.update(updated)
        }
    }
}
