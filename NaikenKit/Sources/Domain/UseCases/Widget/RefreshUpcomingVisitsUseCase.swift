import Foundation

public struct RefreshUpcomingVisitsUseCase: Sendable {
    private let repository: any PropertyRepository
    private let publisher: any UpcomingVisitPublishing

    public init(repository: any PropertyRepository, publisher: any UpcomingVisitPublishing) {
        self.repository = repository
        self.publisher = publisher
    }

    public func execute(now: Date = Date()) async throws {
        let properties = try await repository.fetchAll()
        let visits = properties
            .filter { $0.visitedAt > now }
            .sorted { $0.visitedAt < $1.visitedAt }
            .prefix(Limits.upcomingVisitCount)
            .map(UpcomingVisit.init(property:))
        await publisher.publish(visits)
    }
}
