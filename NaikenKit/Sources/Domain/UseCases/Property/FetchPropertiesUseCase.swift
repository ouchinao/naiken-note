import Foundation

public struct FetchPropertiesUseCase: Sendable {
    private let repository: any PropertyRepository

    public init(repository: any PropertyRepository) {
        self.repository = repository
    }

    public func execute() async throws -> [Property] {
        return try await repository.fetchAll().sorted(by: Self.newestVisitFirst)
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
