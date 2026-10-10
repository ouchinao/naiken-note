import Foundation
import SwiftData

/// id から1件を引く。`@Attribute(.unique)` が使えないので、重複していても先頭の1件を返す
extension ModelContext {
    func propertyRecord(id: UUID) throws -> PropertyRecord? {
        var descriptor = FetchDescriptor<PropertyRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }

    func photoRecord(id: UUID) throws -> PhotoRecord? {
        var descriptor = FetchDescriptor<PhotoRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }

    func measurementRecord(id: UUID) throws -> MeasurementRecord? {
        var descriptor = FetchDescriptor<MeasurementRecord>(predicate: #Predicate { $0.id == id })
        descriptor.fetchLimit = 1
        return try fetch(descriptor).first
    }
}
