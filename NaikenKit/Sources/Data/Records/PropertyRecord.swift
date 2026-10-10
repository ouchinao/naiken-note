import Foundation
import SwiftData

@Model
final class PropertyRecord {
    var id: UUID = UUID()
    var name: String = ""
    var rent: Int?
    var layout: String = ""
    var areaSquareMeters: Double?
    var nearestStation: String = ""
    var walkMinutes: Int?
    var visitedAt: Date = Date()
    var memo: String = ""
    var createdAt: Date = Date()
    var customer: CustomerRecord?

    @Relationship(deleteRule: .cascade, inverse: \PhotoRecord.property)
    var photos: [PhotoRecord]? = []

    @Relationship(deleteRule: .cascade, inverse: \MeasurementRecord.property)
    var measurements: [MeasurementRecord]? = []

    @Relationship(deleteRule: .cascade, inverse: \CheckResultRecord.property)
    var checkResults: [CheckResultRecord]? = []

    init(id: UUID = UUID(), name: String, visitedAt: Date) {
        self.id = id
        self.name = name
        self.visitedAt = visitedAt
    }
}
