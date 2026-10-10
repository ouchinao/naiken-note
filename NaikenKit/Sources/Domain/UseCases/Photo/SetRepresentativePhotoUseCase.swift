import Foundation

/// 代表の印を別に持たず並び順の先頭を代表にするのは、2台の端末で別々に選んでも代表が2枚にならないようにするため
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
