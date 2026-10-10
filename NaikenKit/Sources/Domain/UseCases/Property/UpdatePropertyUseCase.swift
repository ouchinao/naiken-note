import Foundation

public struct UpdatePropertyUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    public func execute(_ property: Property) async throws {
        try await repository.save(property)
    }
}
