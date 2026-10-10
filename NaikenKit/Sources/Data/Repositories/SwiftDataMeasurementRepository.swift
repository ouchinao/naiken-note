import Domain
import Foundation
import SwiftData

@ModelActor
actor SwiftDataMeasurementRepository: MeasurementRepository {
    func save(_ measurement: Measurement, propertyID: UUID) throws {
        if let record = try modelContext.measurementRecord(id: measurement.id) {
            record.apply(measurement)
        } else {
            guard let property = try modelContext.propertyRecord(id: propertyID) else {
                throw RepositoryError.propertyNotFound
            }
            let record = MeasurementRecord(
                id: measurement.id,
                label: measurement.label,
                valueMillimeters: measurement.valueMillimeters
            )
            modelContext.insert(record)
            record.apply(measurement)
            record.property = property
        }
        try modelContext.commit()
    }

    func delete(id: UUID) throws {
        guard let record = try modelContext.measurementRecord(id: id) else {
            return
        }
        modelContext.delete(record)
        try modelContext.commit()
    }
}
