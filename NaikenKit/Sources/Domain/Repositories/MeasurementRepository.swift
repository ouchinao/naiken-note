import Foundation

public protocol MeasurementRepository: Sendable {
    func save(_ measurement: Measurement, propertyID: UUID) async throws
    func delete(id: UUID) async throws
}
