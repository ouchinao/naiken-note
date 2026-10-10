import Domain
import Foundation

extension Measurement {
    init(record: MeasurementRecord) {
        self.init(
            id: record.id,
            label: record.label,
            valueMillimeters: record.valueMillimeters,
            note: record.note,
            photoID: record.photoID,
            createdAt: record.createdAt
        )
    }
}

extension MeasurementRecord {
    func apply(_ measurement: Measurement) {
        label = measurement.label
        valueMillimeters = measurement.valueMillimeters
        note = measurement.note
        photoID = measurement.photoID
        createdAt = measurement.createdAt
    }
}
