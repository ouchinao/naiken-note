import Foundation

public struct FetchPropertyUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws -> Property? {
        return try await repository.fetch(id: id)
    }
}
