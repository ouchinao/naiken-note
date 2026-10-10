import Foundation

public struct FetchPropertiesUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    public func execute(filter: CustomerFilter = .all) async throws -> [Property] {
        let properties = try await repository.fetchAll()
        return properties.filter { filter.includes($0) }
    }
}
