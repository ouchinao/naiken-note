import Foundation

public struct FetchPropertiesUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    public func execute(filter: CustomerFilter = .all) async throws -> [Property] {
        let properties = try await repository.fetchAll()
        return properties.filter { filter.includes($0) }.sorted(by: Self.newestVisitFirst)
    }

    // MARK: - Private

    private static func newestVisitFirst(_ lhs: Property, _ rhs: Property) -> Bool {
        if lhs.visitedAt != rhs.visitedAt {
            return lhs.visitedAt > rhs.visitedAt
        }
        if lhs.createdAt != rhs.createdAt {
            return lhs.createdAt > rhs.createdAt
        }
        return lhs.id.uuidString < rhs.id.uuidString
    }
}
