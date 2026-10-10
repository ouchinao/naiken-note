import Domain
import Foundation

extension Property {
    init(record: PropertyRecord) {
        self.init(
            id: record.id,
            name: record.name,
            rent: record.rent,
            layout: record.layout,
            areaSquareMeters: record.areaSquareMeters,
            nearestStation: record.nearestStation,
            walkMinutes: record.walkMinutes,
            visitedAt: record.visitedAt,
            memo: record.memo,
            photos: (record.photos ?? []).map(Photo.init(record:)),
            measurements: (record.measurements ?? []).map(Measurement.init(record:)),
            checkResults: (record.checkResults ?? []).map(CheckResult.init(record:)),
            customerID: record.customer?.id,
            createdAt: record.createdAt
        )
    }
}

extension PropertyRecord {
    func apply(_ property: Property) {
        name = property.name
        rent = property.rent
        layout = property.layout
        areaSquareMeters = property.areaSquareMeters
        nearestStation = property.nearestStation
        walkMinutes = property.walkMinutes
        visitedAt = property.visitedAt
        memo = property.memo
        createdAt = property.createdAt
    }
}
