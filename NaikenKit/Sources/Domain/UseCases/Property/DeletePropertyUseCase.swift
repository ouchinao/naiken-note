import Foundation

public struct DeletePropertyUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
