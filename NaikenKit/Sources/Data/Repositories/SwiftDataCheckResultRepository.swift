import Domain
import Foundation
import SwiftData

@ModelActor
actor SwiftDataCheckResultRepository: CheckResultRepository {
    func save(_ result: CheckResult, propertyID: UUID) throws {
        guard let property = try modelContext.propertyRecord(id: propertyID) else {
            throw RepositoryError.propertyNotFound
        }
        let record = (property.checkResults ?? []).first { $0.itemKey == result.itemKey } ?? makeRecord(for: result, in: property)
        record.apply(result)
        try modelContext.save()
        StoreChangeObserver.postLocalChange()
    }

    // MARK: - Private

    private func makeRecord(for result: CheckResult, in property: PropertyRecord) -> CheckResultRecord {
        let record = CheckResultRecord(id: result.id, itemKey: result.itemKey)
        modelContext.insert(record)
        record.property = property
        return record
    }
}
