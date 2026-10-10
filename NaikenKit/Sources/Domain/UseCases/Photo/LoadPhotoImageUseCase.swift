import Foundation

/// 写真の画像データを取り出す。`Photo` は画像を持たないので、必要な画面だけがこれを使う
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
