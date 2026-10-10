import Foundation

public struct DeletePropertyUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    /// 物件と、その写真・採寸・チェック結果をまとめて削除する
    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
