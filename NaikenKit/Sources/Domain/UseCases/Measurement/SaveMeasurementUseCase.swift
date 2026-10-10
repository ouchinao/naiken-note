import Foundation

public struct SaveMeasurementUseCase: Sendable {
    public enum Failure: Error, Equatable {
        case emptyLabel
        case invalidValue
    }

    private let repository: any MeasurementRepository

    public init(repository: any MeasurementRepository) {
        self.repository = repository
    }

    public func execute(_ measurement: Measurement, propertyID: UUID) async throws {
        if measurement.label.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw Failure.emptyLabel
        }
        if measurement.valueMillimeters <= 0 {
            throw Failure.invalidValue
        }
        try await repository.save(measurement, propertyID: propertyID)
    }
}
