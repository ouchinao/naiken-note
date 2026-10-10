import Foundation

public struct UpdatePhotoUseCase: Sendable {
    private let repository: any PhotoRepository

    public init(repository: any PhotoRepository) {
        self.repository = repository
    }

    /// 部屋タグ・キャプションの変更を保存する
    public func execute(_ photo: Photo) async throws {
        try await repository.update(photo)
    }
}
