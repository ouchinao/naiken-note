import Foundation

/// `Photo` に画像を持たせないのは、一覧や比較表を出すたびに全写真の画像をメモリに読み込まないため
public struct LoadPhotoImageUseCase: Sendable {
    public enum Variant: Sendable {
        case thumbnail
        case full
    }

    private let repository: any PhotoRepository

    public init(repository: any PhotoRepository) {
        self.repository = repository
    }

    public func execute(photoID: UUID, variant: Variant) async throws -> Data? {
        switch variant {
        case .thumbnail:
            return try await repository.thumbnailData(id: photoID)
        case .full:
            return try await repository.imageData(id: photoID)
        }
    }
}
