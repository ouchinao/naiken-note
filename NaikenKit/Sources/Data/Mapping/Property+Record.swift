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
            photos: (record.photos ?? []).map(Photo.init(record:)).sorted { $0.sortOrder < $1.sortOrder },
            measurements: (record.measurements ?? []).map(Measurement.init(record:)).sorted { $0.createdAt < $1.createdAt },
            checkResults: (record.checkResults ?? []).map(CheckResult.init(record:)),
            createdAt: record.createdAt
        )
    }
}

extension PropertyRecord {
    /// 物件そのものの項目を書き込む。子レコードは Repository が扱う
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
