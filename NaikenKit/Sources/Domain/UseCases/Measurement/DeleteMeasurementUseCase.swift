import Foundation

public struct DeleteMeasurementUseCase: Sendable {
    private let repository: any MeasurementRepository

    public init(repository: any MeasurementRepository) {
        self.repository = repository
    }

    public func execute(id: UUID) async throws {
        try await repository.delete(id: id)
    }
}
