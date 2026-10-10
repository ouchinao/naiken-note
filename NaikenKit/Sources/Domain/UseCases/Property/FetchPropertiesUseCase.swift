import Foundation

public struct FetchPropertiesUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    /// 内見日の新しい順に返す
    public func execute() async throws -> [Property] {
        return try await repository.fetchAll()
    }
}
