import Foundation

public struct FetchPropertiesUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Property] {
        return try await repository.fetchAll()
    }
}
