import Foundation
import SwiftData

/// `@Attribute(.unique)` に頼らないのは、CloudKit と同期するストアでは一意制約を付けられないため
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

    /// 失敗した変更を残さないのは、Repository の actor が同じ context を使い続けるので、次の保存にも失敗した変更が混ざるため
    func commit() throws {
        do {
            try save()
        } catch {
            rollback()
            throw error
        }
        StoreChangeObserver.postLocalChange()
    }
}
