import Foundation

public struct SaveCheckResultUseCase: Sendable {
    private let repository: any CheckResultRepository

    public init(repository: any CheckResultRepository) {
        self.repository = repository
    }

    public func execute(_ result: CheckResult, propertyID: UUID) async throws {
        try await repository.save(result, propertyID: propertyID)
    }
}
