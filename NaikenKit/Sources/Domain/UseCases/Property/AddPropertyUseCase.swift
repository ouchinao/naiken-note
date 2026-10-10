import Foundation

public struct AddPropertyUseCase: Sendable {
    public enum Failure: Error, Equatable {
        case limitReached(limit: Int)
    }

    private let repository: any PropertyRepository
    private let entitlement: any EntitlementProvider

    public init(repository: any PropertyRepository, entitlement: any EntitlementProvider) {
        self.repository = repository
        self.entitlement = entitlement
    }

    public func checkLimit() async throws {
        if let limit = await entitlement.currentEntitlement().propertyLimit {
            let count = try await repository.count()
            if count >= limit {
                throw Failure.limitReached(limit: limit)
            }
        }
    }

    public func execute(name: String, visitedAt: Date) async throws -> Property {
        let property = Property(
            id: UUID(),
            name: name,
            visitedAt: visitedAt,
            createdAt: Date()
        )
        return try await execute(property)
    }

    public func execute(_ property: Property) async throws -> Property {
        try await checkLimit()
        try await repository.save(property)
        return property
    }
}
